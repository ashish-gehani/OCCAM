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
#include "llvm/Module.h"
#include "llvm/Instructions.h"
#include "llvm/IntrinsicInst.h"
#include "llvm/Support/CallSite.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

#include <map>

using namespace llvm;

namespace llvm {
  void initializeAACallGraphPass(PassRegistry&);
}

namespace std {
  template<>
  struct less<AliasAnalysis::Location>
  {
     bool
     operator()(const AliasAnalysis::Location& loc1, const AliasAnalysis::Location& loc2) const
     {
        return loc1.Ptr < loc2.Ptr || (loc1.Ptr == loc2.Ptr && loc1.Size < loc2.Size);
     }
  };
}

namespace {

//===----------------------------------------------------------------------===//
// AACallGraph class definition
//
class AACallGraph : public ModulePass, public CallGraph {
  // Root is root of the call graph, or the external node if a 'main' function
  // couldn't be found.
  //
  CallGraphNode *Root;

  // ExternalCallingNode - This node has edges to all external functions and
  // those internal functions that have their address taken.
  CallGraphNode *ExternalCallingNode;

  // CallsExternalNode - This node has edges to it from all functions making
  // indirect calls or calling an external function.
  CallGraphNode *CallsExternalNode;

  // locationNodes - One node for each location that the alias analysis can
  // distinguish
  std::map<AliasAnalysis::Location, CallGraphNode*> locationNodes;

public:
  static char ID; // Class identification, replacement for typeinfo
  AACallGraph() : ModulePass(ID), Root(0),
    ExternalCallingNode(0), CallsExternalNode(0) {
      initializeAACallGraphPass(*PassRegistry::getPassRegistry());
    }

  // runOnModule - Compute the call graph for the specified module.
  virtual bool runOnModule(Module &M) {
    CallGraph::initialize(M);

    ExternalCallingNode = getOrInsertFunction(0);
    CallsExternalNode = new CallGraphNode(0);
    Root = 0;

    // Add every function to the call graph.
    for (Module::iterator I = M.begin(), E = M.end(); I != E; ++I)
      addToCallGraph(I);

    // If we didn't find a main function, use the external call graph node
    if (Root == 0) Root = ExternalCallingNode;

    return false;
  }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
  }

  virtual void print(raw_ostream &OS, const Module *) const {
    OS << "CallGraph Root is: ";
    if (Function *F = getRoot()->getFunction())
      OS << F->getName() << "\n";
    else {
      OS << "<<null function: 0x" << getRoot() << ">>\n";
    }

    CallGraph::print(OS, 0);
  }

  virtual void releaseMemory() {
    destroy();
  }

  /// getAdjustedAnalysisPointer - This method is used when a pass implements
  /// an analysis interface through multiple inheritance.  If needed, it should
  /// override this to adjust the this pointer as needed for the specified pass
  /// info.
  virtual void *getAdjustedAnalysisPointer(AnalysisID PI) {
    if (PI == &CallGraph::ID)
      return (CallGraph*)this;
    return this;
  }

  CallGraphNode* getExternalCallingNode() const { return ExternalCallingNode; }
  CallGraphNode* getCallsExternalNode()   const { return CallsExternalNode; }

  // getRoot - Return the root of the call graph, which is either main, or if
  // main cannot be found, the external node.
  //
  CallGraphNode *getRoot()             { return Root; }
  const CallGraphNode *getRoot() const { return Root; }

private:
  //===---------------------------------------------------------------------
  // Implementation of CallGraph construction
  //

  inline AliasAnalysis::Location
  locationForValue(AliasAnalysis& aa, Value* v)
  {
    return AliasAnalysis::Location(v, aa.getTypeStoreSize(v->getType()));
  }

  CallGraphNode*
  getNodeForLocation(AliasAnalysis& aa, AliasAnalysis::Location& loc)
  {
    std::map<AliasAnalysis::Location, CallGraphNode*>::iterator i = this->locationNodes.find(loc);
    if (i != this->locationNodes.end()) {
      return i->second;
    }
    else {
      // TODO What is the structure that I want here?
      // I think I want a single call graph node that has calls to several nodes..
      CallGraphNode* cgn = new CallGraphNode(NULL);

      for (Module::iterator i = this->Mod->begin(), e = this->Mod->end(); i != e; ++i) {
        if (!aa.isNoAlias(loc, locationForValue(aa, &*i))) {
          cgn->addCalledFunction(CallSite(), getOrInsertFunction(&*i));
        }
      }

      return cgn;
    }
  }
  
  // addToCallGraph - Add a function to the call graph, and link the node to all
  // of the functions that it calls.
  //
  void addToCallGraph(Function *F) {
    CallGraphNode *Node = getOrInsertFunction(F);

    // If this function has external linkage, anything could call it.
    if (!F->hasLocalLinkage()) {
      ExternalCallingNode->addCalledFunction(CallSite(), Node);

      // Found the entry point?
      if (F->getName() == "main") {
        if (Root)    // Found multiple external mains?  Don't pick one.
          Root = ExternalCallingNode;
        else
          Root = Node;          // Found a main, keep track of it!
      }
    }

    // Loop over all of the users of the function, looking for non-call uses.
    for (Value::use_iterator I = F->use_begin(), E = F->use_end(); I != E; ++I){
      User *U = *I;
      if ((!isa<CallInst>(U) && !isa<InvokeInst>(U))
          || !CallSite(cast<Instruction>(U)).isCallee(I)) {
        // Not a call, or being used as a parameter rather than as the callee.
        ExternalCallingNode->addCalledFunction(CallSite(), Node);
        break;
      }
    }

    // If this function is not defined in this translation unit, it could call
    // anything.
    if (F->isDeclaration() && !F->isIntrinsic())
      Node->addCalledFunction(CallSite(), CallsExternalNode);

    AliasAnalysis* aa = this->getAnalysisIfAvailable<AliasAnalysis>();
    
    // Look for calls by this function.
    for (Function::iterator BB = F->begin(), BBE = F->end(); BB != BBE; ++BB)
      for (BasicBlock::iterator II = BB->begin(), IE = BB->end();
           II != IE; ++II) {
        CallSite CS(cast<Value>(II));
        if (CS && !isa<IntrinsicInst>(II)) {
          const Function *Callee = CS.getCalledFunction();
          if (Callee)
            Node->addCalledFunction(CS, getOrInsertFunction(Callee));
          else {
            if (aa) {
              AliasAnalysis::Location loc = locationForValue(*aa, (Value*)Callee);
              Node->addCalledFunction(CS, getNodeForLocation(*aa, loc));
            } else 
              Node->addCalledFunction(CS, CallsExternalNode);
          }
        }
      }
  }

  //
  // destroy - Release memory for the call graph
  virtual void destroy() {
    /// CallsExternalNode is not in the function map, delete it explicitly.
    if (CallsExternalNode) {
      CallsExternalNode->allReferencesDropped();
      delete CallsExternalNode;
      CallsExternalNode = 0;
    }
    if (!locationNodes.empty()) {
      for (std::map<AliasAnalysis::Location, CallGraphNode*>::iterator i = locationNodes.begin(), e = locationNodes.end(); i != e; ++i) {
        i->second->allReferencesDropped();
        delete i->second;
      }
      locationNodes.clear();
    }
    CallGraph::destroy();
  }
};

} //End anonymous namespace

INITIALIZE_AG_PASS(AACallGraph, CallGraph, "aliascg",
                   "Alias Analysis CallGraph Construction", false, true, true)

char AACallGraph::ID = 0;

// Enuse that users of CallGraph.h also link with this file
DEFINING_FILE_FOR(AACallGraph)
