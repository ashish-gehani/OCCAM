//
// OCCAM
//
// Copyright (c) 2011-2018, SRI International
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

//#include "llvm/ADT/StringMap.h"
//#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Constants.h"
//#include "llvm/IR/User.h"
//#include "llvm/IR/InstVisitor.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Pass.h"
//#include "llvm/Transforms/IPO.h"
//#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/CallSite.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Analysis/CallGraph.h"

#include "PrevirtualizeInterfaces.h"

#include <vector>
#include <set>
#include <queue>
#include <string>
#include <fstream>

#include "proto/Previrt.pb.h"

using namespace llvm;

static cl::opt<std::string>
GatherInterfaceOutput("Pinterface-output",
		      cl::init(""),
		      cl::Hidden,
		      cl::desc("specifies the output file for the interface description"));

static cl::list<std::string>
GatherInterfaceMain("Pinterface-function",
		    cl::Hidden,
		    cl::desc("specifies the function that is called"));
			     
static cl::list<std::string>
GatherInterfaceEntry("Pinterface-entry",
		     cl::Hidden,
		     cl::desc("specifies the interface that is used (only function names)"));

namespace previrt
{

  static bool isInternal(Function* f) {
    if (f->isDeclaration() && !f->isIntrinsic())
      return false;
    return true;
  }

  static GlobalValue* getGlobal(Value* value) {
    if (GlobalValue* GV = dyn_cast<GlobalValue>(value)) {
      return GV;
    } else if (CastInst* CI = dyn_cast<CastInst>(value)) {
      if (Value* v = CI->getOperand(0)) {
	return getGlobal(v);
      }
    } else if (ConstantExpr* CE = dyn_cast<ConstantExpr>(value)) {
      return getGlobal(CE->getOperand(0));
    }
    
    return NULL;
  }


  class GatherInterfacePass : public ModulePass {
  public:
    ComponentInterface interface;
    static char ID;
    
  public:
    GatherInterfacePass(): ModulePass(ID) {}
      
    virtual ~GatherInterfacePass() {}
    
    virtual void getAnalysisUsage(AnalysisUsage &AU) const {
      AU.addRequired<CallGraphWrapperPass> ();
      AU.setPreservesAll();
    }
    
