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

#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/ValueMap.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Analysis/AliasAnalysis.h"

#include "llvm/ADT/ArrayRef.h"

#include "PrevirtTypes.h"
#include "Specializer.h"

#include <fstream>

using namespace llvm;

namespace previrt
{
  std::string
  specializeName(Function* f, std::vector<std::string>& args)
  {
    args.clear();
    //iam    std::string fn = f->getNameStr();
    std::string fn = f->getName().str();

    int idx = fn.find('(');
    if (idx != -1 && fn[fn.length()-1] == ')') {
      std::string base = fn.substr(0, idx);
      idx++;
      unsigned int st = idx;
      bool in_str = false;
      while (st < fn.length()-1) {
        idx = st;
        while (true) {
          if (fn[idx] == '"') {
            in_str = !in_str;
          } else if (!in_str) {
            if (fn[idx] == ',') {
              args.push_back(fn.substr(st, idx-st));
              break;
            } else if (fn[idx] == ')') {
              args.push_back(fn.substr(st, idx-st));
              break;
            }
          } else {
            if (fn[idx] == '\\') {
              idx += 2;
            }
          }
          idx++;
        }
        st = idx + 1;
      }
      return base;
    } else {
      unsigned alen = f->arg_size();
      args.reserve(alen);
      for (unsigned int i = 0; i < alen; ++i)
        args.push_back("?");
      //iam      return f->getNameStr();
      return f->getName().str();
    }
  }

  Function*
  specializeFunction(Function *f, Value*const* args)
  // make a copy of f
  // specialize on the arguments, a null means that that argument isn't known
  {
    assert(!f->isDeclaration());
    ValueToValueMapTy vmap;

    unsigned int i = 0;
    unsigned int j = 0;
    std::vector<std::string> argNames;

    std::string baseName = specializeName(f, argNames);

    for (Function::arg_iterator itr = f->arg_begin(); itr != f->arg_end(); itr++, i++) {
      while (argNames[j] != "?") j++;
      if (args[i] != NULL) {
        Value* arg = (Value*) &(*itr);

        assert(arg->getType() == args[i]->getType()
	       && "Specializing argument with concrete value of wrong type!");

        vmap.insert(typename ValueToValueMapTy::value_type (arg, args[i]));
        PrevirtType pt = PrevirtType::abstract(args[i]);
        argNames[j] = pt.to_string();
        /*
        if (const ConstantInt* ci = dyn_cast<const ConstantInt> (args[i])) {
          argNames[j] = ci->getValue().toString(10, true);
        } else if (const Constant* c = dyn_cast<const Constant>(args[i])) {
          if (c->isNullValue()) {
            argNames[j] = "null";
          } else {
            assert(false);
          }
        } else if (const )
        } else {
          assert(false);
        }
        */
      }
      j++;
    }
    assert (i == f->arg_size());

    baseName += "(";
    for (std::vector<std::string>::const_iterator it = argNames.begin(), be = argNames.begin(), en = argNames.end(); it != en; ++it) {
      if (it != be) baseName += ",";
      baseName += *it;
    }
    baseName += ")";

    Function *result = f->getParent()->getFunction(baseName);
    // If specialized function already exists, no reason
    // to create another one. In fact, can cause the process
    // to diverge. XXX This needs to be a more sophisticated
    // check
    if (!result) {
      ClonedCodeInfo info;
      result = llvm::CloneFunction(f, vmap, &info);
      result->setName(baseName);
    }
    return result;
  }

  Function*
  specializeFunction(Function *f, const std::vector<Value*>& args)
  {
    assert(!f->isDeclaration());
    assert(f->arg_size() == args.size());
    Function *nfunc = specializeFunction(f, args.data());

    // Debugging code for detecting some mis-specializations.
    // Requires #include "llvm/Analysis/Verifier.h"
    //errs() << "\nSpecializing " << f->getName() << "...\n";
    //errs() << "Verifying " << nfunc->getName() << "... ";
    //if (llvm::verifyFunction(*nfunc, llvm::ReturnStatusAction)) {
    //	errs() << "ok\n";
    //} else {
    //  errs() << "bad\n";
    //}

    return nfunc;
  }

