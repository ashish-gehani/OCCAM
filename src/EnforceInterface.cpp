//
// OCCAM
//
// Copyright (c) 2011-2012, SRI International
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

#include "llvm/ADT/StringMap.h"
#include "llvm/IR/User.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Pass.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/CallSite.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "Specializer.h"
#include "PrevirtTypes.h"
#include "PrevirtualizeInterfaces.h"

#include <vector>
#include <string>
#include <stdio.h>
#include <fstream>

using namespace llvm;

namespace previrt
{
  struct FunctionContract
  {
  protected:
    FunctionContract()
    {
    }
  public:
    virtual
    ~FunctionContract()
    {
    }
  public:
    virtual const BasicBlock*
    emitEntryTest(Function* inside, const BasicBlock* success,
        const BasicBlock* failure) const = 0;

  public:
    static FunctionContract*
    fromPrevirtType(const std::vector<PrevirtType>& types);
    static FunctionContract*
    fromCallInfo(const CallInfo& info);
    static FunctionContract*
    anyContract(const std::vector<FunctionContract*>& contracts);
  };

  struct OrContract : public FunctionContract
  {
  private:
    const std::vector<FunctionContract*> contracts;
  public:
    OrContract(const std::vector<FunctionContract*>& _contracts) :
      contracts(_contracts)
    {
    }
    virtual
    ~OrContract()
    {
      for (std::vector<FunctionContract*>::const_iterator i =
          this->contracts.begin(), e = this->contracts.end(); i != e; ++i) {
        delete *i;
      }
    }
  public:
    virtual const BasicBlock*
    emitEntryTest(Function* inside, const BasicBlock* success,
        const BasicBlock* failure) const
    {
      const BasicBlock* top = failure;
      for (std::vector<FunctionContract*>::const_reverse_iterator i =
          this->contracts.rbegin(), e = this->contracts.rend(); i != e; ++i) {
        top = (*i)->emitEntryTest(inside, success, top);
      }
      return top;
    }
  };

  struct SingletonTypeContract : public FunctionContract
  {
  private:
    const std::vector<PrevirtType> params;
  public:
    SingletonTypeContract(const std::vector<PrevirtType>& _params) :
      params(_params)
    {
    }
    virtual
    ~SingletonTypeContract()
    {
    }
  public:
    virtual const BasicBlock*
    emitEntryTest(Function* inside, const BasicBlock* success,
        const BasicBlock* failure) const
    {
      LLVMContext& ctx = success->getContext();
      const BasicBlock* top = success;
      Function::ArgumentListType::const_reverse_iterator args =
          inside->getArgumentList().rbegin();
      for (std::vector<PrevirtType>::const_reverse_iterator b =
          this->params.rbegin(), e = this->params.rend(); b != e; ++b, ++args) {
        if (!b->isConcrete()) {
          // Nothing to check for non-concrete values
          continue;
        }

        // Generate a function to test the equality
        Function* eq = b->getEqualityFunction(inside->getParent());
        if (eq == NULL) {
          errs() << "No equality function, defaulting to false\n";
          return failure;
        }

        // Call the function
        BasicBlock* bb = BasicBlock::Create(ctx);
        inside->getBasicBlockList().push_front(bb);
        IRBuilder<> builder(bb);

        std::vector<Value*> argVals;
        argVals.reserve(2);
        argVals.push_back(b->concretize(*inside->getParent(), args->getType()));
        argVals.push_back(const_cast<Argument*> (&*args));
        Value* test = builder.CreateCall(eq, ArrayRef<Value*> (argVals));
        SwitchInst* sw = builder.CreateSwitch(test,
            const_cast<BasicBlock*> (failure), 1);
        sw->addCase((ConstantInt*) ConstantInt::getTrue(Type::getInt1Ty(ctx)),
            const_cast<BasicBlock*> (top));
        top = bb;
      }
      return top;
    }
  };

  FunctionContract*
  FunctionContract::fromPrevirtType(const std::vector<PrevirtType>& types)
  {
    return new SingletonTypeContract(types);
  }
  FunctionContract*
  FunctionContract::fromCallInfo(const CallInfo& info)
  {
    std::vector<PrevirtType> types;
    types.reserve(info.args.size());
    types.insert(types.begin(), info.args.begin(), info.args.end());
    return FunctionContract::fromPrevirtType(types);
  }
  FunctionContract*
  FunctionContract::anyContract(const std::vector<FunctionContract*>& contracts)
  {
    return new OrContract(contracts);
  }

