#pragma once

/* Produce a Memory SSA form based on the sea-dsa pointer analysis.

   There is no a direct API to access to the memory SSA
   form. Instead, The memory SSA is explicit in the bitcode by
   having calls to these special functions:

   (1) mem.ssa.load(NodeID, TLVar, SingletonGlobal) 
   (2) TLVar mem.ssa.store(NodeID, TLVar, SingletonGlobal) 
   (3) TLVar mem.ssa.arg.init(NodeID, SingletonGlobal) 
   (4) mem.ssa.arg.ref(NodeID, TLVar, Idx, SingletonGlobal) 
   (5) TLVar mem.ssa.arg.mod(NodeID, TLVar, Idx, SingletonGlobal) 
   (6) TLVar mem.ssa.arg.ref_mod(NodeID, TLVar, Idx, SingletonGlobal)
   (7) TLVar mem.ssa.arg.new(NodeID, TLVar, Idx, SingletonGlobal) 
   (8) mem.ssa.in(NodeID, TLVar, Idx, SingletonGlobal)
   (9) mem.ssa.out(NodeID, TLVar, Idx, SingletonGlobal)

   NodeID is a unique identifier (i32) for memory regions.  

   LLVM callsites are surrounded by calls to mem.ssa.arg.ref,
   mem.ssa.arg.mod, mem.ssa.arg.ref_mod, and mem.ssa.arg_new
   (3)-(7). These functions provide information whether the memory
   region passed to the callee is read-only, modified,
   read-and-modified, or created by the callee, respectively.

   Functions also contain calls to mem.ssa.in (8) and mem.ssa.out (9)
   (they are always located in the exit blocks of the functions). They
   represent the input and output regions of the function.

   With (3)-(9) we have enough information to match actual and formal
   parameters at callsites. To know which actual needs to be matched
   to which formal we use Idx (i32).

   TLVar (i32) refers to a top-level variable (i.e., LLVM register) of
   pointer type. Note that some of these functions return a TLVar,
   representing the primed version of the memory region after an
   update occurs. Finally, SingletonGlobal (i8*) denotes whether the
   memory region corresponds to a global variable whose address has
   not been taken.

   An use of memory region is denoted by (1) and (2) denotes an use
   and definition.

   Comparison with SVF (https://github.com/SVF-tools/SVF):

     This pass is pretty similar to what SVF
     (https://github.com/SVF-tools/SVF/wiki/Technical-documentation)
     during its memory SSA construction. Our special functions
     mem.ssa.load and mem.ssa.store correspond to SVF's MU and CHI
     functions, respectively. Similary, mem.ssa.arg.XXX, mem.ssa.in,
     and mem.ssa.out correspond roughly to CallMU, CallCHI, EntryCHI,
     and RetMU. However, one advantage of our encoding is that we
     don't need special calls for PHI nodes (MSSAPHI in SVF). Instead,
     we can use standard PHI nodes.

*/

#include "llvm/Pass.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/Constants.h"

#include "sea_dsa/Graph.hh"
#include "sea_dsa/Global.hh"

#include "boost/container/flat_set.hpp"

namespace previrt {
namespace transforms {
    
class MemorySSA : public llvm::ModulePass {
  
  llvm::Constant *m_memLoadFn;
  llvm::Constant *m_memStoreFn;
  llvm::Constant *m_memShadowInitFn;
  llvm::Constant *m_memShadowArgInitFn;
  llvm::Constant *m_argRefFn;
  llvm::Constant *m_argModFn;
  llvm::Constant *m_argRefModFn;
  llvm::Constant *m_argNewFn;
  
  llvm::Constant *m_markIn;
  llvm::Constant *m_markOut;
    
  sea_dsa::GlobalAnalysis *m_dsa;
    
  llvm::DenseMap<const sea_dsa::Node*,
                 llvm::DenseMap<unsigned, llvm::AllocaInst*> > m_shadows;
  llvm::DenseMap<const sea_dsa::Node*, unsigned> m_node_ids;
  unsigned m_max_id;
  llvm::Type *m_Int32Ty;
  
  typedef boost::container::flat_set<const sea_dsa::Node*> NodeSet;
  llvm::DenseMap<const llvm::Function *, NodeSet> m_readList;
  llvm::DenseMap<const llvm::Function *, NodeSet > m_modList;
  
  void declareFunctions (llvm::Module &M);

  llvm::AllocaInst* allocaForNode (const sea_dsa::Node *n, unsigned offset);

  unsigned getId (const sea_dsa::Node *n, unsigned offset);

  unsigned getOffset (const sea_dsa::Cell &c);
    
  unsigned getId (const sea_dsa::Cell &c)
  { return getId (c.getNode(), getOffset (c)); }
  
  llvm::AllocaInst* allocaForNode (const sea_dsa::Cell &c)
  { return allocaForNode (c.getNode (), getOffset (c)); }
  
  /// compute read/modified information per function
  void computeReadMod ();
  void updateReadMod (llvm::Function &F, NodeSet &readSet, NodeSet &modSet);
  
  bool isRead (const sea_dsa::Cell &c, const llvm::Function &f);
  bool isRead (const sea_dsa::Node* n, const llvm::Function &f);
  bool isModified (const sea_dsa::Cell &c, const llvm::Function &f);
  bool isModified (const sea_dsa::Node *n, const llvm::Function &f);
  
 public:
  static char ID;
  
  MemorySSA () : llvm::ModulePass (ID), m_max_id(0) {}
  
  virtual bool runOnModule (llvm::Module &M);
  virtual bool runOnFunction (llvm::Function &F);
  
  virtual void getAnalysisUsage (llvm::AnalysisUsage &AU) const;
  virtual llvm::StringRef getPassName () const {return "MemorySSA based on sea-dsa";}
}; 
}
}
