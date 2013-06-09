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

#include "llvm/Value.h"
#include "llvm/User.h"
#include "llvm/Module.h"
#include "llvm/Instructions.h"
#include "llvm/Pass.h"
#include "llvm/Constants.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Support/IRBuilder.h"
#include "llvm/Support/CallSite.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/ADT/StringMap.h"

#include "Specializer.h"
#include "PrevirtTypes.h"
#include "PrevirtualizeInterfaces.h"

#include "proto/Watch.pb.h"

#include <vector>
#include <list>
#include <string>
#include <stdio.h>
#include <fstream>
#include <sys/types.h>
#include <regex.h>

using namespace llvm;

namespace previrt
{
  struct WatchEnv;

  struct WatchContext
  {
    std::list<Function*> added_functions;
    Module* const module;
  public:
    WatchContext(Module* m) :
      module(m)
    {
    }
    virtual
    ~WatchContext()
    {
    }

  public:
    LLVMContext&
    getContext();

    void
    addAllFunctions();

    Value*
    getCallFunction(WatchEnv& env, const google::protobuf::RepeatedPtrField<
        watch::proto::PrimExpr>& exprs, const std::vector<Type*>& types);

    Value*
    getCallFunction(WatchEnv& env, const google::protobuf::RepeatedPtrField<
        watch::proto::PrimExpr>& exprs, const std::vector<Value*>& values);
  };

  struct WatchEnv
  {
    std::vector<Value*> valueEnv;
    std::vector<std::string> matchEnv;
    mutable std::vector<GlobalVariable*> matchCache;
    int argCount;
    WatchContext* const context;
  public:
    WatchEnv(WatchContext* ctx) :
      context(ctx)
    {
    }
    virtual
    ~WatchEnv()
    {
    }
  public:
    LLVMContext&
    getContext()
    {
      return context->getContext();
    }

    void
    init(Function* f)
    {
      argCount = f->getArgumentList().size();
      valueEnv.resize(argCount, NULL);

      for (Function::arg_iterator begin = f->arg_begin(), end = f->arg_end(); begin
          != end; ++begin) {
        valueEnv.push_back(&*begin);
      }
    }

    Value*
    lookupValue(int idx) const
    {
      int orig = idx;
      if (idx < 0)
        idx = this->valueEnv.size() + idx;
      if (idx >= (int) this->valueEnv.size() || idx < 0) {
        errs() << "Looking up bad variable: %" << orig << " (%0 - %"
            << this->matchEnv.size() - 1 << ")\n";
        return NULL;
      }
      return this->valueEnv[idx];
    }
    bool
    lookupMatch(int idx, std::string& result) const
    {
      int orig = idx;
      if (idx < 0)
        idx = this->matchEnv.size() + idx;
      if (idx >= (int) this->matchEnv.size() || idx < 0) {
        errs() << "Looking up bad match variable: $" << orig << " ($0 - $"
            << this->matchEnv.size() - 1 << ")\n";
        return false;
      }
      result = this->matchEnv[idx];
      return true;
    }
    Value*
    materializeMatch(IRBuilder<>& irb, int idx)
    {
      int orig = idx;
      if (idx < 0)
        idx = this->matchEnv.size() + idx;
      if (idx >= (int) this->matchEnv.size() || idx < 0) {
        errs() << "Looking up bad match variable: $" << orig << " ($0 - $"
            << this->matchEnv.size() - 1 << ")\n";
        return NULL;
      }

      if (matchCache[idx] == NULL) {
        matchCache[idx] = materializeStringLiteral(*context->module,
            matchEnv[idx].c_str());
      }

      return irb.CreateConstGEP2_32(matchCache[idx], 0, 0);
    }

    bool
    argRangeAdd(int from, int to, std::vector<Value*>& result) const
    {
      if (from < 0)
        from += argCount;
      if (to < 0)
        to += argCount;

      if (from < 0 || from >= argCount || to < 0 || from >= argCount) {
        return false;
      }
      if (from < to) {
        result.insert(result.end(), valueEnv.begin() + from, valueEnv.begin()
            + to);
      } else {
        result.insert(result.end(), valueEnv.rbegin() + (argCount - from),
            valueEnv.rbegin() + (argCount - to));
      }
      return true;
    }

  };

