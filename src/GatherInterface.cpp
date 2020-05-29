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

#include "llvm/ADT/iterator_range.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "Interfaces.h"

#include "seadsa/InitializePasses.hh"
#include "seadsa/CompleteCallGraph.hh"

#include <fstream>
#include <set>
#include <string>
#include <vector>

#include "proto/Previrt.pb.h"

using namespace llvm;

static cl::opt<std::string> GatherInterfaceOutput(
    "Pinterface-output", cl::init(""), cl::Hidden,
    cl::desc("specifies the output file for the interface description"));

static cl::list<std::string> GatherInterfaceEntry(
    "Pinterface-entry", cl::Hidden,
    cl::desc("specifies the interface that is used (only function names)"));

// We should use always seadsa callgraph because it will be more
// precise. However, it might be slower to compute so that's why by
// default we use LLVM callgraph.
static cl::opt<bool> UseSeaDsa(
    "Pinterface-with-seadsa", 
    cl::desc("Use the callgraph computed by seadsa"),
    cl::init(false));

namespace previrt {

static bool isInternal(const Function *f) {
  if (f->isDeclaration() && !f->isIntrinsic()) {
    return false;
  } else {
    return true;
  }
}

static GlobalValue *getGlobal(Value *value) {
  if (GlobalValue *GV = dyn_cast<GlobalValue>(value)) {
    return GV;
  } else if (CastInst *CI = dyn_cast<CastInst>(value)) {
    if (Value *v = CI->getOperand(0)) {
      return getGlobal(v);
    }
  } else if (ConstantExpr *CE = dyn_cast<ConstantExpr>(value)) {
    return getGlobal(CE->getOperand(0));
  }

  return NULL;
}

static Value *stripBitCast(Value *V) {
  if (BitCastInst *BC = dyn_cast_or_null<BitCastInst>(V)) {
    return BC->getOperand(0);
  } else {
    return V;
  }
}

class GatherInterfacePass : public ModulePass {
public:
  ComponentInterface interface;
  static char ID;

public:
  GatherInterfacePass() : ModulePass(ID) {
    if (UseSeaDsa) {
      // Initialize sea-dsa pass
      llvm::PassRegistry &Registry = *llvm::PassRegistry::getPassRegistry();
      llvm::initializeCompleteCallGraphPass(Registry);
    }
  }

  virtual ~GatherInterfacePass() {}

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    if (UseSeaDsa) {
      AU.addRequired<seadsa::CompleteCallGraph>();
    } else {
      AU.addRequired<CallGraphWrapperPass>();
    }
    AU.setPreservesAll();
  }

