#include "transforms/MemorySSA.h"
#include "transforms/AssistMemorySSA.h"
#include "sea_dsa/CallSite.hh"
#include "sea_dsa/Mapper.hh"
#include "sea_dsa/DsaAnalysis.hh"

#include "llvm/IR/DataLayout.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Transforms/Utils/UnifyFunctionExitNodes.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/Support/raw_ostream.h"

#include "boost/range.hpp"
#include "boost/range/algorithm/sort.hpp"
#include "boost/range/algorithm/set_algorithm.hpp"
#include "boost/range/algorithm/binary_search.hpp"


static llvm::cl::opt<bool>
SplitFields("Pmem-ssa-split-fields",
            llvm::cl::desc("Memory SSA: Split nodes by fields"),
            llvm::cl::init(false));

static llvm::cl::opt<bool>
LocalReadMod ("Pmem-ssa-local-mod",
              llvm::cl::desc("Memory SSA: Compute read/mod info locally"),
              llvm::cl::init(false));

//#define MEMSSA_LOG(...) __VA_ARGS__
#define MEMSSA_LOG(...)

namespace previrt {
namespace transforms {  
  
  using namespace llvm;
  using namespace sea_dsa;

  namespace sea_dsa_impl  {
    template <typename Set>
    void markReachableNodes (const Node *n, Set &set) {
      if (!n) return;
      assert (!n->isForwarding () && "Cannot mark a forwarded node");
      if (set.insert (n).second) 
        for (auto const &edg : n->links ())
          markReachableNodes (edg.second->getNode (), set);
    }

    template <typename Set>
    void reachableNodes (const Function &fn, Graph &g, Set &inputReach, Set& retReach) {
      // formal parameters
      for (Function::const_arg_iterator I = fn.arg_begin(), E = fn.arg_end(); I != E; ++I) {
        const Value &arg = *I;
        if (g.hasCell (arg)) {
          Cell &c = g.mkCell (arg, Cell ());
          markReachableNodes (c.getNode (), inputReach);
        }
      }
      
      // globals
      for (auto &kv : boost::make_iterator_range (g.globals_begin(), g.globals_end())) {
        markReachableNodes (kv.second->getNode (), inputReach);
      }
      
      // return value
      if (g.hasRetCell (fn))
        markReachableNodes (g.getRetCell (fn).getNode(), retReach);
    }

    template <typename Set>
    void set_difference (Set &s1, Set &s2) {
      Set s3;
      boost::set_difference (s1, s2, std::inserter (s3, s3.end ()));
      std::swap (s3, s1);
    }
  
    template <typename Set>
    void set_union (Set &s1, Set &s2) {
      Set s3;
      boost::set_union (s1, s2, std::inserter (s3, s3.end ()));
      std::swap (s3, s1);
    }
 
    /// Computes Node reachable from the call arguments in the graph.
    /// reach - all reachable nodes
    /// outReach - subset of reach that is only reachable from the return node
    template <typename Set1, typename Set2>
    void argReachableNodes (const Function &fn, Graph &G, Set1 &reach, Set2 &outReach) {
      reachableNodes (fn, G, reach, outReach);
      set_difference (outReach, reach);
      set_union (reach, outReach);
    }

  } // end namespace sea_dsa_impl


  bool MemorySSA::isRead (const Cell &c, const Function &f) {
    return c.getNode () ? isRead (c.getNode (), f) : false;
  }
  
  bool MemorySSA::isModified (const Cell &c, const Function &f) {
    return c.getNode () ? isModified (c.getNode (), f) : false;
  }
  
  bool MemorySSA::isRead (const Node *n, const Function &f) {
    return LocalReadMod ?  m_readList[&f].count(n) > 0 : n->isRead ();
  }
  
  bool MemorySSA::isModified (const Node *n, const Function &f) {
    return LocalReadMod ? m_modList[&f].count (n) > 0 : n->isModified ();
  }
  