  LLVMContext&
  WatchContext::getContext()
  {
    return module->getContext();
  }

  void
  WatchContext::addAllFunctions()
  {
    for (std::list<Function*>::iterator i = added_functions.begin(), e =
        added_functions.end(); i != e; ++i) {
      module->getFunctionList().push_back(*i);
    }
    added_functions.clear();
    return;
  }

  Value*
  WatchContext::getCallFunction(WatchEnv& env,
      const google::protobuf::RepeatedPtrField<watch::proto::PrimExpr>& exprs,
      const std::vector<Type*>& types)
  {
    if (exprs.size() == 0) {
      errs() << "No target given!\n";
      return NULL;
    }

    // Special case for calling variable
    if (exprs.size() == 1) {
      const watch::proto::PrimExpr& expr = exprs.Get(0);

      FunctionType* type = NULL;
      if (expr.has_var()) {
        Value* v = env.lookupValue(expr.var());
        if (v == NULL) {
          return NULL;
        }
        type = dyn_cast<FunctionType> (v->getType());
        if (type == NULL) {
          errs() << "Trying to call non-function!\n";
          return NULL;
        }

        return v;
      }
    }

    // The normal case is a string that is constructed from components
    Twine name;
    for (google::protobuf::RepeatedPtrField<watch::proto::PrimExpr>::const_iterator
        i = exprs.begin(), e = exprs.end(); i != e; ++i) {
      if (i->has_var() || i->has_lit()) {
        return NULL;
      }
      if (i->has_match()) {
        std::string res;
        if (!env.lookupMatch(i->match(), res)) {
          errs() << "didn't find! " << i->match() << "\n";
          return NULL;
        }
        name = name.concat(res);
      } else if (i->has_str()) {
        // Get the string...
        name = name.concat(i->str());
      }
    }

    std::string fullName = name.str();
    Constant* f = this->module->getFunction(fullName);
    if (f != NULL)
      return f;

    for (std::list<Function*>::iterator i = added_functions.begin(), e =
        added_functions.end(); i != e; ++i) {
      //iam      if (fullName == (*i)->getNameStr()) {
      //iam        errs() << "early match '" << fullName << "'  '" << (*i)->getNameStr()
      if (fullName == (*i)->getName().str()) {
        errs() << "early match '" << fullName << "'  '" << (*i)->getName().str()
               << "'\n";
        return *i;
      }
    }

    ArrayRef<Type*> args(types);
    FunctionType* type = FunctionType::get(Type::getVoidTy(getContext()), args,
        false);

    Function* function = Function::Create(type,
        GlobalVariable::ExternalWeakLinkage, fullName.c_str());
    added_functions.push_back(function);

    return function;
  }

  Value*
  WatchContext::getCallFunction(WatchEnv& env,
      const google::protobuf::RepeatedPtrField<watch::proto::PrimExpr>& exprs,
      const std::vector<Value*>& values)
  {
    std::vector<Type*> types;
    types.reserve(values.size());
    for (std::vector<Value*>::const_iterator i = values.begin(), e =
        values.end(); i != e; ++i) {
      types.push_back((*i)->getType());
    }
    return getCallFunction(env, exprs, types);
  }

