//
// OCCAM
//
// Copyright © 2011-2012, SRI International
//
//  All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// * Neither the name of SRI International nor the names of its contributors may
//   be used to endorse or promote products derived from this software without
//   specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#include "llvm/User.h"
#include "llvm/Module.h"
#include "llvm/Instructions.h"
#include "llvm/Pass.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Support/IRBuilder.h"
#include "llvm/Support/CallSite.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/ADT/StringMap.h"

#include "Specializer.h"
#include "PrevirtTypes.h"
#include "PrevirtualizeInterfaces.h"

#include "proto/Previrt.pb.h"

#include <vector>
#include <string>
#include <stdio.h>
#include <fstream>

using namespace llvm;

namespace previrt
{
  static Constant*
  getEvent(Module* m, StringRef name, const std::vector<Type*>& types)
  {
    Constant* f = m->getFunction(name);
    if (f != NULL)
      return f;

    ArrayRef<Type*> args(types);
    FunctionType* type = FunctionType::get(Type::getVoidTy(m->getContext()),
        args, false);

    return m->getOrInsertFunction(name, type);
  }

  static Constant*
  getEvent(Module* m, StringRef name, const std::vector<Value*>& values)
  {
    Constant* f = m->getFunction(name);
    if (f != NULL)
      return f;

    std::vector<Type*> types;
    types.reserve(values.size());
    for (std::vector<Value*>::const_iterator i = values.begin(), e =
        values.end(); i != e; ++i) {
      types.push_back((*i)->getType());
    }
    return getEvent(m, name, types);
  }

  static Constant*
  getExit(Module* M, const char* failureName, bool fancy)
  {
    Function* failureFunction = M->getFunction(failureName);
    if (failureFunction != NULL) {
      FunctionType* typ = failureFunction->getFunctionType();
      bool badType = false;
      if (fancy) {
        if (!typ->isVarArg() || !typ->getReturnType()->isVoidTy()
            || typ->getNumParams() != 1 || !typ->getParamType(0)->isPointerTy()) {
          PointerType* pty = dyn_cast<PointerType> (typ->getParamType(0));
          if (!pty->getElementType()->isIntegerTy(8)) {
            badType = true;
          }
        } else {
          badType = true;
        }
      } else {
        badType = typ->isVarArg() || !typ->getReturnType()->isVoidTy() ||
        typ->getNumParams() != 1 ||
        !typ->getParamType(0)->isIntegerTy(32);
      }

      if (badType) {
        errs() << "Failure function already exists with bad type.\n";
        typ->dump();
        return NULL;
      } else
        return failureFunction;
    } else {
      FunctionType* typ = NULL;
      if (fancy) {
        typ = FunctionType::get(Type::getVoidTy(M->getContext()),
            ArrayRef<Type*> (Type::getInt8PtrTy(M->getContext(), 0)), true);
      } else {
        typ = FunctionType::get(Type::getVoidTy(M->getContext()),
            ArrayRef<Type*> (Type::getInt32Ty(M->getContext())), false);
      }
      failureFunction = Function::Create(typ, GlobalVariable::ExternalLinkage, failureName, M);
      failureFunction->setDoesNotReturn(true);
      return failureFunction;
    }
  }

  static bool
  getArguments(const std::vector<Value*>& env,
      const google::protobuf::RepeatedField<int>& indicies,
      std::vector<Value*>& result)
  {
    result.reserve(indicies.size());
    for (google::protobuf::RepeatedField<int>::const_iterator i =
        indicies.begin(), e = indicies.end(); i != e; ++i) {
      int idx = *i;
      if (idx < 0)
        idx = env.size() + idx;

      if (idx >= (int) env.size() || idx < 0)
        return false;
      result.push_back(env[idx]);
    }
    return true;
  }

  static void
  tailCall(Value* call, IRBuilder<>& builder)
  {
    if (call->getType()->isVoidTy()) {
      builder.CreateRetVoid();
    } else {
      builder.CreateRet(call);
    }
  }

