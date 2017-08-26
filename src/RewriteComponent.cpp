//
// OCCAM
//
// Copyright (c) 2011-2016, SRI International
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
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CallSite.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "PrevirtualizeInterfaces.h"
#include "Specializer.h"
#include "ArgIterator.h"

#include <vector>
#include <string>
#include <stdio.h>

#define DUMP 1

using namespace llvm;

namespace previrt
{
  static Instruction*
  applyRewriteToCall(Module& M, const CallRewrite* const rw, CallSite cs)
  {
    Function* target = cs.getCalledFunction();
    assert(target != NULL);

    Function* newTarget = M.getFunction(rw->function);
    if (newTarget == NULL) {
      // There isn't a function, we need to construct it
      FunctionType* newType = target->getFunctionType();
      std::vector<Type*> argTypes;
      for (std::vector<unsigned>::const_iterator i = rw->args.begin(), e =
          rw->args.end(); i != e; ++i)
        argTypes.push_back(newType->getParamType(*i));
      ArrayRef<Type*> params(argTypes);
      newType = FunctionType::get(target->getReturnType(), params, target->isVarArg());

      newTarget = dyn_cast<Function> (M.getOrInsertFunction(rw->function,
          newType));
    }

    assert(newTarget != NULL);

    return specializeCallSite(cs.getInstruction(), newTarget, rw->args);
  }
  
  bool
  TransformComponentWithUse(Module& M, ComponentInterfaceTransform& T)
  {
    bool modified = false;
    for (ComponentInterfaceTransform::FMap::const_iterator i = T.rewrites.begin(), e = T.rewrites.end(); i != e; ++i) {

      errs() << "Looking for calls to " << i->first << "\n";
      
      Function* f = M.getFunction(i->first);
      if (f == NULL) continue;

      for (Function::use_iterator ui = f->use_begin(), ue = f->use_end(); ui != ue; ++ui) {
	Use* use = &(*ui);
	User* user = ui->getUser();

        if (isa<CallInst>(user) ||  isa<InvokeInst>(user)) { 
	
	  // The instruction is a call site
	  CallSite cs(cast<Instruction>(user));
	  
	  // If we are not the callee we should bail
	  if(!cs.isCallee(use)){ continue; }
	  
	  const CallRewrite* const rw = T.lookupRewrite(i->first, cs.arg_begin(), cs.arg_end());
	  if (rw == NULL){ continue; }
	  
          #if DUMP
	  BasicBlock* owner = cs.getInstruction()->getParent();
	  errs() << "Specializing (inter-module) call to '" << cs.getCalledFunction()->getName()
		 << "' in function '" << (owner == NULL ? "??" : owner->getParent()->getName())
		 << "' on arguments [";
	  for (unsigned int i = 0, cnt = 0; i < cs.arg_size(); ++i) {
	    if (std::find(rw->args.begin(), rw->args.end(), i) == rw->args.end()) {
	      if (cnt++ != 0)
		errs() << ",";
	      if (Function* funptr = dyn_cast<Function> (cs.getArgument(i)))
		errs() << i << "=(" << "&" << funptr->getName () << ")";
	      else
		errs() << i << "=(" << *cs.getArgument(i) << ")";
	    }
	  }
	  errs() << "]\n";
          #endif
	  
	  if (cs.getCalledFunction () && cs.getCalledFunction ()->hasExternalLinkage()) {
	    for (unsigned int i = 0; i < cs.arg_size(); ++i) {
	      if (std::find(rw->args.begin(), rw->args.end(), i) == rw->args.end()) {
		if (Function* funptr = dyn_cast<Function> (cs.getArgument(i))) {
		  // XXX: we are specializing a callsite that has an
		  // argument with the address of a function
		  // foo. After the specialization, foo may be dead in
		  // the current module but it might be called in
		  // another module.  This code ensures that foo will
		  // not be remove from the current module, otherwise
		  // the linker will complain.
		  funptr->setLinkage(GlobalValue::ExternalLinkage);
		  llvm::errs () << "Marking " << funptr->getName () << "  as external.\n";
		}
	      }
	    }
	  }

	  Instruction* newInst = applyRewriteToCall(M, rw, cs);
	  llvm::ReplaceInstWithInst(cs.getInstruction(), newInst);
	  modified = true;
	}
      }
    }

    return modified;
  }