  static Constant*
  getExit(WatchContext* ctx, const char* failureName, bool fancy)
  {
    Function* failureFunction = ctx->module->getFunction(failureName);
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
        badType = typ->isVarArg() || !typ->getReturnType()->isVoidTy()
            || typ->getNumParams() != 1 || !typ->getParamType(0)->isIntegerTy(
            32);
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
        typ = FunctionType::get(Type::getVoidTy(ctx->getContext()), ArrayRef<
            Type*> (Type::getInt8PtrTy(ctx->getContext(), 0)), true);
      } else {
        typ = FunctionType::get(Type::getVoidTy(ctx->getContext()), ArrayRef<
            Type*> (Type::getInt32Ty(ctx->getContext())), false);
      }
      failureFunction = Function::Create(typ, GlobalVariable::ExternalLinkage,
          failureName);
      ctx->added_functions.push_back(failureFunction);
      failureFunction->setDoesNotReturn(true);
      return failureFunction;
    }
  }

  static Value*
  getValue(WatchEnv& env, IRBuilder<>& irb, const watch::proto::PrimExpr& expr)
  {
    if (expr.has_var()) {
      return env.lookupValue(expr.var());
    } else if (expr.has_lit()) {
      if (expr.lit().type() == proto::I) {
        Type* type = IntegerType::get(env.getContext(),
            expr.lit().int_().bits());
        Module& m = *irb.GetInsertBlock()->getParent()->getParent();
        return PrevirtType(expr.lit()).concretize(m, type);
      } else {
        // TODO: literals not implemented!
        errs() << "Only integer literals are implemented!\n";
        return NULL;
      }
    } else if (expr.has_match()) {
      return env.materializeMatch(irb, expr.match());
    } else if (expr.has_str()) {
      std::string contents = expr.str();
      Constant* cnst = llvm::ConstantDataArray::getString(env.getContext(), expr.str(), true);

      ConstantInt* zero32 = ConstantInt::get(IntegerType::getInt32Ty(
          env.getContext()), 0, false);
      return ConstantExpr::getGetElementPtr(cnst, zero32, true);
    } else {
      errs() << "Empty PrimExpr!\n";
      return NULL;
    }
  }

  static bool
  getArguments(
      WatchEnv& env,
      IRBuilder<>& irb,
      const google::protobuf::RepeatedPtrField<watch::proto::PrimExprs>& indicies,
      std::vector<Value*>& result)
  {
    int count = 0;
    for (google::protobuf::RepeatedPtrField<watch::proto::PrimExprs>::const_iterator
        i = indicies.begin(), e = indicies.end(); i != e; ++i) {
      if (i->has_one() && i->has_args()) {
        errs() << "Too many PrimExprs!\n";
        return false;
      }
      if (i->has_one()) {
        count++;
        continue;
      }
      if (i->has_args()) {
        count += i->args().end() - i->args().start();
        continue;
      }

      errs() << "Empty PrimExprs!\n";
      return false;
    }
    result.reserve(count);

    for (google::protobuf::RepeatedPtrField<watch::proto::PrimExprs>::const_iterator
        i = indicies.begin(), e = indicies.end(); i != e; ++i) {
      if (i->has_one()) {
        Value* val = getValue(env, irb, i->one());
        result.push_back(val);
      } else {
        assert(i->has_args());

        if (!env.argRangeAdd(i->args().start(), i->args().end(), result)) {
          return false;
        }
      }
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

  static void
  returnUndef(Function* inside, IRBuilder<>& builder)
  {
    if (inside->getReturnType()->isVoidTy()) {
      builder.CreateRetVoid();
    } else {
      builder.CreateRet(UndefValue::get(inside->getReturnType()));
    }
  }

  static bool
  compileAction(Function* inside, const Function* const delegate,
      const watch::proto::ActionTree& policy, WatchContext& ctx, WatchEnv& env,
      BasicBlock* result, BasicBlock* failure, BasicBlock* success)
  {
    IRBuilder<> builder(result);

    if (policy.has_if_()) {

      PrevirtType pt(policy.if_().test());
      Function* eq = pt.getEqualityFunction(inside->getParent());
      if (eq == NULL) {
        errs() << "No equality function, defaulting to false\n";
        if (policy.if_().has__else()) {
          return compileAction(inside, delegate, policy.if_()._else(), ctx,
              env, result, failure, success);

        } else {
          errs()
              << "No equality function, and no else. defaulting to failure\n";
          builder.CreateBr(failure);
          return true;
        }

      } else {

        Value* compLeft = env.lookupValue(policy.if_().var());
        Value* compRight =
            pt.concretize(*inside->getParent(), compLeft->getType());
        env.valueEnv[policy.if_().var()] = compRight;
        BasicBlock* _then = BasicBlock::Create(result->getContext());
        if (!compileAction(inside, delegate, policy.if_()._then(), ctx, env,
            _then, failure, success)) {
          return false;
        }
        env.valueEnv[policy.if_().var()] = compLeft;
        BasicBlock* _else;
        if (policy.if_().has__else()) {
          _else = BasicBlock::Create(result->getContext());
          if (!compileAction(inside, delegate, policy.if_()._else(), ctx, env,
              _else, failure, success)) {
            return false;
          }
        } else {
          _else = success;
        }

        std::vector<Value*> argVals;
        argVals.reserve(2);
        argVals.push_back(compLeft);
        argVals.push_back(compRight);
        Value* test = builder.CreateCall(eq, ArrayRef<Value*> (argVals));
        SwitchInst* sw = builder.CreateSwitch(test, _else, 1);
        sw->addCase(ConstantInt::getTrue(ctx.getContext()), _then);
        return true;
      }

    } else if (policy.has_forward()) {

      CallInst* call = builder.CreateCall(const_cast<Function*> (delegate),
          ArrayRef<Value*> (env.valueEnv.data(), env.valueEnv.data()
              + delegate->getArgumentList().size()));
      env.valueEnv.push_back(call);
      builder.CreateBr(success);

      return true;

    } else if (policy.has_call()) {

      std::vector<Value*> args;
      BasicBlock* def = BasicBlock::Create(ctx.getContext(), "defined", inside);
      IRBuilder<> dbuilder(def);

      if (!getArguments(env, dbuilder, policy.call().args(), args)) {
        errs() << "index out of bounds\n";
        return false;
      }
      Value* evt = ctx.getCallFunction(env, policy.call().target(), args);
      if (evt == NULL) {
        return false;
      }

      BasicBlock* join = BasicBlock::Create(ctx.getContext(), "join", inside);
      Value* evt_int = builder.CreatePtrToInt(evt, Type::getInt32Ty(
          ctx.getContext()));
      SwitchInst* sw = builder.CreateSwitch(evt_int, def, 1);
      sw->addCase(
          ConstantInt::get(Type::getInt32Ty(ctx.getContext()), 0, true), join);

      CallInst* call = dbuilder.CreateCall(evt, ArrayRef<Value*> (args));
      if (policy.call().tail()) {
        tailCall(call, dbuilder);
        return true;
      } else {
        dbuilder.CreateBr(join);
      }

      IRBuilder<> jbuilder(join);
      jbuilder.CreateBr(success);
      return true;

    } else if (policy.has_return_()) {

      IRBuilder<> builder(result);
      if (policy.return_().undef()) {
        returnUndef(inside, builder);
        return result;
      } else if (policy.return_().has_value()) {
        if (inside->getReturnType()->isVoidTy()) {
          builder.CreateRetVoid();
        } else {
          builder.CreateRet(getValue(env, builder, policy.return_().value()));
        }
        return result;
      } else {

        returnUndef(inside, builder);
        return result;
      }

    } else if (policy.has_fail()) {

      builder.CreateBr(failure);
      return true;

    } else if (policy.seq_size() > 0) {

      BasicBlock** blocks = new BasicBlock*[policy.seq_size() + 1];
      blocks[0] = result;
      for (int i = 1; i < policy.seq_size(); ++i) {
        blocks[i] = BasicBlock::Create(result->getContext(), "",
            result->getParent());
        assert(blocks[i] != NULL);
      }
      blocks[policy.seq_size()] = success;

      for (int i = 0; i < policy.seq_size(); ++i) {
        const watch::proto::ActionTree& tr = policy.seq(i);
        if (!compileAction(inside, delegate, tr, ctx, env, blocks[i], failure,
            blocks[i + 1])) {
          // Don't delete the blocks because they were llvm allocated
          delete blocks;
          return false;
        }
      }
      delete blocks;
      return true;
    } else {
      errs() << "Empty ActionTree!\n";
      return false;
    }

  }

  bool
  watchFunction(WatchContext& ctx, WatchEnv& env, Function* inside,
      const Function* const delegate, const watch::proto::ActionTree& policy,
      Constant* policyError, bool fancyFail)
  {
    env.valueEnv.clear();
    env.valueEnv.reserve(inside->getArgumentList().size());
    for (Function::arg_iterator i = inside->arg_begin(), e = inside->arg_end(); i
        != e; ++i) {
      env.valueEnv.push_back(&*i);
    }

    BasicBlock* result = BasicBlock::Create(ctx.getContext(), "entry", inside);
    BasicBlock* success = BasicBlock::Create(ctx.getContext(), "success",
        inside);
    BasicBlock* failure = BasicBlock::Create(ctx.getContext(), "failure",
        inside);

    if (!compileAction(inside, delegate, policy, ctx, env, result, failure,
        success)) {
      inside->deleteBody();
      return false;
    }

    // Build the failure block
    IRBuilder<> builder(failure);
    if (fancyFail) {
      Constant* name = llvm::ConstantDataArray::getString(ctx.getContext(),
							  delegate->getName(),
							  true);
      GlobalVariable *gv = new GlobalVariable(*inside->getParent(),
          name->getType(), true, GlobalVariable::LinkOnceODRLinkage, name, "");

      Value* v = builder.CreateConstGEP2_32(gv, 0, 0);
      env.valueEnv.insert(env.valueEnv.begin(), v);
      builder.CreateCall(policyError, ArrayRef<Value*> (env.valueEnv));
    } else {
      builder.CreateCall(policyError, ArrayRef<Value*> (ConstantInt::getSigned(
          Type::getInt32Ty(ctx.getContext()), 1)));
    }
    returnUndef(inside, builder);

    IRBuilder<> builder2(success);
    returnUndef(inside, builder2);

    return true;
  }

  static bool
  patternMatches(const watch::proto::PatternExpr& ptrn,
      const std::string& fname, FunctionType* ft, WatchEnv& env)
  {
    for (google::protobuf::RepeatedPtrField<std::string>::const_iterator ex =
        ptrn.exclude().begin(), end = ptrn.exclude().end(); ex != end; ++ex) {
      if (fname == *ex) {
        return false;
      }
    }

    env.matchEnv.clear();
    env.matchCache.clear();
    if (ptrn.has_function_name()) {
      regex_t reg;
      if (regcomp(&reg, ptrn.function_name().c_str(), REG_EXTENDED)) {
        errs() << "Bad regular expression: '" << ptrn.function_name() << "'\n";
        return false;
      }

#define MAX_MATCH 10
      regmatch_t matches[MAX_MATCH];

      if (REG_NOMATCH == regexec(&reg, fname.c_str(), MAX_MATCH, matches, 0)) {
        regfree(&reg);
        return false;
      }
      errs() << "matched!\n";

      int count = MAX_MATCH - 1;
      while (count >= 0 && matches[count].rm_eo == -1) {
        count--;
      }
      env.matchEnv.reserve(count + 1);
      env.matchEnv.push_back(fname);
      env.matchCache.resize(count + 1, NULL);
      for (int i = 0; i < count; i++) {
        env.matchEnv.push_back(std::string(fname.c_str() + matches[i].rm_so,
            matches[i].rm_eo - matches[i].rm_so));
        errs() << "Match captured: '" << env.matchEnv[i + 1] << "'\n";
      }
    }

    return true;
  }

  static const Function*
  getAliasedFunction(const GlobalAlias* alias)
  {
    const GlobalValue* gv = alias->getAliasedGlobal();
    if (gv == NULL)
      return NULL;
    if (const Function* f = dyn_cast<Function>(gv)) {
      return f;
    } else if (const GlobalAlias* a = dyn_cast<GlobalAlias>(gv)) {
      return getAliasedFunction(a);
    } else {
      // This is a GlobalVariable, probably not legit
      return NULL;
    }
  }

  static cl::list<std::string> WatchInput("Pwatch2-input", cl::NotHidden,
      cl::desc("interfaces to watch"));
  static cl::opt<bool>
      WatchFancy("Pwatch2-fancy", cl::Hidden, cl::init(false), cl::desc(
          "should the failure function be passed the name and arguments?"));
  static cl::opt<bool> WatchAllowLocal("Pwatch2-local", cl::Hidden, cl::init(
      false), cl::desc("allow local calls to the function"));
  static cl::opt<std::string> WatchFailFunction("Pwatch2-fail", cl::Hidden,
      cl::init("exit"), cl::desc("name of function to call"));
  class WatchPass2 : public ModulePass
  {
  private:
    watch::proto::WatchInterface interface;
    bool fancy;
    bool allowLocal;
    std::string failureName;
  public:
    static char ID;

  public:
    WatchPass2() :
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
          watch::proto::WatchInterface buf;
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
    ~WatchPass2()
    {
    }
  public:
    virtual bool
    runOnModule(Module& M)
    {
      bool modified = false;

      WatchContext context(&M);
      WatchEnv env(&context);
      Constant* failureFunction = getExit(&context, failureName.c_str(), fancy);

      for (Module::iterator fi = M.begin(), fe = M.end(); fi != fe; ++fi) {
        Function* delegate = &*fi;
        //iam        std::string name = delegate->getNameStr();
        std::string name = delegate->getName().str();

        // TODO we can do this (somewhat) for declarations
        if (delegate->isDeclaration())
          continue;
        // TODO variable argument function support is not implemented
        if (delegate->isVarArg())
          continue;

        for (::google::protobuf::RepeatedPtrField<
            watch::proto::WatchInterface_Hooks>::const_iterator i =
            interface.hooks().begin(), e = interface.hooks().end(); i != e; ++i) {
          if (patternMatches(i->pattern(), name, delegate->getFunctionType(),
              env)) {
            Function* inside = NULL;

            if (allowLocal) {
              inside = Function::Create(delegate->getFunctionType(),
                  delegate->getLinkage(), "");
              context.added_functions.push_back(inside);
              inside->takeName(delegate);
            } else {
              inside = delegate;
              delegate = CloneFunction(inside);
              context.added_functions.push_back(delegate);
              inside->deleteBody();
            }

            if (watchFunction(context, env, inside, delegate, i->action(),
                failureFunction, fancy)) {
              delegate->setLinkage(GlobalValue::InternalLinkage);
              errs() << "rewrote function '" << name << "'\n";
              modified = true;
            } else {
              errs() << "failed to rewrite '" << name << "'\n";
            }
          }
        }
      }

      for (Module::alias_iterator fi = M.alias_begin(), fe = M.alias_end(); fi
          != fe; ++fi) {
        GlobalAlias* alias = &*fi;

        assert(alias != NULL);

        const Function* delegate = getAliasedFunction(alias);
        if (delegate == NULL) {
          // You can only watch functions...
          continue;
        }
        FunctionType* ft = delegate->getFunctionType();

        if (delegate->isDeclaration() || delegate->isVarArg()) {
          // We don't watch declarations
          // We can't watch var arg functions yet
          continue;
        }

        //iam        const std::string& name = alias->getNameStr();
        const std::string& name = alias->getName().str();

        for (::google::protobuf::RepeatedPtrField<
            watch::proto::WatchInterface_Hooks>::const_iterator i =
            interface.hooks().begin(), e = interface.hooks().end(); i != e; ++i) {
          if (patternMatches(i->pattern(), name, ft, env)) {
            Function* inside = NULL;

            if (allowLocal) {
              // TODO: Not implemented
              assert(false && "not implemented");
              /*inside = Function::Create(ft, alias->getLinkage(), "");
               context.added_functions.push_back(inside);
               inside->takeName(alias);*/
            } else {
              inside = Function::Create(ft, GlobalValue::InternalLinkage);
              context.added_functions.push_back(inside);
              alias->setAliasee(ConstantExpr::getBitCast(inside,
                  alias->getType()));
            }

            if (watchFunction(context, env, inside, delegate, i->action(),
                failureFunction, fancy)) {
              inside->setLinkage(GlobalValue::InternalLinkage);
              errs() << "rewrote function '" << name << "'\n";
              modified = true;
            } else {
              errs() << "failed to rewrite '" << name << "'\n";
            }
          }
        }
      }
      context.addAllFunctions();
      return true;
    }
  };
  char WatchPass2::ID;

  static RegisterPass<WatchPass2> X("Pwatch2",
      "watch/enforce an interface inside functions", false, false);
}
