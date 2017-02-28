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
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/User.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Pass.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/CallSite.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/CallGraph.h"

#include "PrevirtualizeInterfaces.h"
#include "ArgIterator.h"

#include <vector>
#include <set>
#include <list>
#include <queue>
#include <string>
#include <stdio.h>
#include <fstream>

#include "proto/Previrt.pb.h"

using namespace llvm;

namespace previrt
{
  // Internal functions are functions with bodies, i.e. not "declarations"
  // all intrinsics have "bodies" since the compiler gives them meaning
  static bool
  isInternal(Function* target)
  {
    assert(target != NULL);
    if (target->isDeclaration() && !target->isIntrinsic())
      return false;
    return true;
  }

#if 0
  static bool
  canCall(FunctionType* ft, Type* ret, Use* i, Use* e)
  {
    if (ret != ft->getReturnType()) return false;

    unsigned int idx = 0;
    while (i != e) {
      if (idx >= ft->getNumParams()) {
        if (ft->isVarArg()) {
          return true;
        } else {
          // Too many parameters
          return false;
        }
      }

      Type* t = ft->getParamType(idx);
      if (t != i->get()->getType()) {
        return false;
      }
      idx++;
    }
    return idx == ft->getNumParams();
  }

  // This is a sketch of a new implementation of GatherInterface that uses CallGraph
  // the benefit of using CallGraph is that we can (in theory) hook into alias analysis
  // and other passes that refine indirect function calls (an attempt at this is AACallGraph.cpp)
  void
  GatherInterface2(const CallGraph& cg, ComponentInterface& I, std::list<Function*>* roots = NULL)
  {
    std::queue<const std::pair<WeakVH,CallGraphNode*>* > queue;
    std::set<Value*> visited_or_pending;

    if (roots == NULL) {
      const CallGraphNode* cgn = cg.getRoot();
      for (CallGraphNode::const_iterator ii = cgn->begin(), ee = cgn->end(); ii != ee; ++ii) {
        queue.push(&*ii);
      }
    } else {
      for (std::list<Function*>::const_iterator i = roots->begin(), e = roots->end(); i != e; ++i) {
        const CallGraphNode* cgn = cg[*i];
        for (CallGraphNode::const_iterator ii = cgn->begin(), ee = cgn->end(); ii != ee; ++ii) {
          if (visited_or_pending.find((Value*)ii->first) == visited_or_pending.end()) {
            queue.push(&*ii);
            visited_or_pending.insert((Value*)ii->first);
          }
        }
      }
    }

    // TODO this isn't good enough because if we're hitting the CallsExternal
    //      node then we actually need to go back to the ExternalCalling node
    while (!queue.empty()) {
      const std::pair<WeakVH,CallGraphNode*>& call_site = *queue.front();
      queue.pop();

      // cgn is the target of the call
      const CallGraphNode* cgn = call_site.second;
      // instr is the source of the call
      Value* instr = (Value*)call_site.first;

      if (cgn->getFunction() != NULL && !isInternal(cgn->getFunction())) {
        // External functions are not traversed for the interface,
        // they are taken care of by other modules.
        // Just mark it as being called and continue
        if ((isa<CallInst>(instr) || isa<InvokeInst>(instr)) &&
            CallSite(instr).getCalledFunction() == cgn->getFunction()) {
          // Add a call for this callsite
          CallSite cs(instr);
          I.call(cs.getCalledFunction()->getName(), cs.arg_begin(), cs.arg_end());
        } else {
          I.callAny(cgn->getFunction());
        }

        continue;
      }

      // Add the target functions to the queue
      for (CallGraphNode::const_iterator i = cgn->begin(), e = cgn->end(); i != e; ++i) {
        if (visited_or_pending.find((Value*)i->first) == visited_or_pending.end()) {
          queue.push(&*i);
        }
      }
    }


#if 0
    // Compute the calls set
    if (!GatherInterfaceMain.empty()) {
      checked = true;
      for (cl::list<std::string>::const_iterator i = GatherInterfaceMain.begin(), e = GatherInterfaceMain.end(); i != e; ++i) {
        Function* f = M.getFunction(*i);
        if (f != NULL) {
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
        Function* f = M.getFunction(i->first());
        if (f == NULL) continue;
        queue.push(cg.getOrInsertFunction(f));
      }
    }

    if (!checked) {
      queue.push(cg.getExternalCallingNode());
    }

    std::set<CallGraphNode*> visited;

/*      errs() << "calls external...\n";
    cg.getCallsExternalNode()->print(errs());

    errs() << "external calls...\n";
    cg.getExternalCallingNode()->print(errs());*/

    while (!queue.empty()) {
      CallGraphNode* cgn = queue.front();
      queue.pop();

      if (cgn->getFunction() != NULL && !isInternal(cgn->getFunction())) {
        //errs() << "skipping...\n";
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
        // TODO We should be able to prune based on function type!
        cgn = cg.getExternalCallingNode();
        if (visited.find(cgn) != visited.end()) {
          continue;
        }
      }

      for (CallGraphNode::const_iterator i = cgn->begin(), e = cgn->end(); i != e; ++i) {
        Value* instr = (Value*)i->first;
        /*errs() << "considering....\n";
        instr->dump();*/

        if (instr == NULL) {
          assert (i->second->getFunction() != NULL);
          this->interface.callAny(i->second->getFunction());
        } else {

          CallSite cs;
          if (CallInst* ci = dyn_cast<CallInst>(instr)) {
            cs = CallSite(ci);
          } else if (InvokeInst* ii = dyn_cast<InvokeInst>(instr)) {
            cs = CallSite(ii);
          } else {
            assert (false && "call from non-call instruction");
          }

          Function* called = i->second->getFunction();
          //errs() << "Called = " << called << "\n";
          if (called != NULL && !isInternal(called)) {
            //errs() << called->getName() << "\n";
            this->interface.call(called->getName(), cs.arg_begin(), cs.arg_end());
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
      assert(ci.SerializeToOstream(&output));
      output.close();
    }

    return false;
#endif
  }
#endif

#if 0
  // Testing/exploration code
  static void
  dfs(CallGraphNode* cgn, std::set<Function*>& visited, Twine indent)
  {
    if (cgn->getFunction() == NULL) {
      errs() << indent << "< ??? >\n";
    } else if (cgn->getFunction()->isDeclaration()) {
      errs() << indent << cgn->getFunction()->getName() << " -- external\n";
      return;
    } else {
      errs() << indent << cgn->getFunction()->getName() << "\n";
    }
    for (CallGraphNode::const_iterator i = cgn->begin(), e = cgn->end(); i != e; ++i) {
      Function* f = i->second->getFunction();

      if (visited.find(f) == visited.end()) {
        visited.insert(f);
        dfs(i->second, visited, indent + "> ");
        //visited.erase(f);
      }
    }
  }
#endif

  /*
   * TODO this function should be able to go under casts!
   */
  static GlobalValue*
  getGlobal(Value* value)
  {
    assert(value != NULL);

    if (isa<GlobalValue>(value)) {
      return dyn_cast<GlobalValue>(value);
    } else if (CastInst* ci = dyn_cast<CastInst>(value)) {
      Value* v = ci->getOperand(0);
      assert (v != NULL);
      return getGlobal(v);
    } else if (ConstantExpr* cnst = dyn_cast<ConstantExpr>(value)) {
      return getGlobal(cnst->getOperand(0));
    }
    return NULL;
  }


  static cl::opt<std::string> GatherInterfaceOutput("Pinterface2-output",
      cl::init(""), cl::Hidden, cl::desc(
          "specifies the output file for the interface description"));
  static cl::list<std::string> GatherInterfaceMain("Pinterface2-function",
        cl::Hidden, cl::desc(
            "specifies the function that is called"));
  static cl::list<std::string> GatherInterfaceEntry("Pinterface2-entry",
        cl::Hidden, cl::desc(
            "specifies the interface that is used (only function names)"));
  class GatherInterface2Pass : public ModulePass
  {
  public:
    ComponentInterface interface;
    static char ID;
    
  public:
    GatherInterface2Pass() :
      ModulePass(ID)
    {
    }
    virtual
    ~GatherInterface2Pass()
    {
    }
  public:
    virtual void
    getAnalysisUsage(AnalysisUsage &Info) const
    {
      Info.addRequired<CallGraphWrapperPass> ();
      Info.addRequiredTransitive<AAResultsWrapperPass>();
      Info.setPreservesAll();
    }
    virtual bool
    runOnModule(Module& M)
    {
      CallGraphWrapperPass& cg = this->getAnalysis<CallGraphWrapperPass> ();

      bool checked = false;

      errs() << "GatherInterface2Pass::runOnModule: " << M.getModuleIdentifier() << "\n";
      
      // Add all nodes in llvm.compiler.used and llvm.used
      // *** This is very important for correctly compiling libc
      static const char* used_vars[2] = {"llvm.compiler.used", "llvm.used"};
      for (int i = 0; i < 2; ++i) {
        GlobalVariable* used = M.getGlobalVariable(used_vars[i], true);
        if (used != NULL) {
          Constant* value = used->getInitializer();
          assert(value != NULL);

	  
          if (value->getType()->isVectorTy()) {
// GM:            SmallVectorImpl<Constant*> elems(64);
//            SmallVector<Constant*, 64> elems; // IAM, AG
//            value->getVectorElements(elems);
//            for (SmallVectorImpl<Constant*>::const_iterator i = elems.begin(), e = elems.end(); i != e; ++i) {
	    for (unsigned int i=0; i < value->getNumOperands(); ++i) {
	      //              GlobalValue* gv = getGlobal(*i);
	      GlobalValue* gv = getGlobal(value->getAggregateElement(i));
              if (gv == NULL || gv->hasInternalLinkage()) continue;
              this->interface.reference(gv->getName());
              errs() << "adding reference to '" << gv->getName() << "'\n";
            }
            errs() << "vector!";
          } else if (ConstantArray* ary = dyn_cast<ConstantArray>(value)) {
            for (ConstantArray::op_iterator begin = ary->op_begin(), end = ary->op_end(); begin != end; ++begin) {
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
      std::queue<CallGraphNode*> queue;

      // Compute the calls set
      if (!GatherInterfaceMain.empty()) {
        checked = true;
        for (cl::list<std::string>::const_iterator i = GatherInterfaceMain.begin(), e = GatherInterfaceMain.end(); i != e; ++i) {
          Function* f = M.getFunction(*i);
          if (f != NULL) {
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
          Function* f = M.getFunction(i->first());
          if (f == NULL) continue;
          queue.push(cg.getOrInsertFunction(f));
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

        if (cgn->getFunction() != NULL && !isInternal(cgn->getFunction())) {
          // this is a declaration and doesn't have any calls
          //errs() << "skipping...\n";
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
          if (instr == NULL) {
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
            if (called != NULL && !isInternal(called)) {
              this->interface.call(called->getName(), cs.arg_begin(), cs.arg_end());
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
	assert(success && "failed to write out interface");
        output.close();
      }

      return false;
    }
  };
  char GatherInterface2Pass::ID;

  static RegisterPass<GatherInterface2Pass> X("Pinterface2",
      "compute the external dependencies of the module.", false, false);
}