  /*
   * Rewrite the given module according to the ComponentInterfaceTransformer.
   */
  bool
  TransformComponentWithoutUse(Module& M, ComponentInterfaceTransform& T)
  {
    assert(T.interface != NULL);
    bool modified = false;
    for (Module::iterator f = M.begin(), e = M.end(); f != e; ++f) {
      for (Function::iterator bb = f->begin(), bbe = f->end(); bb != bbe; ++bb) {
        for (BasicBlock::iterator I = bb->begin(), E = bb->end(); I != E; ++I) {
          // TODO: Handle the operands


          CallSite call;
          if (CallInst* ci = dyn_cast<CallInst>(&*I)) {
            if (ci->isInlineAsm())
              continue;
            call = CallSite(ci);
          } else if (InvokeInst* ci = dyn_cast<InvokeInst>(&*I)) {
            call = CallSite(ci);
          } else {
            // TODO: We need to find all references, including ones stored in variables
            //       we'll be conservative and say that if it is stored in a variable then
            //       we can't optimize it at all
            continue;
          }

          Function* target = call.getCalledFunction();
          if (target == NULL || !target->isDeclaration()) {
            continue;
          }

          //iam          const CallRewrite* const rw = T.lookupRewrite(target->getNameStr(), call.arg_begin(), call.arg_end());
          const CallRewrite* const rw = T.lookupRewrite(target->getName().str(), call.arg_begin(), call.arg_end());

          if (rw == NULL) {
            // There is no rewrite for this function
            continue;
          }

          // Get/Create the function
          Function* newTarget = M.getFunction(rw->function);
          if (newTarget == NULL) {
            // There isn't a function, we need to construct it
            FunctionType* newType = target->getFunctionType();
            std::vector<Type*> argTypes;
            for (std::vector<unsigned>::const_iterator i = rw->args.begin(), e =
                rw->args.end(); i != e; ++i)
              argTypes.push_back(newType->getParamType(*i));
            ArrayRef<Type*> params(argTypes);
            newType = FunctionType::get(target->getReturnType(), params, target->isVarArg());

            newTarget = dyn_cast<Function> (M.getOrInsertFunction(rw->function,
                newType));
          }

          assert(newTarget != NULL);

          Instruction* newInst = specializeCallSite(I, newTarget, rw->args);
          llvm::ReplaceInstWithInst(bb->getInstList(), I, newInst);
          modified = true;
        }
      }
    }
    return modified;
  }

  bool
  TransformComponent(Module& M, ComponentInterfaceTransform& T)
  {
    return TransformComponentWithUse(M, T);
  }


  static cl::list<std::string> RewriteComponentInput("Prewrite-input",
      cl::NotHidden, cl::desc(
          "specifies the interface to rewrite using"));

  class RewriteComponentPass : public ModulePass
  {
  public:
    ComponentInterfaceTransform transform;
    static char ID;
    
  public:
    RewriteComponentPass() :
      ModulePass(ID), transform()
    {

      errs() << "RewriteComponentPass()\n";

      for (cl::list<std::string>::const_iterator b = RewriteComponentInput.begin(), e = RewriteComponentInput.end();
           b != e; ++b) {
        errs() << "Reading file '" << *b << "'...";
        if (transform.readTransformFromFile(*b)) {
          errs() << "success\n";
        } else {
          errs() << "failed\n";
        }
      }

      transform.dump();

      errs() << "Done reading (" << transform.rewriteCount() << " rewrites)\n";
    }
    virtual
    ~RewriteComponentPass()
    {
    }
  public:
    virtual bool
    runOnModule(Module& M)
    {
      if (this->transform.interface == NULL) {
        return false;
      }
      
      errs() << "RewriteComponentPass:runOnModule: " << M.getModuleIdentifier() << "\n";


      bool modified = TransformComponent(M, this->transform);
      if (modified) {
        errs() << "...progress...\n";
      } else {
        errs() << "...no progress...\n";
      }
      return modified;
    }
  };
  char RewriteComponentPass::ID;

  static RegisterPass<RewriteComponentPass> X("Prewrite",
      "previrtualize the given module (requires parameters)", false, false);

}
