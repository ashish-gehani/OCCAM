//===- CallGraph.cpp - Build a Module's call graph ------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the CallGraph class and provides the BasicCallGraph
// default implementation.
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/CallGraph.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/CallSite.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

#include <map>

using namespace llvm;

namespace llvm {
  void initializeAACallGraphPass(PassRegistry&);
  void initializeCallGraphWrapperPassAnalysisGroup(PassRegistry&);
}

namespace {

//===----------------------------------------------------------------------===//
// AACallGraph class definition
//
class AACallGraph : public CallGraphWrapperPass {

public:
  static char ID; // Class identification, replacement for typeinfo
  AACallGraph() {
      initializeAACallGraphPass(*PassRegistry::getPassRegistry());
    }

  // runOnModule - Compute the call graph for the specified module.
  virtual bool runOnModule(Module &M) {
    CallGraphWrapperPass::runOnModule(M);
    return false;
  }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
  }

  virtual void print(raw_ostream &OS, const Module *) const override {
    CallGraphWrapperPass::print(OS, 0);
  }

  virtual void releaseMemory() {
    CallGraphWrapperPass::releaseMemory();
  }

private:

};

} //End anonymous namespace

INITIALIZE_AG_PASS(AACallGraph, CallGraphWrapperPass, "aliascg",
                   "Alias Analysis CallGraph Construction", false, true, true)

char AACallGraph::ID = 0;

// Enuse that users of CallGraph.h also link with this file
//DEFINING_FILE_FOR(AACallGraph)