    virtual bool runOnModule(Module& M) {
      CallGraphWrapperPass& cg = this->getAnalysis<CallGraphWrapperPass>();

      bool checked = false;
      errs() << "GatherInterfacePass::runOnModule: " << M.getModuleIdentifier() << "\n";
      
      // Add all nodes in llvm.compiler.used and llvm.used
      // *** This is very important for correctly compiling libc
      static const char* used_vars[2] = {"llvm.compiler.used", "llvm.used"};
      for (int i = 0; i < 2; ++i) {
        GlobalVariable* used = M.getGlobalVariable(used_vars[i], true);
        if (used) {
          Constant* value = used->getInitializer();
          assert(value);

          if (value->getType()->isVectorTy()) {
	    for (unsigned int i=0; i < value->getNumOperands(); ++i) {
	      GlobalValue* gv = getGlobal(value->getAggregateElement(i));
              if (!gv || gv->hasInternalLinkage()) continue;
              this->interface.reference(gv->getName());
              errs() << "adding reference to '" << gv->getName() << "'\n";
            }
            errs() << "vector!";
          } else if (ConstantArray* ary = dyn_cast<ConstantArray>(value)) {
            for (ConstantArray::op_iterator begin = ary->op_begin(), end = ary->op_end();
		 begin != end; ++begin) {
              if (GlobalValue* gv = getGlobal(begin->get())) {
                this->interface.reference(gv->getName());
              }
            }
          } else {
            errs() << used_vars[i] << " = \n" << *value << "\n";
          }
        }
      }

      // Traverse the call graph
      // XXX: replace queue with vector if FIFO ordering does not matter.
      std::queue<CallGraphNode*> queue;

      // Compute the calls set
      if (!GatherInterfaceMain.empty()) {
        checked = true;
        for (cl::list<std::string>::const_iterator i = GatherInterfaceMain.begin(), e = GatherInterfaceMain.end();
	     i != e; ++i) {
          if (Function* f = M.getFunction(*i)) {
            queue.push(cg.getOrInsertFunction(f));
          } else {
            assert(false && "got null");
          }
        }
      }
      
      if (!GatherInterfaceEntry.empty()) {
        checked = true;
        ComponentInterface ci;
        for (cl::list<std::string>::const_iterator i = GatherInterfaceEntry.begin(), e = GatherInterfaceEntry.end();
              i != e; ++i) {
          errs() << "Reading interface from '" << *i << "'...";
          if (ci.readFromFile(*i)) {
            errs() << "success\n";
          } else {
            errs() << "failed\n";
          }
        }
	
        for (ComponentInterface::FunctionIterator i = ci.begin(), e = ci.end(); i != e; ++i) {
          if (Function* f = M.getFunction(i->first())) {
	    queue.push(cg.getOrInsertFunction(f));
	  }
        }
      }

      // Only check the external calling node once
      if (!checked) {
        queue.push(cg.getExternalCallingNode());
      }

      std::set<CallGraphNode*> visited;
      while (!queue.empty()) {
        CallGraphNode* cgn = queue.front();
        queue.pop();

        if (cgn->getFunction() && !isInternal(cgn->getFunction())) {
          // this is a declaration and doesn't have any calls
          continue;
        }

        if (cgn == cg.getCallsExternalNode()) {
          // In this case, we're here from a call that we can't resolve,
          // so we need to be conservative.
          // Everything that could have made it into this set is in the
          // "External Calling" node, i.e. can be called externally
          // - stored in a variable or externally visible
          // NOTE: for this to be useful, we're going to need to minimize
          // the size of the "externally visible" set.
          cgn = cg.getExternalCallingNode();
          if (visited.find(cgn) != visited.end()) {
            continue;
          }
        }

        for (CallGraphNode::const_iterator i = cgn->begin(), e = cgn->end(); i != e; ++i) {
          Value* instr = (Value*)i->first;
          if (!instr) {
            assert (i->second->getFunction() != NULL);
            this->interface.callAny(i->second->getFunction());
          } else {
            CallSite cs;
            if (CallInst* ci = dyn_cast<CallInst>(instr)) {
              cs = CallSite(ci);
            } else if (InvokeInst* ii = dyn_cast<InvokeInst>(instr)) {
              cs = CallSite(ii);
            } else {
              // Probably not true
              //this->interface.callAny(i->second->getFunction());
              assert (false && "call from non-call instruction");
            }

            Function* called = i->second->getFunction();
            if (called && !isInternal(called)) {
              interface.call(called->getName(), cs.arg_begin(), cs.arg_end());
              continue;
            }
          }

          if (visited.find(cgn) == visited.end()) {
            visited.insert(cgn);
            queue.push(i->second);
            //errs() << "adding...\n";
          }
        }
      }

      // A little bit simpler, compute the references set
      for (Module::const_iterator i = M.begin(), e = M.end(); i != e; ++i) {
        if (i->isDeclaration()) {
          this->interface.reference(i->getName());
        }
      }
      
      for (Module::global_iterator i = M.global_begin(), e = M.global_end(); i != e; ++i) {
        if (i->isDeclaration()) {
          this->interface.reference(i->getName());
        }
      }

      if (GatherInterfaceOutput != "") {
        proto::ComponentInterface ci;
        codeInto<ComponentInterface, proto::ComponentInterface> (
            this->interface, ci);
        std::ofstream output(GatherInterfaceOutput.c_str(), std::ios::binary);
	assert(output.good());
        bool success = ci.SerializeToOstream(&output);
	if (!success)
	  assert(false && "failed to write out interface");
        output.close();
      }

      return false;
    }
  };
  char GatherInterfacePass::ID;

} // end namespace previrt

static RegisterPass<previrt::GatherInterfacePass>
X("Pinterface",
  "compute the external dependencies of the module",
  false, false);

