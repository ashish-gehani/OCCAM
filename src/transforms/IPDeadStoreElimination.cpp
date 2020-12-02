/*
   Inter-procedural Dead Store Elimination.

   1. Run seadsa ShadowMem pass to instrument code with shadow.mem
      instructions.

   2. Follow inter-procedural def-use chains to check if a store has
      no use. If yes, the store is dead and it can be safely
      removed. We also identify useless global initializers.

   3. Remove shadow.mem function calls.

*/

#include "llvm/IR/CallSite.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/UnifyFunctionExitNodes.h"

#include "seadsa/InitializePasses.hh"
#include "seadsa/ShadowMem.hh"

#include <boost/functional/hash.hpp>
#include <boost/unordered_set.hpp>

#include "analysis/MemorySSA.h"

static llvm::cl::opt<bool>
OnlySingleton(
    "ipdse-only-singleton",
    llvm::cl::desc(
        "IP DSE: remove store only if operand is a singleton global var"),
    llvm::cl::Hidden, llvm::cl::init(true));

static llvm::cl::opt<unsigned>
MaxLenDefUse("ipdse-max-def-use",
    llvm::cl::desc("IP DSE: maximum length of the def-use chain"),
    llvm::cl::Hidden, llvm::cl::init(UINT_MAX));

//#define DSE_LOG(...) __VA_ARGS__
#define DSE_LOG(...)

namespace previrt {
namespace transforms {

using namespace llvm;
using namespace analysis;

static bool hasFunctionPtrParam(Function *F) {
  FunctionType *FTy = F->getFunctionType();
  for (unsigned i = 0, e = FTy->getNumParams(); i < e; ++i) {
    if (PointerType *PT = dyn_cast<PointerType>(FTy->getParamType(i))) {
      if (isa<FunctionType>(PT->getElementType())) {
        return true;
      }
    }
  }
  return false;
}

class IPDeadStoreElimination : public ModulePass {

  struct QueueElem {
    // Last shadow mem instruction related to storeInstOrGvInit
    const Instruction *shadowMemInst;
    // The original instruction that we want to remove if we can prove
    // it is redundant.
    Value *storeInstOrGvInit;
    // Number of steps (i.e., shadow mem instructions connect them)
    // between storeInstOrGvInit and shadowMemInst
    unsigned length;

    QueueElem(const Instruction *I, Value *V, unsigned Len)
        : shadowMemInst(I), storeInstOrGvInit(V), length(Len) {}

    size_t hash() const {
      size_t val = 0;
      boost::hash_combine(val, shadowMemInst);
      boost::hash_combine(val, storeInstOrGvInit);
      return val;
    }

    bool operator==(const QueueElem &o) const {
      return (shadowMemInst == o.shadowMemInst &&
              storeInstOrGvInit == o.storeInstOrGvInit);
    }

    void write(raw_ostream &o) const {
      o << "(" << *shadowMemInst << ", " << *storeInstOrGvInit << ")";
    }

    friend raw_ostream &operator<<(raw_ostream &o, const QueueElem &e) {
      e.write(o);
      return o;
    }
  };

  struct QueueElemHasher {
    size_t operator()(const QueueElem &e) const { return e.hash(); }
  };


  template <class Q, class QE> inline void enqueue(Q &queue, QE e) {
    DSE_LOG(errs() << "\tEnqueued " << e << "\n");
    queue.push_back(e);
  }

  // Map a store instruction into a boolean. If true then the
  // instruction cannot be deleted.
  DenseMap<Value*, bool> m_valueMap;
  
  inline void markToKeep(Value *V) {
    m_valueMap[V] = true;
    DSE_LOG(errs()<< "\tKeep " << *V << "\n";);
  }
  
  inline void markToRemove(Value *V) {
    if (m_valueMap[V]) {
      report_fatal_error(
	"[IPDSE] cannot remove an instruction that was previously marked as keep");
    }
    m_valueMap[V] = false;
  }