  AllocaInst* MemorySSA::allocaForNode (const Node *n, const unsigned offset) {
    auto &offmap = m_shadows[n];
    auto it = offmap.find (offset);
    if (it != offmap.end ()) return it->second;
    
    AllocaInst *a = new AllocaInst (m_Int32Ty, 0);
    offmap [offset] = a;
    return a;
  }
    
  unsigned MemorySSA::getId (const Node *n, unsigned offset) {
    auto it = m_node_ids.find (n);
    if (it != m_node_ids.end ()) return it->second + offset;
    
    unsigned id = m_max_id;
    m_node_ids[n] = id;

    if (n->size() == 0) {
      // XXX: nodes can have zero size
      assert (offset == 0);
      m_max_id++;
      return id;
    }
    
    // -- allocate enough ids for every byte of the object
    assert (n->size() > 0);
    m_max_id += n->size ();
    return id + offset;
  }
    
    
  void MemorySSA::declareFunctions (llvm::Module &M) {
    LLVMContext &ctx = M.getContext ();
    m_Int32Ty = Type::getInt32Ty (ctx);
    m_memLoadFn = M.getOrInsertFunction ("mem.ssa.load", 
                                         Type::getVoidTy (ctx),
                                         Type::getInt32Ty (ctx),
                                         Type::getInt32Ty (ctx),
                                         Type::getInt8PtrTy (ctx));
    
    m_memStoreFn = M.getOrInsertFunction ("mem.ssa.store", 
                                          Type::getInt32Ty (ctx),
                                          Type::getInt32Ty (ctx),
                                          Type::getInt32Ty (ctx),
                                          Type::getInt8PtrTy (ctx));

    // initialization of a region reachable from the function returns
    m_memShadowInitFn = M.getOrInsertFunction ("mem.ssa.init",
                                               Type::getInt32Ty (ctx),
                                               Type::getInt32Ty (ctx),
                                               Type::getInt8PtrTy (ctx));

    // initialization of a region reachable from the function inputs
    m_memShadowArgInitFn = M.getOrInsertFunction ("mem.ssa.arg.init",
                                                  Type::getInt32Ty (ctx),
                                                  Type::getInt32Ty (ctx),
                                                  Type::getInt8PtrTy (ctx));

    // read-only actual parameter at the caller
    m_argRefFn = M.getOrInsertFunction ("mem.ssa.arg.ref",
                                        Type::getVoidTy (ctx),
                                        Type::getInt32Ty (ctx),
                                        Type::getInt32Ty (ctx),
                                        Type::getInt32Ty (ctx),
                                        Type::getInt8PtrTy (ctx));

    // modified actual parameter at the caller
    m_argModFn = M.getOrInsertFunction ("mem.ssa.arg.mod",
                                        Type::getInt32Ty (ctx),
                                        Type::getInt32Ty (ctx),
                                        Type::getInt32Ty (ctx),
                                        Type::getInt32Ty (ctx),
                                        Type::getInt8PtrTy (ctx));

    // read and modified 
    m_argRefModFn = M.getOrInsertFunction ("mem.ssa.arg.ref_mod",
                                        Type::getInt32Ty (ctx),
                                        Type::getInt32Ty (ctx),
                                        Type::getInt32Ty (ctx),
                                        Type::getInt32Ty (ctx),
                                        Type::getInt8PtrTy (ctx));
    
    // new region created by the callee
    m_argNewFn = M.getOrInsertFunction ("mem.ssa.arg.new",
                                        Type::getInt32Ty (ctx),
                                        Type::getInt32Ty (ctx),
                                        Type::getInt32Ty (ctx),
                                        Type::getInt32Ty (ctx),
                                        Type::getInt8PtrTy (ctx));

    // read-only formal parameter (input regions)
    m_markIn = M.getOrInsertFunction ("mem.ssa.in",
                                      Type::getVoidTy (ctx),
                                      Type::getInt32Ty (ctx),
                                      Type::getInt32Ty (ctx),
                                      Type::getInt32Ty (ctx),
                                      Type::getInt8PtrTy (ctx));

    // modified formal parameter  (output regions)
    m_markOut = M.getOrInsertFunction ("mem.ssa.out",
                                       Type::getVoidTy (ctx),
                                       Type::getInt32Ty (ctx),
                                       Type::getInt32Ty (ctx),
                                       Type::getInt32Ty (ctx),
                                       Type::getInt8PtrTy (ctx));
  }
  