  /*
   * Generate a piece of code in F that enforces I, protecting calls to call
   */
  void
  protectCall(Function* F, Function* const call, const FunctionContract& I)
  {
    std::vector<Value*> ary;
    ary.reserve(F->getArgumentList().size());
    for (Function::ArgumentListType::iterator i = F->getArgumentList().begin(),
        e = F->getArgumentList().end(); i != e; ++i) {
      ary.push_back(&*i);
    }

    BasicBlock* call_bb = BasicBlock::Create(F->getContext());
    {
      F->getBasicBlockList().push_back(call_bb);
      IRBuilder<> builder(call_bb);

      if (F->getReturnType() == Type::getVoidTy(F->getContext())) {
        CallInst* ci = builder.CreateCall(call, ArrayRef<Value*> (ary), "");
        ci->setTailCall(true);
        builder.CreateRetVoid();
      } else {
        CallInst* ci = builder.CreateCall(call, ArrayRef<Value*> (ary),
            "delegate");
        ci->setTailCall(true);
        builder.CreateRet(ci);
      }
    }

    BasicBlock* fail_bb = BasicBlock::Create(F->getContext());
    {
      std::vector<Type*> arg_types;
      arg_types.reserve(1);
      arg_types.push_back(Type::getInt8PtrTy(F->getContext()));

      FunctionType* policyErrorType = FunctionType::get(Type::getVoidTy(
          F->getContext()), ArrayRef<Type*> (arg_types), true);
      Constant* policyError = F->getParent()->getOrInsertFunction(
          "policyError", policyErrorType);

      F->getBasicBlockList().push_back(fail_bb);
      IRBuilder<> builder(fail_bb);

      Constant* name = llvm::ConstantDataArray::getString(F->getContext(), F->getName(), true);
      GlobalVariable *gv = new GlobalVariable(*F->getParent(), name->getType(),
          true, GlobalVariable::LinkOnceODRLinkage, name, "");

      Value* v = builder.CreateConstGEP2_32(gv->getType(), gv, 0, 0); // gv->getType() is a guess
      ary.insert(ary.begin(), v);
      builder.CreateCall(policyError, ArrayRef<Value*> (ary), "");
      if (F->getReturnType() == Type::getVoidTy(F->getContext())) {
        builder.CreateRetVoid();
      } else {
        builder.CreateRet(UndefValue::get(F->getReturnType()));
      }
    }

    I.emitEntryTest(F, call_bb, fail_bb);
  }

  /*
   * Enforce an interface inside a call
   */
  Function*
  enforceInterfaceInside(Function* F, const FunctionContract& I)
  {
    assert(!F->isDeclaration());

    Function* wrapF = Function::Create(F->getFunctionType(), F->getLinkage(),
        "", F->getParent());
    wrapF->copyAttributesFrom(F);
    F->setLinkage(Function::InternalLinkage);

    protectCall(wrapF, F, I);

    return wrapF;
  }

  Function*
  enforceInterfaceOutside(Function* F, const FunctionContract& I)
  {
    assert(F->isDeclaration());

    Function* underF = Function::Create(F->getFunctionType(), F->getLinkage(),
        "", F->getParent());
    underF->copyAttributesFrom(F);
    F->setLinkage(GlobalVariable::InternalLinkage);

    protectCall(F, underF, I);
    underF->takeName(F);

    return underF;
  }

  /*
   *
   */
  FunctionContract*
  getContractFromInterface(StringRef name, ComponentInterface& T)
  {
    ComponentInterface::FunctionIterator f = T.find(name);
    if (f == T.end())
      return NULL;

    std::vector<FunctionContract*> options;

    options.reserve(f->second.size());
    for (ComponentInterface::CallIterator i = T.call_begin(f), e =
        T.call_end(f); i != e; ++i) {
      options.push_back(FunctionContract::fromCallInfo(**i));
    }

    return FunctionContract::anyContract(options);
  }

  bool
  enforceInterface(Module& M, ComponentInterface& T, bool inside)
  {
    for (ComponentInterface::FunctionIterator i = T.begin(), e = T.end(); i
        != e; ++i) {
      Function* f = M.getFunction(i->first());
      if (f == NULL)
        continue;

      if (inside) {
        if (!f->isDeclaration()) {
          FunctionContract* contract =
              getContractFromInterface(f->getName(), T);
          if (contract) {
            enforceInterfaceInside(f, *contract);
            delete contract;
          }
        }
      } else {
        if (f->isDeclaration()) {
          FunctionContract* contract =
              getContractFromInterface(f->getName(), T);
          if (contract) {
            enforceInterfaceOutside(f, *contract);
            delete contract;
          }
        }
      }
    }
    return true;
  }

#define ENFORCE_MACRO(dir, fn)                                                           \
  static cl::list<std::string> EnforceInterface_##dir##_Input("Penforce-" #dir "-input", \
          cl::NotHidden, cl::desc("interfaces to enforce"));                             \
  class EnforceInterface_##dir##_Pass : public ModulePass                                \
  {                                                                                      \
  public:                                                                                \
    ComponentInterface interface;                                                        \
    static char ID;                                                                      \
  public:                                                                                \
    EnforceInterface_##dir##_Pass() :                                                    \
      ModulePass(ID)                                                                     \
    {                                                                                    \
      for (cl::list<std::string>::const_iterator                                         \
              b = EnforceInterface_##dir##_Input.begin(),                                \
              e = EnforceInterface_##dir##_Input.end();                                  \
           b != e; ++b) {                                                                \
        errs() << "Reading file '" << *b << "'...";                                      \
        if (interface.readFromFile(*b)) {                                                \
          errs() << "success\n";                                                         \
        } else {                                                                         \
          errs() << "failed\n";                                                          \
        }                                                                                \
      }                                                                                  \
      errs() << "Done reading.\n";                                                       \
    }                                                                                    \
    virtual                                                                              \
    ~EnforceInterface_##dir##_Pass()                                                     \
    {                                                                                    \
    }                                                                                    \
  public:                                                                                \
    virtual bool                                                                         \
    runOnModule(Module& M)                                                               \
    {                                                                                    \
      return enforceInterface(M, this->interface, fn);                                   \
    }                                                                                    \
  };                                                                                     \
  char EnforceInterface_##dir##_Pass::ID;                                                \
                                                                                         \
  static RegisterPass<EnforceInterface_##dir##_Pass> X_##dir("Penforce-" #dir,           \
      "enforce an interface " #dir " calls", false, false);
  ENFORCE_MACRO(inside, true)
  ENFORCE_MACRO(outside, false)
}
