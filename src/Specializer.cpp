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
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/ValueMap.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"

#include "llvm/ADT/ArrayRef.h"

#include "InterfaceTypes.h"
#include "Specializer.h"

#include <fstream>

using namespace llvm;

namespace previrt {
std::string specializeName(Function *f, std::vector<std::string> &args) {
  assert(f->hasName());

  args.clear();
  std::string fn = f->getName().str();

  int idx = fn.find('(');
  if (idx != -1 && fn[fn.length() - 1] == ')') {
    std::string base = fn.substr(0, idx);
    idx++;
    unsigned int st = idx;
    bool in_str = false;
    while (st < fn.length() - 1) {
      idx = st;
      while (true) {
        if (fn[idx] == '"') {
          in_str = !in_str;
        } else if (!in_str) {
          if (fn[idx] == ',') {
            args.push_back(fn.substr(st, idx - st));
            break;
          } else if (fn[idx] == ')') {
            args.push_back(fn.substr(st, idx - st));
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
    for (unsigned int i = 0; i < alen; ++i) {
      args.push_back("?");
    }
    return "__occam_spec." + f->getName().str();
  }
}

/*
 * f is the original function
 * 
 * args is vector of NULL's elements or some LLVM constants. If
 * args[i] is not null then the i-th argument of the new function
 * will be replaced with args[i].
*/  
Function *specializeFunction(Function *f, const std::vector<Value *> &args) {
  assert(!f->isDeclaration());

  if (!f->hasName()) {
    // XXX: this is a unnecessary restriction but it should never
    // happen becase we enforce that all functions are named before
    // specialization.
    return nullptr;
  }

  ValueToValueMapTy vmap;
  unsigned int i = 0;
  unsigned int j = 0;
  std::vector<std::string> argNames;
  std::string baseName = specializeName(f, argNames);
  for (Function::arg_iterator it = f->arg_begin(); it != f->arg_end();
       it++, i++) {
    while (argNames[j] != "?") {
      j++;
      if (j >= argNames.size()) {
	// HOTFIX: running out-of-bounds is possible here. Not sure if
	// we can do something better than giving up.
	return nullptr;
      }
    }

    if (args[i]) {
      Value *arg = (Value *)&(*it);
      assert(arg->getType() == args[i]->getType() &&
             "Specializing argument with concrete value of wrong type!");
      vmap.insert(typename ValueToValueMapTy::value_type(arg, args[i]));
      InterfaceType pt = InterfaceType::abstract(args[i]);
      argNames[j] = pt.to_string();
    }
    j++;
  }
  assert(i == f->arg_size());

  baseName += "(";
  for (auto it=argNames.begin(), et=argNames.end();it!=et;) {
    baseName += *it;
    ++it;
    if (it!=et) {
      baseName += ",";
    }
  }
  baseName += ")";

  
  Function *result = f->getParent()->getFunction(baseName);
  if (!result) {
    ClonedCodeInfo info;
    result = llvm::CloneFunction(f, vmap, &info);
    result->setName(baseName);
  } else {
    // If specialized function already exists, no reason
    // to create another one. In fact, can cause the process
    // to diverge.

    //// 
    // Sanity check
    ////
    unsigned num_args_specialized_function = 0;
    for(unsigned i=0; i < args.size(); ++i) {
      if (!args[i]) num_args_specialized_function++;
    }
    if (result->arg_size() != num_args_specialized_function) {
      // HOTFIX: we found another function with the same name but
      // different number of arguments. This shouldn't happen because
      // the name of the specialized function has encoded the number
      // of unspecialized functions (by having ? symbols)
      return nullptr;
    }
  }
  
  return result;
}

/*
 * Specialize a call site and return the new instruction.
 */
Instruction *specializeCallSite(Instruction *I, llvm::Function *nfunc,
                                const std::vector<unsigned> &perm) {

  assert((nfunc->isVarArg() && nfunc->arg_size() <= perm.size()) ||
         (!nfunc->isVarArg() && nfunc->arg_size() == perm.size()));

  const size_t specialized_arg_count = perm.size(); // nfunc->arg_size();

  Instruction *newInst = nullptr;
  if (CallInst *ci = dyn_cast<CallInst>(I)) {
    std::vector<Value *> newOperands;
    newOperands.reserve(specialized_arg_count);

    for (size_t j = 0; j < specialized_arg_count; ++j) {
      newOperands.push_back(ci->getArgOperand(perm[j]));
    }

    if (ci->hasName()) {
      newInst = CallInst::Create(nfunc, newOperands, ci->getName());
    } else {
      newInst = CallInst::Create(nfunc, newOperands);
    }
    dyn_cast<CallInst>(newInst)->setTailCallKind(ci->getTailCallKind());

  } else if (InvokeInst *ci = dyn_cast<InvokeInst>(I)) {
    std::vector<Value *> newOperands;
    newOperands.reserve(specialized_arg_count);
    for (size_t j = 0; j < specialized_arg_count; ++j) {
      newOperands.push_back(ci->getArgOperand(perm[j]));
    }
    if (ci->hasName()) {
      newInst =
          InvokeInst::Create(nfunc, ci->getNormalDest(), ci->getUnwindDest(),
                             newOperands, ci->getName());
    } else {
      newInst = InvokeInst::Create(nfunc, ci->getNormalDest(),
                                   ci->getUnwindDest(), newOperands);
    }
  } else {
    assert(false && "specializeCallSite got non-callsite");
    return nullptr; // Unreachable
  }
  CallSite NewCS = CallSite(newInst);
  NewCS.setCallingConv(nfunc->getCallingConv());
  return newInst;
}

  GlobalVariable *materializeStringLiteral(llvm::Module &m, const char *data,
					   bool isConstant) {
  Constant *initializer =
      llvm::ConstantDataArray::getString(m.getContext(), data, true);
  GlobalVariable *gv =
      new GlobalVariable(m, initializer->getType(), isConstant,
                         GlobalValue::LinkageTypes::PrivateLinkage,
			 initializer);
  return gv;
}

Constant *charStarFromStringConstant(llvm::Module &m, llvm::Constant *v) {
  Constant *zero =
      ConstantInt::getSigned(IntegerType::getInt32Ty(m.getContext()), 0);
  Constant *args[2] = {zero, zero};
  ArrayRef<Constant *> ar_args(args, 2);
  Type *constantType =
      cast<PointerType>(v->getType()->getScalarType())->getContainedType(0u);
  return ConstantExpr::getGetElementPtr(constantType, v, ar_args, false);
}
}
