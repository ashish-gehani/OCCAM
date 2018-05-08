/* 
   Inter-procedural Dead Store Elimination.

   Consider only global variables whose addresses have not been taken.
   1. Compute a Memory SSA form.
   2. Follow inter-procedural def-use chains to check if a store to a
      singleton global variable has no use. If yes, the store is dead
      and it can be removed.
*/

#include "transforms/AssistMemorySSA.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Transforms/Utils/UnifyFunctionExitNodes.h"
#include <set>

// For now, only singleton global variables.
// TODO: we can also support regions that contain single types if they
// are always fully accessed.
static llvm::cl::opt<bool>
OnlySingleton("ip-dse-only-singleton",
   llvm::cl::desc("IP DSE: remove store only if operand is a singleton global var"),
   llvm::cl::Hidden,
   llvm::cl::init(true));

#define DSE_LOG(...) __VA_ARGS__

namespace previrt {
namespace transforms {

using namespace llvm;
  
class IPDeadStoreElimination: public ModulePass {
  
  struct QueueElem {
    const Instruction *mem_ssa_inst;
    StoreInst *store_inst;
    
    QueueElem(const Instruction *inst, StoreInst *si)
      : mem_ssa_inst(inst), store_inst(si) { }
    
    bool operator==(const QueueElem& o) const
      { return (mem_ssa_inst == o.mem_ssa_inst && store_inst == o.store_inst);}
    
    bool operator<(const QueueElem& o) const {
      if (mem_ssa_inst < o.mem_ssa_inst) {
	return true;
      } else if (mem_ssa_inst > o.mem_ssa_inst) {
	  return false;
      } else {
	return store_inst < o.store_inst;
      }
    }
    
    void write(raw_ostream &o) const
    { o << "(" << *mem_ssa_inst << ", " << *store_inst << ")"; }
    
    friend raw_ostream& operator<<(raw_ostream &o, const QueueElem &e) {
      e.write(o);
      return o;
    }
  };
    
  
  // Map a store instruction into a boolean. If true then the
  // instruction cannot be deleted.
  DenseMap<StoreInst*, bool> m_store_map;
  
  template<class Q, class S> 
  inline void enqueue(Q &queue, const S &visited, const Instruction *I, StoreInst *SI) {
    QueueElem e(I, SI);
    if (visited.count(e) != 0) {
      DSE_LOG(errs() << "\tSkipped " << e << " from the queue!\n";)
	return;
    }
    DSE_LOG(errs() << "\tEnqueued " << e << "\n";)
      queue.push_back(e);
  }
  
  inline void markStoreToKeep(StoreInst *SI)
  { m_store_map[SI] = true; }
  inline void markStoreToRemove(StoreInst *SI)
  { m_store_map[SI] = false; }
  
  // Given a call to mem.ssa.arg.XXX it founds the nearest actual
  // callsite from the original program and return the calleed
  // function.
  const Function* findCalledFunction(ImmutableCallSite &MemSsaCS) {
    const Instruction *I = MemSsaCS.getInstruction();
    for (auto it = I->getIterator(), et = I->getParent()->end(); it != et; ++it) {
      if (const CallInst *CI = dyn_cast<const CallInst>(&*it)) {
	ImmutableCallSite CS(CI);
	if (!CS.getCalledFunction()) {
	  return nullptr;
	}
	
	if (CS.getCalledFunction()->getName().startswith("mem.ssa")) {
	  continue;
	} else {
	  return CS.getCalledFunction();
	}
      }
    }
    return nullptr;
  }
  
public:
  
  static char ID;
  
  IPDeadStoreElimination(): ModulePass(ID) {}
  