  bool MemorySSA::runOnModule (llvm::Module &M) {
    if (M.begin () == M.end ())
      return false;
    
    m_dsa = &getAnalysis<DsaAnalysis>().getDsaAnalysis ();
    if (LocalReadMod) {
      computeReadMod ();
    }
    
    declareFunctions(M);
    m_node_ids.clear ();
    bool change = false;
    for (Function &f : M) {
      change |= runOnFunction (f);
    }
    return change;
  }
  
  void MemorySSA::computeReadMod () {
    CallGraph &cg = getAnalysis<CallGraphWrapperPass> ().getCallGraph ();
    for (auto it = scc_begin (&cg); !it.isAtEnd(); ++it) {
      const std::vector<CallGraphNode*> &scc = *it;
      NodeSet read;
      NodeSet modified;

      // compute read/mod, sharing information between scc 
      for (CallGraphNode *cgn : scc) {
        Function *f = cgn->getFunction ();
        if (!f) continue;
        updateReadMod (*f, read, modified);
      }

      // set the computed read/mod to all functions in the scc
      for (CallGraphNode *cgn : scc) {
        Function *f = cgn->getFunction ();
        if (!f) continue;
        m_readList[f].insert (read.begin (), read.end ());
        m_modList[f].insert (modified.begin(), modified.end ());
      }
    }
  }
  
  void MemorySSA::updateReadMod (Function &F, NodeSet &readSet, NodeSet &modSet) {
    if (!m_dsa->hasGraph (F)) return;
    
    Graph &G = m_dsa->getGraph (F);
    for (BasicBlock &bb : F) {
      for (Instruction &inst : bb) {
        if (LoadInst *li = dyn_cast<LoadInst> (&inst)) {
          if (G.hasCell (*(li->getPointerOperand ()))) {
            const Cell &c = G.getCell (*(li->getPointerOperand ()));
            if (!c.isNull()) readSet.insert (c.getNode ());
          }
        }
        else if (StoreInst *si = dyn_cast<StoreInst> (&inst)) {
          if (G.hasCell (*(si->getPointerOperand ()))) {
            const Cell &c = G.getCell (*(si->getPointerOperand ()));
            if (!c.isNull ()) modSet.insert (c.getNode ());
          }
        }
        else if (CallInst *ci = dyn_cast<CallInst> (&inst)) {
          CallSite CS (ci);
          Function *cf = CS.getCalledFunction ();
          if (!cf) continue;
          if (cf->getName ().equals ("calloc")) {
            const Cell &c = G.getCell (inst);
            if (!c.isNull ()) modSet.insert (c.getNode ());
          }
          else if (m_dsa->hasGraph (*cf)) {
            readSet.insert (m_readList[cf].begin (), m_readList[cf].end ());
            modSet.insert (m_modList[cf].begin (), m_modList[cf].end ());
          }            
          
        }
        // TODO: handle intrinsics (memset,memcpy) and other library functions
      }
    }
  }
  
  static Value *getUniqueScalar (LLVMContext &ctx, IRBuilder<> &B, const Cell &c) {
    const Node* n = c.getNode ();
    if (n && c.getOffset () == 0) {
      Value *v = const_cast<Value*>(n->getUniqueScalar ());
    
      // -- a unique scalar is a single-cell global variable. We might be
      // -- able to extend this to single-cell local pointers, but these
      // -- are probably not very common.
      if (v)
        if (GlobalVariable *gv = dyn_cast<GlobalVariable> (v))
          if (gv->getType ()->getElementType ()->isSingleValueType ())
            return B.CreateBitCast (v, Type::getInt8PtrTy (ctx));
    }
    return ConstantPointerNull::get (Type::getInt8PtrTy (ctx));
  }