  static BasicBlock*
  watch(Function* inside, Function* const delegate,
      const proto::ActionTree& policy, std::vector<Value*>& env,
      BasicBlock* failure)
  {
    LLVMContext& ctx = inside->getContext();

    switch (policy.type())
    {
    default:
      assert(false); // Not implemented
      break;
    case proto::CASE:
    {
      assert(policy.has_case_());
      PrevirtType pt(policy.case_().test());
      Function* eq = pt.getEqualityFunction(inside->getParent());
      if (eq == NULL) {
        errs() << "No equality function, defaulting to false\n";
        BasicBlock* trg = watch(inside, delegate, policy.case_()._else(), env,
            failure);
        return trg;
      } else {
        Value* compLeft = env[policy.case_().var()];
        Value* compRight = pt.concretize(*inside->getParent(), compLeft->getType());
        env[policy.case_().var()] = compRight;
        BasicBlock* _then = watch(inside, delegate, policy.case_()._then(),
            env, failure);
        env[policy.case_().var()] = compLeft;
        if (_then == NULL)
          return NULL;
        BasicBlock* _else = watch(inside, delegate, policy.case_()._else(),
            env, failure);
        if (_else == NULL)
          return NULL;

        BasicBlock* bb = BasicBlock::Create(ctx);
        IRBuilder<> builder(bb);
        std::vector<Value*> argVals;
        argVals.reserve(2);
        argVals.push_back(compLeft);
        argVals.push_back(compRight);
        Value* test = builder.CreateCall(eq, ArrayRef<Value*> (argVals));
        SwitchInst* sw = builder.CreateSwitch(test, _else, 1);
        sw->addCase(ConstantInt::getTrue(ctx), _then);
        inside->getBasicBlockList().push_front(bb);
        return bb;
      }
    }
    case proto::EVENT:
    {
      assert(policy.has_event());
      std::vector<Value*> args;
      if (!getArguments(env, policy.event().args(), args)) {
        errs() << "index out of bounds\n";
        return NULL;
      }
      BasicBlock* bb = BasicBlock::Create(ctx);
      IRBuilder<> builder(bb);
      Constant* evt = getEvent(inside->getParent(),
          policy.event().handler().c_str(), args);
      builder.CreateCall(evt, ArrayRef<Value*> (args));
      if (policy.event().has_then()) {
        BasicBlock* then = watch(inside, delegate, policy.event().then(), env,
            failure);
        builder.CreateBr(then);
      } else {
        builder.CreateBr(failure);
      }
      inside->getBasicBlockList().push_front(bb);
      return bb;
    }
    case proto::FORWARD:
    {
      BasicBlock* bb = BasicBlock::Create(ctx);
      IRBuilder<> builder(bb);

      CallInst* call = builder.CreateCall(delegate, ArrayRef<Value*> (
          env.data(), env.data() + delegate->getArgumentList().size()));
      call->setTailCall(true);
      tailCall(call, builder);
      inside->getBasicBlockList().push_front(bb);
      return bb;
    }
    case proto::FAIL:
      return failure;
    }
  }

  bool
  watchFunction(Function* inside, Function* const delegate,
      const proto::ActionTree& policy, Constant* policyError, bool fancyFail)
  {
    std::vector<Value*> env;
    env.reserve(inside->getArgumentList().size());
    for (Function::arg_iterator i = inside->arg_begin(), e = inside->arg_end(); i
        != e; ++i) {
      env.push_back((Value*) &*i);
    }

    LLVMContext& ctx = inside->getContext();

    BasicBlock* failure = BasicBlock::Create(ctx, "failure", inside);

    BasicBlock* result = watch(inside, delegate, policy, env, failure);
    if (result == NULL) {
      inside->deleteBody();
      return false;
    }

    // Build the failure block
    IRBuilder<> builder(failure);
    if (fancyFail) {
      Constant* name = llvm::ConstantDataArray::getString(ctx, delegate->getName(), true);
      GlobalVariable *gv = new GlobalVariable(*inside->getParent(),
          name->getType(), true, GlobalVariable::LinkOnceODRLinkage, name, "");

      Value* v = builder.CreateConstGEP2_32(gv, 0, 0);
      env.insert(env.begin(), v);
      builder.CreateCall(policyError, ArrayRef<Value*> (env));
    } else {
      builder.CreateCall(policyError, ArrayRef<Value*> (ConstantInt::getSigned(
          Type::getInt32Ty(ctx), 1)));
    }

    if (inside->getReturnType()->isVoidTy()) {
      builder.CreateRetVoid();
    } else {
      builder.CreateRet(UndefValue::get(inside->getReturnType()));
    }

    //inside->getBasicBlockList().push_front(result);
    return true;
  }