  virtual bool runOnModule(Module& M) override {
    if (M.begin () == M.end ()) {
      return false;
    }
    
    // Worklist: collect all memory ssa store instructions whose
    // pointer operand is a global variable.
    std::vector<QueueElem> queue;
    for (auto& F: M) {
      for (auto &I: instructions(&F)) {
	if (isMemSSAStore(&I, OnlySingleton)) {
	  auto it = I.getIterator();
	  ++it;
	  if (StoreInst *SI = dyn_cast<StoreInst>(&*it)) {
	    queue.push_back(QueueElem(&I, SI));
	    // All the store instructions will be removed unless the
	    // opposite is proven.
	    markStoreToRemove(SI);
	  } else {
	    report_fatal_error("[IP-DSE] after mem.ssa.store we expect a StoreInst");
	  }
	}
      }
    }
    
    if (queue.empty()) {
      return false;
      }
    
    MemorySSACallsManager MMan(M, *this, OnlySingleton);
    
    DSE_LOG(errs() << "[IP-DSE] BEGIN initial queue: \n";
	    for(auto &e: queue) {
	      errs () << "\t" << e << "\n";
	    }
	    errs () << "[IP-DSE] END initial queue\n";)
      
    //boost::unordered_set<QueueElem> visited;
    std::set<QueueElem> visited;	
    
    while (!queue.empty()) {
      QueueElem w = queue.back();
      DSE_LOG(errs() << "[IP-DSE] Processing " << *(w.mem_ssa_inst) << "\n";)
      queue.pop_back();
      visited.insert(w);
      
      if (hasMemSSALoadUser(w.mem_ssa_inst, OnlySingleton)) {
	DSE_LOG(errs() << "\thas a load user: CANNOT be removed.\n";)
	markStoreToKeep(w.store_inst);
	continue;
      } 
      
      for (auto &U: w.mem_ssa_inst->uses()) {
	Instruction *I = dyn_cast<Instruction>(U.getUser());
	if (!I) continue;
	DSE_LOG(errs() << "\tChecking user " << *I << "\n";)
		  
	if (PHINode *PHI = dyn_cast<PHINode>(I)) {
	  DSE_LOG(errs () << "\tPHI node: enqueuing lhs\n";)
	  enqueue(queue, visited, PHI, w.store_inst);
	} else {
	  ImmutableCallSite CS(I);
	  if (!CS.getCalledFunction()) continue;
	  
	  if (isMemSSAStore(CS, OnlySingleton)) {
	    DSE_LOG(errs() << "\tstore: skipped\n";)
	    continue;
	  } else if (isMemSSAArgRef(CS, OnlySingleton)) { 
	    DSE_LOG(errs() << "\targ ref: CANNOT be removed\n";)
	    markStoreToKeep(w.store_inst);		
	  } else if (isMemSSAArgMod(CS, OnlySingleton)) {
	    DSE_LOG(errs() << "\targ mod: skipped\n";)
	    continue;
	  } else if (isMemSSAArgRefMod(CS, OnlySingleton)) {
	    DSE_LOG(errs() << "\tRecurse inter-procedurally in the callee\n";)
	    // Inter-procedural step: we recurse on the uses of
	    // the corresponding formal (non-primed) variable in
	    // the callee.
	      
	    int64_t idx = getMemSSAParamIdx(CS, OnlySingleton);
	    if (idx < 0) {
	      report_fatal_error("[IP-DSE] cannot find index in mem.ssa function");
	    }
	    // HACK: find the actual callsite associated with mem.ssa.arg.ref_mod(...)
	    const Function *calleeF = findCalledFunction(CS);
	    if (!calleeF) {
	      report_fatal_error("[IP-DSE] cannot find callee associated with mem.ssa.XXX function");
	    }
	    const MemorySSAFunction* MemSsaFun = MMan.getFunction(calleeF);
	    if (!MemSsaFun) {
	      report_fatal_error("[IP-DSE] cannot find MemorySSAFunction");
	    }
	    const Value* calleeInitArgV = MemSsaFun->getInFormal(idx);
	    if (!calleeInitArgV) {
	      report_fatal_error("[IP-DSE] getInFormal returned nullptr");
	    }
	    
	    if (const Instruction* calleeInitArg = dyn_cast<const Instruction>(calleeInitArgV)) {
	      enqueue(queue, visited, calleeInitArg, w.store_inst);
	    } else {
	      report_fatal_error("[IP-DSE] expected to enqueue from callee");
	    }
	  } else if (isMemSSAFunIn(CS, OnlySingleton)) {
	    // do nothing
	  } else if (isMemSSAFunOut(CS, OnlySingleton)) {
	    DSE_LOG(errs() << "\tRecurse inter-procedurally in the caller\n";)
	    // Inter-procedural step: we recurse on the uses of
	    // the corresponding actual (primed) variable in the
	    // caller.
	      
	      int64_t idx = getMemSSAParamIdx(CS, OnlySingleton);
	    if (idx < 0) {
	      report_fatal_error("[IP-DSE] cannot find index in mem.ssa function");		
	    }
	    Function *F = I->getParent()->getParent();
	    for (auto &U: F->uses()) {
	      if (CallInst *CI = dyn_cast<CallInst>(U.getUser())) {
		const MemorySSACallSite* MemSsaCS = MMan.getCallSite(CI);
		if (!MemSsaCS) {
		  report_fatal_error("[IP-DSE] cannot find MemorySSACallSite");
		}
		if (const Instruction* caller_primed = dyn_cast<const Instruction>(MemSsaCS->getPrimed(idx))) {
		  enqueue(queue, visited, caller_primed, w.store_inst);
		} else {
		  report_fatal_error("[IP-DSE] expected to enqueue from caller");		    
		}
	      }
	    }
	  } else {
	    errs () << "TODO: unexpected case during worklist processing " << *I << "\n";
	  }
	}
      }
    }
    
    // Finally, we remove dead store instructions
    for (auto &kv: m_store_map) {
      if (!kv.second) {	
	DSE_LOG(errs() << "[IP-DSE] DELETED " <<  *(kv.first) << "\n";)
	kv.first->eraseFromParent();  
      } 
    }
    return false;
  }
  
  virtual void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesAll ();
    //AU.addRequired<previrt::transforms::MemorySSA>();
    AU.addRequired<llvm::UnifyFunctionExitNodes> ();      
  }

  virtual StringRef getPassName() const override {
    return "Interprocedural Dead Store Elimination";
  }
  
};

  char IPDeadStoreElimination::ID = 0;
}
}

static llvm::RegisterPass<previrt::transforms::IPDeadStoreElimination>
X("ip-dse", "Inter-procedural Dead Store Elimination");