  // Given a call to shadow.mem.arg.XXX it founds the nearest actual
  // callsite from the original program and return the calleed
  // function.
  const Function *findCalledFunction(ImmutableCallSite &MemSsaCS) {
    const Instruction *I = MemSsaCS.getInstruction();
    for (auto it = I->getIterator(), et = I->getParent()->end(); it != et;
         ++it) {
      if (const CallInst *CI = dyn_cast<const CallInst>(&*it)) {
        ImmutableCallSite CS(CI);
        if (!CS.getCalledFunction()) {
          return nullptr;
        }

        if (CS.getCalledFunction()->getName().startswith("shadow.mem")) {
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

  IPDeadStoreElimination() : ModulePass(ID) {
    // Initialize sea-dsa pass
    llvm::PassRegistry &Registry = *llvm::PassRegistry::getPassRegistry();
    //llvm::initializeAllocWrapInfoPass(Registry);
    llvm::initializeShadowMemPassPass(Registry);
  }

  virtual bool runOnModule(Module &M) override {
    if (M.begin() == M.end()) {
      return false;
    }

    errs() << "Started interprocedural dead store elimination...\n";
    
    // Populate worklist
    
    // --- collect all shadow.mem store instructions
    std::vector<QueueElem> queue;
    for (auto &F : M) {
      for (auto &I : instructions(&F)) {
        if (isMemSSAStore(&I, OnlySingleton)) {
          auto it = I.getIterator();
          ++it;
          if (StoreInst *SI = dyn_cast<StoreInst>(&*it)) {
            queue.push_back(QueueElem(&I, SI, 0));
            // All the store instructions will be removed unless the
            // opposite is proven.
            markToRemove(SI);
          } else {
            report_fatal_error(
                "[IPDSE] after shadow.mem.store we expect a StoreInst");
          }
        }
      }
    }
    // --- collect all global initializers
    if (Function *main =  M.getFunction("main")) {
      BasicBlock &entryBB = main->getEntryBlock();
      for (auto &I: entryBB) {
	if (isMemSSAArgInit(&I, true /*only if singleton*/) ||
	    isMemSSAGlobalInit(&I, false /* global.init cannot be singleton */)) {
	  ImmutableCallSite CS(&I);
	  if (GlobalVariable *GV = const_cast<GlobalVariable*>
	      (dyn_cast<const GlobalVariable>
	       (getMemSSASingleton(CS, MemSSAOp::MEM_SSA_ARG_INIT)))) {
	    if (GV->hasInitializer()) {
	      queue.push_back(QueueElem(&I, GV, 0));
	      // All the global initializers will be removed unless the
	      // opposite is proven.
	      markToRemove(GV);
	    }
	  }
	}
      }
    }

    // Process worklist

    // TODO: we need to improve performance by caching intermediate
    // queries. In particular, we need to remember PHI nodes and
    // function parameters.
    
    unsigned numUselessStores = 0;
    unsigned numUselessGvInit = 0;    
    unsigned skippedChains = 0;    
    if (!queue.empty()) {
      errs() << "Number of stores: " << queue.size() << "\n";
      MemorySSACallsManager MMan(M, *this, OnlySingleton);

      DSE_LOG(errs() << "[IPDSE] BEGIN initial queue: \n"; for (auto &e
                                                                 : queue) {
        errs() << e << "\n";
      } errs() << "[IPDSE] END initial queue\n";);

      // A store is not useless if there is a def-use chain between a
      // store and a load instruction and there is not any other store
      // in between.
      boost::unordered_set<QueueElem, QueueElemHasher> visited;
      while (!queue.empty()) {
        QueueElem w = queue.back();
        DSE_LOG(errs() << "[IPDSE] Processing " << *(w.shadowMemInst)
                       << "\n");
        queue.pop_back();

        if (!visited.insert(w).second) {
	  // this is not necessarily a cycle
	  DSE_LOG(errs() << "\tAlready processed: skipped\n";);
          continue;
        }

        if (hasMemSSALoadUser(w.shadowMemInst, OnlySingleton)) {
          DSE_LOG(errs() << "\thas a load user: CANNOT be removed.\n");
          markToKeep(w.storeInstOrGvInit);
          continue;
        }
	
        if (w.length == MaxLenDefUse) {
          skippedChains++;
          markToKeep(w.storeInstOrGvInit);
          continue;
        }

	// w.storeInstOrGvInit is not useless if any of its direct or
	// indirect uses say it is not useless.
        for (auto &U : w.shadowMemInst->uses()) {
	  
	  if (m_valueMap[w.storeInstOrGvInit]) {
	    // Do not bother with the rest of uses if one already said
	    // that the store or global initializer is not useless.
	    break;
	  }
	  
          Instruction *I = dyn_cast<Instruction>(U.getUser());
          if (!I)
            continue;
          DSE_LOG(errs() << "\tChecking user " << *I << "\n");

          if (PHINode *PHI = dyn_cast<PHINode>(I)) {
            DSE_LOG(errs() << "\tPHI node: enqueuing lhs\n");
            enqueue(queue, QueueElem(PHI, w.storeInstOrGvInit, w.length + 1));
          } else if (isa<CallInst>(I)) {
            ImmutableCallSite CS(I);
            if (!CS.getCalledFunction())
              continue;
            if (isMemSSAStore(CS, OnlySingleton)) {
              DSE_LOG(errs() << "\tstore: skipped\n");
              continue;
            } else if (isMemSSAArgRef(CS, OnlySingleton)) {
              DSE_LOG(errs() << "\targ ref: CANNOT be removed\n");
              markToKeep(w.storeInstOrGvInit);
            } else if (isMemSSAArgMod(CS, OnlySingleton) || 
		       isMemSSAArgRefMod(CS, OnlySingleton)) {
              DSE_LOG(errs() << "\tRecurse inter-procedurally in the callee\n");
              // Inter-procedural step: we recurse on the uses of
              // the corresponding formal (non-primed) variable in
              // the callee.

              int64_t idx = getMemSSAParamIdx(CS);
              if (idx < 0) {
                report_fatal_error(
                    "[IPDSE] cannot find index in shadow.mem function");
              }
              // HACK: find the actual callsite associated with
              // shadow.mem.arg.ref_mod(...)
              const Function *calleeF = findCalledFunction(CS);
              if (!calleeF) {
                report_fatal_error(
                    "[IPDSE] cannot find callee with shadow.mem.XXX function");
              }
              const MemorySSAFunction *MemSsaFun = MMan.getFunction(calleeF);
              if (!MemSsaFun) {
                report_fatal_error("[IPDSE] cannot find MemorySSAFunction");
              }

              if (MemSsaFun->getNumInFormals() == 0) {
                // Probably the function has only shadow.mem.arg.init
                errs() << "TODO: unexpected case function without "
                          "shadow.mem.in.\n";
                markToKeep(w.storeInstOrGvInit);
                continue;
              }

              const Value *calleeInitArgV = MemSsaFun->getInFormal(idx);
              if (!calleeInitArgV) {
                report_fatal_error("[IPDSE] getInFormal returned nullptr");
              }

              if (const Instruction *calleeInitArg =
                      dyn_cast<const Instruction>(calleeInitArgV)) {
                enqueue(queue,
                        QueueElem(calleeInitArg, w.storeInstOrGvInit, w.length + 1));
              } else {
                report_fatal_error("[IPDSE] expected to enqueue from callee");
              }

            } else if (isMemSSAFunIn(CS, OnlySingleton)) {
              DSE_LOG(errs() << "\tin: skipped\n");
              // do nothing
            } else if (isMemSSAFunOut(CS, OnlySingleton)) {
              DSE_LOG(errs() << "\tRecurse inter-procedurally in the caller\n");
              // Inter-procedural step: we recurse on the uses of
              // the corresponding actual (primed) variable in the
              // caller.

              int64_t idx = getMemSSAParamIdx(CS);
              if (idx < 0) {
                report_fatal_error(
                    "[IPDSE] cannot find index in shadow.mem function");
              }

              // Find callers
              Function *F = I->getParent()->getParent();
              for (auto &U : F->uses()) {
                if (CallInst *CI = dyn_cast<CallInst>(U.getUser())) {
                  const MemorySSACallSite *MemSsaCS = MMan.getCallSite(CI);
                  if (!MemSsaCS) {
                    report_fatal_error(
                        "[IPDSE] cannot find MemorySSACallSite");
                  }

                  // make things easier ...
                  CallSite CS(CI);
                  assert(CS.getCalledFunction());
                  if (hasFunctionPtrParam(CS.getCalledFunction())) {
                    markToKeep(w.storeInstOrGvInit);
                    continue;
                  }

                  if (idx >= MemSsaCS->numParams()) {
                    // It's possible that the function has formal
                    // parameters but the call site does not have actual
                    // parameters. E.g., llvm can remove the return
                    // parameter from the callsite if it's not used.
                    errs() << "TODO: unexpected case of callsite with no "
                              "actual parameters.\n";
                    markToKeep(w.storeInstOrGvInit);
                    break;
                  }

                  if (OnlySingleton) {
                    if ((!MemSsaCS->isRefMod(idx)) && (!MemSsaCS->isMod(idx)) &&
                        (!MemSsaCS->isNew(idx))) {
                      // XXX: if OnlySingleton then isRefMod, isMod, and
                      // isNew can only return true if the corresponding
                      // memory region is a singleton. We saw cases
                      // (e.g., curl) where we start from store to a
                      // singleton region but after following its
                      // def-use chain we end up having other shadow.mem
                      // instructions that do not correspond to a
                      // singleton region. This is a sea-dsa issue. For
                      // now, we play conservative and give up by
                      // keeping the store.
                      markToKeep(w.storeInstOrGvInit);
                      break;
                    }
                  }

                  assert(OnlySingleton || MemSsaCS->isRefMod(idx) ||
                         MemSsaCS->isMod(idx) || MemSsaCS->isNew(idx));
                  if (const Instruction *caller_primed =
                          dyn_cast<const Instruction>(
                              MemSsaCS->getPrimed(idx))) {
                    enqueue(queue, QueueElem(caller_primed, w.storeInstOrGvInit,
                                             w.length + 1));
                  } else {
                    report_fatal_error(
                        "[IPDSE] expected to enqueue from caller");
                  }
                }
              }
            } else {
              errs() << "Warning: unexpected case during worklist processing "
                     << *I << "\n";
            }
          }
        }
      }

      // Finally, we remove dead instructions and useless global
      // initializers
      for (auto &kv : m_valueMap) {
        if (!kv.second) {
	  if (StoreInst *SI = dyn_cast<StoreInst>(kv.first)) {
	    DSE_LOG(errs() << "[IPDSE] DELETED " << *SI << "\n");
	    SI->eraseFromParent();
	    numUselessStores++;
	  } else if (GlobalVariable *GV = dyn_cast<GlobalVariable>(kv.first)) {
	    DSE_LOG(errs() << "[IPDSE] USELESS INITIALIZER " << *GV << "\n");
	    numUselessGvInit++;
	    // Making the initializer undefined should be ok since we
	    // know that nobody will read from it and this helps
	    // SCCP. However, the bitcode verifier complains about it.
	    // 
	    // GV->setInitializer(UndefValue::get(GV->getInitializer()->getType()));
	    LLVMContext &C = M.getContext();
	    MDNode *N = MDNode::get(C, MDString::get(C, "useless_initializer"));
	    GV->setMetadata("ipdse.useless_initializer", N);
	  }
        }
      }

      errs() << "\tNumber of deleted stores " << numUselessStores << "\n";
      errs() << "\tNumber of useless global initializers " << numUselessGvInit << "\n";
      errs() << "\tSkipped " << skippedChains
             << " def-use chains because they were too long\n";
      errs() << "Finished ip-dse\n";
    }

    // Make sure that we remove all the shadow.mem functions
    DSE_LOG(errs() << "Removing shadow.mem functions ... \n";);
    seadsa::StripShadowMemPass SSMP;
    SSMP.runOnModule(M);

    return (numUselessStores > 0 || numUselessGvInit > 0);
  }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesAll();
    // Required to place shadow.mem.in and shadow.mem.out
    AU.addRequired<llvm::UnifyFunctionExitNodes>();    
    // This pass will instrument the code with shadow.mem calls
    AU.addRequired<seadsa::ShadowMemPass>();
  }

  virtual StringRef getPassName() const override {
    return "Interprocedural Dead Store Elimination";
  }
};

char IPDeadStoreElimination::ID = 0;
}
}

static llvm::RegisterPass<previrt::transforms::IPDeadStoreElimination>
    X("ipdse", "Inter-procedural Dead Store Elimination");