  static cl::list<std::string> WatchInput("Pwatch-input", cl::NotHidden,
      cl::desc("interfaces to watch"));
  static cl::opt<bool>
      WatchFancy("Pwatch-fancy", cl::Hidden, cl::init(false), cl::desc(
          "should the failure function be passed the name and arguments?"));
  static cl::opt<bool> WatchAllowLocal("Pwatch-local", cl::Hidden, cl::init(
      true), cl::desc("allow local calls to the function"));
  static cl::opt<std::string> WatchFailFunction("Pwatch-fail", cl::Hidden,
      cl::init("exit"), cl::desc("name of function to call"));
  class WatchPass : public ModulePass
  {
  private:
    proto::EnforceInterface interface;
    bool fancy;
    bool allowLocal;
    std::string failureName;
  public:
    static char ID;

  public:
    WatchPass() :
      ModulePass(ID), fancy(WatchFancy.getValue()), allowLocal(
          WatchAllowLocal.getValue()),
          failureName(WatchFailFunction.getValue())
    {
      for (cl::list<std::string>::const_iterator b = WatchInput.begin(), e =
          WatchInput.end(); b != e; ++b) {
        errs() << "Reading file '" << *b << "'...";
        std::ifstream input(b->c_str(), std::ios::binary);
        if (input.fail()) {
          errs() << "failed: file not found\n";
          continue;
        } else {
          proto::EnforceInterface buf;
          if (!buf.ParseFromIstream(&input)) {
            errs() << "failed: reading\n";
            input.close();
            continue;
          }
          interface.MergeFrom(buf);
        }
      }
      errs() << "Done reading.\n";
    }
    virtual
    ~WatchPass()
    {
    }
  public:
    virtual bool
    runOnModule(Module& M)
    {
      bool modified = false;
      Constant* failureFunction = getExit(&M, failureName.c_str(), fancy);

      for (::google::protobuf::RepeatedPtrField<
          proto::EnforceInterface_Functions>::const_iterator i =
          interface.functions().begin(), e = interface.functions().end(); i
          != e; ++i) {
        assert(i->IsInitialized());
        Function* delegate = M.getFunction(i->name());
        if (delegate == NULL)
          continue;
        if (delegate->isDeclaration())
          continue;

        Function* inside = NULL;
        if (allowLocal) {
          inside = Function::Create(delegate->getFunctionType(),
              delegate->getLinkage(), "", &M);
          inside->takeName(delegate);
        } else {
          inside = delegate;
          delegate = CloneFunction(inside);
          M.getFunctionList().push_back(delegate);
          inside->deleteBody();
        }

        if (watchFunction(inside, delegate, i->actions(), failureFunction,
            fancy)) {
          delegate->setLinkage(GlobalValue::InternalLinkage);
          errs() << "rewrote function '" << i->name() << "'\n";
        } else {
          errs() << "failed to rewrite '" << i->name() << "'\n";
        }

        modified = true;
      }
      return modified;
    }
  };
  char WatchPass::ID;

  static RegisterPass<WatchPass> X("Pwatch",
      "watch/enforce an interface inside functions", false, false);
}