  /*
   * Specialize a call site and return the new instruction
   */
  Instruction*
  specializeCallSite(Instruction* I,
      llvm::Function* nfunc, const std::vector<unsigned>& perm)
  {
    assert((nfunc->isVarArg() && nfunc->arg_size() <= perm.size())
        || (!nfunc->isVarArg() && nfunc->arg_size() == perm.size()));
    const size_t specialized_arg_count = perm.size(); //nfunc->arg_size();

    Instruction* newInst = NULL;
    if (CallInst* ci = dyn_cast<CallInst>(I)) {


      std::vector<Value*> newOperands;
      newOperands.reserve (specialized_arg_count);

      for (size_t j = 0; j < specialized_arg_count; ++j) {
        newOperands.push_back (ci->getArgOperand(perm[j]));
      }

      if (ci->hasName()) {
	newInst = CallInst::Create(nfunc, newOperands, ci->getName());
      } else {
	newInst = CallInst::Create(nfunc, newOperands);
      }
    } else if (InvokeInst* ci = dyn_cast<InvokeInst>(I)) {

      std::vector<Value*> newOperands;
      newOperands.reserve(specialized_arg_count);
      for (size_t j = 0; j < specialized_arg_count; ++j) {
        newOperands.push_back(ci->getArgOperand(perm[j]));
      }

      newInst = InvokeInst::Create(nfunc, ci->getNormalDest(),
				   ci->getUnwindDest(), newOperands, ci->getName());

    } else {
      assert(false && "specializeCallSite got non-callsite");
      return NULL; // Unreachable
    }

    return newInst;
  }


  bool checkAlias(Function * f, CallInst * ci, AAResults & AA){

      bool debug = false;
      if(debug) errs()<<"Checking Alias \n";

      for(unsigned int i = 0; i < ci->getNumOperands(); i++){
        Value * callArg = ci->getOperand(i);
        for(Function::arg_iterator itr = f->arg_begin(); itr != f->arg_end(); itr++, i++) {
          Value * funcArg = (Value*) &(*itr);
          if(!AA.isNoAlias(callArg, funcArg))
          {
             if(debug)
               errs()<<*callArg<<" and "<<*funcArg<<" may ALIAS **** \n";
             return true;
          }
        }
      }

      return false;
  }


  bool
  canSpecialize(Function* f, AAResults & AA)
  {
    if (f->isDeclaration())
      return false;

    bool canSpec = true;
    for (inst_iterator I = inst_begin(f), E = inst_end(f); I != E; ++I) {
      if (CallInst* ci = dyn_cast<CallInst>(&*I)) {
        if (ci->isInlineAsm()) {
          canSpec = canSpec & !checkAlias(f, ci, AA);
        }
      }
    }

    return canSpec;
  }

  GlobalVariable*
  materializeStringLiteral(llvm::Module& m, const char* data)
  {
    Constant* ary = llvm::ConstantDataArray::getString(m.getContext(), data, true);
    GlobalVariable* gv = new GlobalVariable(m, ary->getType(), true, GlobalValue::LinkageTypes::PrivateLinkage, ary, "");
    gv->setConstant(true);

    return gv;
  }

  Constant*
  charStarFromStringConstant(llvm::Module& m, llvm::Constant* v)
  {
    errs()<<"CHAR STAR \n\n\n\n\n" ;
    Constant* zero = ConstantInt::getSigned(IntegerType::getInt32Ty(m.getContext()), 0);
    Constant* args[2] = {zero, zero};
    ArrayRef<Constant*> ar_args(args, 2);
    Type * constantType = cast<PointerType>(v->getType()->getScalarType())
    ->getContainedType(0u);
    return ConstantExpr::getGetElementPtr(constantType, v, ar_args, false);
  }

}