  unsigned MemorySSA::getOffset (const Cell &c)
  {return (SplitFields ? c.getOffset() : 0);}    
  
  bool MemorySSA::runOnFunction (Function &F) {
    if (F.isDeclaration ()) return false;
    if (!m_dsa->hasGraph(F)) return false;

    
    Graph &G = m_dsa->getGraph (F);

    // Debugging
    MEMSSA_LOG(errs () << "Memory SSA on " << F.getName() << "\n";    
	       G.write(errs());
	       errs () << "\n";);
    
    m_shadows.clear ();
    // -- preserve ids across functions m_node_ids.clear ();
    LLVMContext &ctx = F.getContext ();
    IRBuilder<> B (ctx);
    for (BasicBlock &bb : F) {
      for (Instruction &inst : bb) {
        if (const LoadInst *load = dyn_cast<LoadInst> (&inst)) {
          if (!G.hasCell (*(load->getOperand (0)))) {
	    continue;
	  }
          const Cell &c = G.getCell (*(load->getOperand (0)));
          if (c.isNull ()) continue;
          
          B.SetInsertPoint (&inst);
          B.CreateCall (m_memLoadFn,
			{B.getInt32 (getId (c)),
                         B.CreateLoad (allocaForNode (c)),
			 getUniqueScalar (ctx, B, c)});
        }
        else if (const StoreInst *store = dyn_cast<StoreInst> (&inst)) {
          if (!G.hasCell (*(store->getOperand (1)))) {
	    continue;
	  }
          const Cell &c = G.getCell (*(store->getOperand (1)));
          if (c.isNull ()) continue;
          
          B.SetInsertPoint (&inst);
          AllocaInst *v = allocaForNode (c);
          B.CreateStore (B.CreateCall (m_memStoreFn, 
                                       {B.getInt32 (getId (c)),
                                        B.CreateLoad (v),
					getUniqueScalar (ctx, B, c)}),
                         v);           
        }
        else if (CallInst *call = dyn_cast<CallInst> (&inst)) {
          /// ignore inline assembly
          if (call->isInlineAsm ()) continue;
          
          /// skip intrinsics, except for memory-related ones
          if (isa<IntrinsicInst> (call) && !isa<MemIntrinsic> (call)) continue;

          ImmutableCallSite ICS(call);
          DsaCallSite CS (ICS);

          if (!CS.getCallee()) continue;
          
          if (CS.getCallee ()->getName ().equals ("calloc")) {
            if (!G.hasCell(*call)) continue;
            const Cell &c = G.getCell (*call);
            if (c.isNull ()) continue;
            
	    if (c.getOffset () == 0) {
	      B.SetInsertPoint (call);
	      AllocaInst *v = allocaForNode (c);
	      B.CreateStore (B.CreateCall (m_memStoreFn,
					   {B.getInt32 (getId (c)),
					    B.CreateLoad (v),
					    getUniqueScalar (ctx, B, c)}), v);
	    } else {
	      // TODO: handle multiple nodes
	      errs() << "WARNING: missing calloc instrumentation because cell offset is not zero\n";
	    }
          }
          else if (MemSetInst *MSI = dyn_cast<MemSetInst>(&inst)) {
	    Value &dst = *(MSI->getDest ());
            if (!G.hasCell(dst)) continue;
            const Cell &c = G.getCell (dst);
            if (c.isNull ()) continue;

	    if (c.getOffset () == 0) {
	      B.SetInsertPoint (&inst);
	      AllocaInst *v = allocaForNode (c);
	      B.CreateStore (B.CreateCall (m_memStoreFn,
					   {B.getInt32 (getId (c)),
					    B.CreateLoad (v),
					    getUniqueScalar (ctx, B, c)}), v);
	    } else {
	      // TODO: handle multiple nodes
	      errs() << "WARNING: missing memset instrumentation because cell offset is not zero\n";
	    }
          }
	  

          const Function &calleeF = *CS.getCallee ();
          if (!m_dsa->hasGraph (calleeF)) continue;
          Graph &calleeG= m_dsa->getGraph (calleeF);
          
          // -- compute callee nodes reachable from arguments and returns
          std::set<const Node*> reach;
          std::set<const Node*> retReach;
          sea_dsa_impl::argReachableNodes (calleeF, calleeG, reach, retReach);

          // -- compute mapping between callee and caller graphs
          SimulationMapper simMap;
          Graph::computeCalleeCallerMapping (CS, calleeG, G, simMap); 
          
          /// generate mod, ref, new function, based on whether the
          /// remote node reads, writes, or creates the corresponding node.
          
          B.SetInsertPoint (&inst);
          unsigned idx = 0;
          for (const Node* n : reach) {
            // skip nodes that are not read/written by the callee
            if (!isRead (n, calleeF) && !isModified (n, calleeF)) continue;

            // TODO: This must be done for every possible offset of the caller node,
            // TODO: not just for offset 0

            assert (n);
            Cell callerC = simMap.get(Cell(const_cast<Node*> (n), 0));
            assert (!callerC.isNull () && "Not found node in the simulation map");
            AllocaInst *v = allocaForNode (callerC);
            unsigned id = getId (callerC);
            // -- read only node ignore nodes that are only reachable
            // -- from the return of the function
            if (isRead (n, calleeF) && !isModified (n, calleeF) && retReach.count(n) <= 0) {
              B.CreateCall (m_argRefFn,
			    {B.getInt32 (id),
                             B.CreateLoad (v),
                             B.getInt32 (idx),
			     getUniqueScalar (ctx, B, callerC)});
            }
            // -- read/write or new node
            else if (isModified (n, calleeF)) {
              // -- n is new node iff it is reachable only from the return node
              Constant* argFn = retReach.count (n) ? m_argNewFn : m_argModFn;
	      if (m_argModFn && isRead(n,calleeF))
		argFn = m_argRefModFn;
              B.CreateStore (B.CreateCall (argFn, 
                                           {B.getInt32 (id),
                                            B.CreateLoad (v),
                                            B.getInt32 (idx),
					    getUniqueScalar (ctx, B, callerC)}), v);
            }
            idx++;
          }
        }
      }
    }
      
    // compute Nodes that escape because they are either reachable
    // from the input arguments or from returns
    std::set<const Node*> reach;
    std::set<const Node*> retReach;
    sea_dsa_impl::argReachableNodes (F, G, reach, retReach);
    
    // -- create shadows for all nodes that are modified by this
    // -- function and escape to a parent function
    for (const Node *n : reach) {
      if (isModified (n, F) || isRead (n, F)) {
        // TODO: allocate for all slices of n, not just offset 0
        allocaForNode (n, 0);
      }
    }
    
    // allocate initial value for all used shadows
    DenseMap<const Node*, DenseMap<unsigned, Value*> > inits;
    B.SetInsertPoint (&*F.getEntryBlock ().begin ());
    for (auto it : m_shadows) {
      const Node *n = it.first;
      Constant *fn = reach.count (n) <= 0 ? m_memShadowInitFn : m_memShadowArgInitFn;
      for (auto jt : it.second) {
        Cell c (const_cast<Node*> (n), jt.first);
        AllocaInst *a = jt.second;
        B.Insert (a, "mem.ssa");
        CallInst *ci;
        ci = B.CreateCall(fn, {B.getInt32 (getId (c)), getUniqueScalar (ctx, B, c)});
        inits[c.getNode()][getOffset(c)] = ci;
        B.CreateStore (ci, a);
      }
    }
     
    UnifyFunctionExitNodes &ufe = getAnalysis<llvm::UnifyFunctionExitNodes> (F);
    if (BasicBlock *exit = ufe.getReturnBlock ()) {
      TerminatorInst *ret = exit->getTerminator ();
      // split return basic block if it has more than just the return instruction
      if (exit->size () > 1) {
	exit = llvm::SplitBlock (exit, ret,
				 // these two passes will not be preserved if null
				 nullptr /*DominatorTree*/, nullptr /*LoopInfo*/);
	ret = exit->getTerminator ();
      }
      
      B.SetInsertPoint (ret);
      unsigned idx = 0;
      for (const Node* n : reach) {
	// skip nodes that are not read/written by the callee
	if (!isRead (n, F) && !isModified (n, F)) continue;
	
	// TODO: extend to work with all slices
	Cell c (const_cast<Node*> (n), 0);
	
	// n is read and is not only return-node reachable (for
	// return-only reachable nodes, there is no initial value
	// because they are created within this function)
	if ((isRead (n, F) || isModified (n, F)) && retReach.count (n) <= 0) {
	  assert (!inits[n].empty());
	  /// initial value
	  B.CreateCall (m_markIn,
			{B.getInt32 (getId (c)),
			 inits[n][0], 
			 B.getInt32 (idx),
			 getUniqueScalar (ctx, B, c)});
	}
	
	if (isModified (n, F)) {
	  assert (!inits[n].empty());
	  /// final value
	  B.CreateCall (m_markOut, 
			{B.getInt32 (getId (c)),
			 B.CreateLoad (allocaForNode (c)),
			 B.getInt32 (idx),
			 getUniqueScalar (ctx, B, c)});
	}
	++idx;
      }
    } else {
      // TODO
    }
    return true;
  }
    
