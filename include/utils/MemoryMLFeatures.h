#pragma once

#include "llvm/Pass.h"
#include "llvm/IR/CallSite.h"
#include "llvm/ADT/StringRef.h"
#include <memory>

/** 
 * Extract memory-related ML features using sea-dsa.
 * Currently, we only focus on the effects of a callsite.
 **/

namespace llvm {
  class CallSite;
  class Function;
  class raw_ostream;
}

namespace previrt {
  class MemoryMLFeaturesPassImpl;
}

namespace previrt {

  class MLFeaturesCallSite {
    friend class MemoryMLFeaturesPassImpl;
    
    /* 
     * For a given callsite we consider to points-to graphs:
     *  1. The summary graph of the callee
     *  2. The graph at the callee after unifying actual with formal
     *  parameters at the callsite. We call this top-down unification.
     *
     *  The graph at 2 represents the points-to effects of the callsite
     *  in the callee.
    */

    llvm::Instruction *m_cs; 
        
    // All fields with prefix "callee_" are features from the callee's
    // summary graph.
    // All fields with prefix "td_callee_" represents the callee's
    // graph after top-down unifications at callsite m_cs
    
    // Total number of nodes
    unsigned callee_nodes;
    // Number of collapsed nodes.  A collapsed node is a node for
    // which the analysis lost field-sensitivity.
    unsigned callee_collapsed;
    // Number of read/write nodes
    unsigned callee_accessed;
    // Number of sequence nodes. A sequence node is an abstracted
    // node that represents an unbounded number of consecutive bytes.
    unsigned callee_sequence;
    // Number of nodes allocated in the stack
    unsigned callee_alloca;
    // Number of nodes allocated in the heap
    unsigned callee_heap;
    // Number of nodes allocated by external calls
    unsigned callee_external;
    // Number of LLVM registers that point to some node.
    unsigned callee_pointers;
    // Number of allocation sites 
    unsigned callee_alloc_sites;
    // Number of memory accesses
    unsigned callee_mem_accesses;
    // Number of safe allocation sites (potentially) accessed by a memory operation
    unsigned callee_safe_alloc_sites;
    
    unsigned td_callee_nodes;
    unsigned td_callee_collapsed;
    unsigned td_callee_accessed;
    unsigned td_callee_sequence;
    unsigned td_callee_alloca;
    unsigned td_callee_heap;
    unsigned td_callee_external;
    unsigned td_callee_pointers;
    unsigned td_callee_alloc_sites;
    unsigned td_callee_mem_accesses;
    unsigned td_callee_safe_alloc_sites;

  public:
    
    MLFeaturesCallSite();
    
    MLFeaturesCallSite(llvm::CallSite &CS);
    
    void write(llvm::raw_ostream& o) const ;

    /* Number of nodes in the callee's summary graph */
    unsigned getCalleeNumNodes() const {
      return callee_nodes;
    }
    /* Number of nodes in the callee's after top-down unification */
    unsigned getTdCalleeNumNodes() const {
      return td_callee_nodes;
    }
    /* Number of read/modified nodes in the callee's summary graph */
    unsigned getCalleeNumAccessed() const {
      return callee_accessed;
    }
    /* Number of read/modified nodes in the callee's after top-down unification */ 
    unsigned getTdCalleeNumAccessed() const {
      return td_callee_accessed;
    }
    /* Number of collapsed nodes in the callee's summary graph */
    unsigned getCalleeNumCollapsed() const {
      return callee_collapsed;
    }
    /* Number of collapsed nodes in the callee's after top-down unification */
    unsigned getTdCalleeNumCollapsed() const {
      return td_callee_collapsed;
    }
    /* Number of sequence nodes in the callee's summary graph */ 
    unsigned getCalleeNumSequence() const {
      return callee_sequence;
    }
    /* Number of sequence nodes in the callee's after top-down unification */
    unsigned getTdCalleeNumSequence() const {
      return td_callee_sequence;
    }
    /* Number of stack-allocated nodes in the callee's summary graph */                
    unsigned getCalleeNumAlloca() const {
      return callee_alloca;
    }
    /* Number of stack-allocated nodes in the callee's after top-down unification */    
    unsigned getTdCalleeNumAlloca() const {
      return td_callee_alloca;
    }    
    /* Number of heap-allocated nodes in the callee's summary graph */                
    unsigned getCalleeNumHeap() const {
      return callee_heap;
    }
    /* Number of heap-allocated nodes in the callee's after top-down unification */        
    unsigned getTdCalleeNumHeap() const {
      return td_callee_heap;
    }
    /* Number of external-allocated nodes in the callee's summary graph */     
    unsigned getCalleeNumExternal() const {
      return callee_external;
    }
    /* Number of external-allocated nodes in the callee's graph after td unification */
    unsigned getTdCalleeNumExternal() const {
      return td_callee_external;
    }    
    /* Number of LLVM pointers pointing to some node in the callee's summary graph */
    unsigned getCalleeNumPointers() const {
      return callee_pointers;
    }
    /* Number of LLVM pointers pointing to some node in the callee's
       graph after td unification*/
    unsigned getTdCalleeNumPointers() const {
      return td_callee_pointers;
    }
    /* Number of pointers per node in the callee's summary graph*/
    unsigned getCalleePointersPerNode() const {
      return (callee_nodes > 0 ? callee_pointers / callee_nodes : 0);
    }
    /* Number of pointers per node in the callee's graph after td unification*/
    unsigned getTdCalleePointersPerNode() const {
      return (td_callee_nodes > 0 ? td_callee_pointers / td_callee_nodes : 0);
    }
    /* Number of allocation sites in the callee's summary graph */
    unsigned getCalleeNumAllocSites() const {
      return callee_alloc_sites;
    }
    /* Number of allocation sites in the callee's graph after td unification */
    unsigned getTdCalleeNumAllocSites() const {
      return td_callee_alloc_sites;
    }    
  };

  class MemoryMLFeaturesPass : public llvm::ModulePass {
    std::unique_ptr<MemoryMLFeaturesPassImpl> m_impl;
    
  public:

    static char ID; 

    MemoryMLFeaturesPass();
    
    bool runOnModule(llvm::Module &M) override;
    
    void getAnalysisUsage(llvm::AnalysisUsage &AU) const override;

    MLFeaturesCallSite extractMLFeatures(llvm::CallSite &CS);

    llvm::StringRef getPassName() const override {
      return "Perform memory-related ML feature extraction using sea-dsa";
    }
  };

} // end namespace 
    



