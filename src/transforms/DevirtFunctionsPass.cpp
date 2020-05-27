/**
 * LLVM transformation pass to resolve indirect calls
 *
 * The transformation performs "devirtualization" which consists of
 * looking for indirect function calls and transforming them into a
 * switch statement that selects one of several direct function calls
 * to execute. Devirtualization happens if a pointer analysis can
 * resolve the indirect calls and compute all possible callees.
 **/

#include "transforms/DevirtFunctions.hh"
#include "llvm/Pass.h"
//#include "llvm/Analysis/CallGraph.h"
#include "llvm/IR/MDBuilder.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "seadsa/CompleteCallGraph.hh"
#include "seadsa/InitializePasses.hh"

static llvm::cl::opt<unsigned> MaxNumTargets(
    "Pmax-num-targets",
    llvm::cl::desc(
        "Do not resolve if number of targets is greater than this number."),
    llvm::cl::init(9999));

/*
* Resolve first C++ virtual calls by using a Class Hierarchy Analysis (CHA)
* before using seadsa.
**/
static llvm::cl::opt<bool>
    ResolveCallsByCHA("Pdevirt-with-cha",
                      llvm::cl::desc("Resolve virtual calls by using CHA "
                                     "(useful for C++ programs)"),
                      llvm::cl::init(false));

static llvm::cl::opt<bool> ResolveIncompleteCalls(
    "Presolve-incomplete-calls",
    llvm::cl::desc("Resolve indirect calls that might still require "
                   "further reasoning about other modules"
                   "(enable this option may be unsound)"),
    llvm::cl::init(false), llvm::cl::Hidden);

namespace previrt {
namespace transforms {

using namespace llvm;

/** Resolve indirect calls by adding bounce (trampoline) functions **/
class DevirtualizeFunctionsPass : public ModulePass {
public:
  static char ID;

  DevirtualizeFunctionsPass() : ModulePass(ID) {
    // Initialize sea-dsa pass
    llvm::PassRegistry &Registry = *llvm::PassRegistry::getPassRegistry();
    llvm::initializeCompleteCallGraphPass(Registry);
  }

  virtual bool runOnModule(Module &M) override {
    // -- Get the call graph
    // CallGraph* CG = &(getAnalysis<CallGraphWrapperPass> ().getCallGraph ());

    bool res = false;

    // -- Access to analysis pass which finds targets of indirect function calls
    DevirtualizeFunctions DF(/*CG*/ nullptr);

    if (ResolveCallsByCHA) {
      CallSiteResolverByCHA CSResolver(M);
      res |= DF.resolveCallSites(M, &CSResolver);
    }

    CallSiteResolverBySeaDsa CSResolver(
        M, getAnalysis<seadsa::CompleteCallGraph>(), ResolveIncompleteCalls,
        MaxNumTargets);
    res |= DF.resolveCallSites(M, &CSResolver);

    return res;
  }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const override {
    // AU.addRequired<CallGraphWrapperPass>();
    AU.addRequired<seadsa::CompleteCallGraph>();
    // FIXME: DevirtualizeFunctions does not fully update the call
    // graph so we don't claim it's preserved.
    // AU.setPreservesAll();
    // AU.addPreserved<CallGraphWrapperPass>();
  }

  virtual StringRef getPassName() const override {
    return "Devirtualize indirect calls";
  }
};

// Currently unused but it might be useful in the future.
/** Annotate indirect calls with all possible callees.
 *
 *  For a given call site, the metadata, if present, indicates the
 *  set of functions the call site could possibly target at
 *  run-time.
 **/
class AnnotateIndirectCalls : public ModulePass {
public:
  static char ID;

  AnnotateIndirectCalls() : ModulePass(ID) {
    // Initialize sea-dsa pass
    llvm::PassRegistry &Registry = *llvm::PassRegistry::getPassRegistry();
    llvm::initializeCompleteCallGraphPass(Registry);
  }

  virtual bool runOnModule(Module &M) override {
    bool change = false;

    CallSiteResolverBySeaDsa CallSiteResolver(
        M, getAnalysis<seadsa::CompleteCallGraph>(), ResolveIncompleteCalls,
        MaxNumTargets);
    MDBuilder MDB(M.getContext());

    for (auto &F : M) {
      for (auto &B : F) {
        for (auto &I : B) {
          if (isa<CallInst>(I) || isa<InvokeInst>(I)) {
            CallSite CS(&I);
            if (CS.isIndirectCall()) {
              const SmallVector<const Function *, 16> *Targets =
                  CallSiteResolver.getTargets(CS);
              if (Targets) {
                std::vector<Function *> Callees;
                // remove constness
                for (const Function *CalleeF : *Targets) {
                  Callees.push_back(const_cast<Function *>(CalleeF));
                }
                MDNode *MDCallees = MDB.createCallees(Callees);
                I.setMetadata(LLVMContext::MD_callees, MDCallees);
                change = true;
              }
            }
          }
        }
      }
    }
    return change;
  }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<seadsa::CompleteCallGraph>();
    AU.setPreservesAll();
  }

  virtual StringRef getPassName() const override {
    return "Annotate indirect calls with all possible callees";
  }
};

char DevirtualizeFunctionsPass::ID = 0;
char AnnotateIndirectCalls::ID = 0;

} // end namespace
} // end namespace

static llvm::RegisterPass<previrt::transforms::DevirtualizeFunctionsPass>
    X("Pdevirt",
      "Devirtualize indirect function calls by adding bounce functions");

static llvm::RegisterPass<previrt::transforms::AnnotateIndirectCalls>
    Y("Pannotate-indirect-calls",
      "Annotate indirect calls with metadata listing all possible callees");