  virtual bool runOnModule(Module &M) {
    /*
     * Compute an interface from M's call graph.
     * 
     * Keep in mind the following facts from a LLVM CallGraph:
     *
     * - Nodes in a CallGraph are functions plus two special nodes:
     *   CallGraph::getCallsExternalNode() and
     *   CallGraph::getExternalCallingNode. An edge from F1 to F2 if
     *   there is a **direct** callsite in F1 that calls F2.
     *
     * - If function F is not internal and its address can be taken
     *   then there is an edge from CallGraph::getExternalCallingNode
     *   to F
     * 
     * - If function F has an indirect call or external call then
     *   there is an edge from F to CallGraph::getCallsExternalNode()
     */
    
    CallGraph *cg = nullptr;
    if (UseSeaDsa) {
      cg = &getAnalysis<seadsa::CompleteCallGraph>().getCompleteCallGraph();      
    } else {
      cg = &getAnalysis<CallGraphWrapperPass>().getCallGraph();
    }

    errs() << "GatherInterfacePass::runOnModule: "
	   << M.getModuleIdentifier()
           << "\n";

    if (UseSeaDsa) {
      errs() << "#=========== SeaDsa CallGraph =========#\n";      
    } else {
      errs() << "#=========== LLVM CallGraph =========#\n";
    }
    cg->print(llvm::errs());

    // Add all nodes in llvm.compiler.used and llvm.used
    // *** This is very important for correctly compiling libc
    static const char *used_vars[2] = {"llvm.compiler.used", "llvm.used"};
    for (int i = 0; i < 2; ++i) {
      GlobalVariable *used = M.getGlobalVariable(used_vars[i], true);
      if (used) {
        Constant *value = used->getInitializer();
        assert(value);

        if (value->getType()->isVectorTy()) {
          for (unsigned int i = 0; i < value->getNumOperands(); ++i) {
            GlobalValue *gv = getGlobal(value->getAggregateElement(i));
            if (!gv || gv->hasInternalLinkage())
              continue;
            interface.reference(gv->getName());
            errs() << "adding reference to '" << gv->getName() << "'\n";
          }
          errs() << "vector!";
        } else if (ConstantArray *ary = dyn_cast<ConstantArray>(value)) {
          for (ConstantArray::op_iterator begin = ary->op_begin(),
                                          end = ary->op_end();
               begin != end; ++begin) {
            if (GlobalValue *gv = getGlobal(begin->get())) {
              interface.reference(gv->getName());
            }
          }
        } else {
          errs() << used_vars[i] << " = \n" << *value << "\n";
        }
      }
    }

    // Process the call graph
    std::vector<CallGraphNode *> worklist;

    // -- Initialize worklist with entry points of the current module
    if (!GatherInterfaceEntry.empty()) {
      ComponentInterface ci;
      for (auto interfaceName: GatherInterfaceEntry) {
        errs() << "Reading interface from '" << interfaceName << "'...";
        if (ci.readFromFile(interfaceName)) {
          errs() << "success\n";
        } else {
          errs() << "failed\n";
        }
      }
      for (auto FH: llvm::make_range(ci.begin(), ci.end())) {
        if (Function *f = M.getFunction(FH)) {
          worklist.push_back(cg->getOrInsertFunction(f));
        }
      }
    } else {
      worklist.push_back(cg->getExternalCallingNode());
    }

    std::set<CallGraphNode*> visited; // break cycles
    while (!worklist.empty()) {
      CallGraphNode *cgn = worklist.back();
      worklist.pop_back();

      if (cgn->getFunction() && !isInternal(cgn->getFunction())) {
        // this is a declaration and doesn't have any calls
        continue;
      }

      // if (cgn == cg->getCallsExternalNode()) {
      // 	// If we are here is because an external or indirect call
      // 	// call. Add all the entries of the call graph
      // 	// (CallGraph::getExternalCallingNode) in the worklist.
	
      //   cgn = cg->getExternalCallingNode();
      //   if (visited.find(cgn) != visited.end()) {
      //     continue;
      //   }
      // }

      // -- Process edges in the callgraph.
      // 
      // A callRecord is a pair of a (callsite, CallGraphNode). The
      // first element of the pair can be null when the source node is
      // getExternalCallingNode()
      for (auto &callRecord : *cgn) {
        Value *calledV = stripBitCast(callRecord.first);
        if (!calledV) {
          assert(cgn == cg->getExternalCallingNode());
	  if (isInternal(callRecord.second->getFunction())) {
	    // Entry point of the module
	    interface.callFrom(callRecord.second->getFunction());
	  }
        } else {
          CallSite CS(calledV);
          const Function *callee = callRecord.second->getFunction();
	  if (callee) {
	    // -- Direct call
	    if (!isInternal(callee)) {
	      errs() << "External call to "
		     << callRecord.second->getFunction()->getName() << "\n";
	      // Record a known external call
	      interface.callTo(callee->getName(), CS.arg_begin(), CS.arg_end());
	      continue;
	    }
	  } else {
	    // -- Indirect call: we don't know the callee
	  }
        }

        if (visited.insert(cgn).second) {
          worklist.push_back(callRecord.second);
        }
      }
    }

    // -- Record all external symbols of the current module
    
    // functions
    for (Function &F : llvm::make_range(M.begin(), M.end())) {
      if (F.isDeclaration() && !F.isIntrinsic()) {
        errs() << "Added reference to function " << F.getName() << "\n";
        interface.reference(F.getName());
      }
    }

    // global variables
    for (GlobalVariable &gv : M.globals()) {
      if (gv.isDeclaration()) {
        errs() << "Added reference to global " << gv.getName() << "\n";
        interface.reference(gv.getName());
      }
    }

    // aliases
    for (GlobalAlias &alias : M.aliases()) {
      if (alias.isDeclaration()) {
        errs() << "Added reference to alias " << alias.getName() << "\n";
        interface.reference(alias.getName());
      }
    }

    errs() << "Generated interface for " << M.getModuleIdentifier() << "\n";
    errs() << interface << "\n";
    
    if (GatherInterfaceOutput != "") {
      proto::ComponentInterface ci;
      codeInto<ComponentInterface, proto::ComponentInterface>(interface, ci);
      std::ofstream output(GatherInterfaceOutput.c_str(), std::ios::binary);
      assert(output.good());
      bool success = ci.SerializeToOstream(&output);
      if (!success) {
        errs() << "[GatherInterface] failed to write out interface\n";
        assert(false && "failed to write out interface");
      }
      output.close();
    }

    return false;
  }
};
char GatherInterfacePass::ID;

} // end namespace previrt

static RegisterPass<previrt::GatherInterfacePass>
    X("Pinterface",
      "Compute the interface for a LLVM module",
      false,
      false);