  void MemorySSA::getAnalysisUsage (llvm::AnalysisUsage &AU) const {
    //AU.setPreservesAll ();
    AU.addRequiredTransitive<DsaAnalysis> ();    
    AU.addRequired<llvm::CallGraphWrapperPass>();
    AU.addRequired<llvm::UnifyFunctionExitNodes> ();
  } 
    

  class StripMemorySSAInst : public ModulePass  {
  public:
    static char ID;
    StripMemorySSAInst () : ModulePass (ID) {} 

    void getAnalysisUsage (AnalysisUsage &AU) const override
    {AU.setPreservesAll ();}
    
    bool runOnModule (Module &M) override {
      std::vector<std::string> voidFnNames = 
        {"mem.ssa.load", "mem.ssa.arg.ref",
         "mem.ssa.in", "mem.ssa.out" };
      
      for (auto &name : voidFnNames) {
        Function *fn = M.getFunction (name);
        if (!fn) continue;
        
        while (!fn->use_empty ()) {
          CallInst *ci = cast<CallInst> (fn->user_back ());
          Value *last = ci->getArgOperand (ci->getNumArgOperands () - 1);
          ci->eraseFromParent ();
          RecursivelyDeleteTriviallyDeadInstructions (last);
        }
      }

      std::vector<std::string> intFnNames =
        { "mem.ssa.store", "mem.ssa.init",
          "mem.ssa.arg.init", "mem.ssa.arg.mod",
	  "mem.ssa.arg.ref_mod"};
      Value *zero = ConstantInt::get (Type::getInt32Ty(M.getContext ()), 0);
      
      for (auto &name : intFnNames) {
        Function *fn = M.getFunction (name);
        if (!fn) continue;
        
        while (!fn->use_empty ()) {
          CallInst *ci = cast<CallInst> (fn->user_back ());
          Value *last = ci->getArgOperand (ci->getNumArgOperands () - 1);
          ci->replaceAllUsesWith (zero);
          ci->eraseFromParent ();
          RecursivelyDeleteTriviallyDeadInstructions (last);
        }
      }
      
      return true;
    }
    
  };
  
  char MemorySSA::ID = 0;
  char StripMemorySSAInst::ID = 0;  
}
}

static llvm::RegisterPass<previrt::transforms::MemorySSA>
X ("memory-ssa", "Memory SSA using sea-dsa");
static llvm::RegisterPass<previrt::transforms::StripMemorySSAInst>
Y ("strip-memory-ssa-inst", "Remove Memory SSA instrumentation");


