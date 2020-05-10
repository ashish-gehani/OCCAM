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
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "seadsa/CompleteCallGraph.hh"

static llvm::cl::opt<unsigned>
MaxNumTargets("Pmax-num-targets",
    llvm::cl::desc("Do not resolve if number of targets is greater than this number."),
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

static llvm::cl::opt<bool>
ResolveIncompleteCalls("Presolve-incomplete-calls",
    llvm::cl::desc("Resolve indirect calls that might still require "
		   "further reasoning about other modules"
		   "(enable this option may be unsound)"),
    llvm::cl::init(false),
    llvm::cl::Hidden);

/**
* It leaves the original indirect call site in the default case of the
* switch statement. Enabling this option may be useful to ensure
* soundness if ResolveIncompleteCalls is enabled.
**/
static llvm::cl::opt<bool>
AllowIndirectCalls("Pallow-indirect-calls",
    llvm::cl::desc("Allow creation of indirect calls "
		   "during devirtualization "
		   "(required for soundness if call cannot be fully resolved)"),   
    llvm::cl::init(false),
    llvm::cl::Hidden);


namespace previrt {
namespace transforms {  

  using namespace llvm;
  
  class DevirtualizeFunctionsDsaPass:  public ModulePass {
  public:
    
    static char ID;
    
    DevirtualizeFunctionsDsaPass()
      : ModulePass(ID) {}
    
    virtual bool runOnModule(Module& M) override {
      // -- Get the call graph
      //CallGraph* CG = &(getAnalysis<CallGraphWrapperPass> ().getCallGraph ());
      
      bool res = false;
      
      // -- Access to analysis pass which finds targets of indirect function calls
      DevirtualizeFunctions DF(/*CG*/ nullptr, AllowIndirectCalls);

      if (ResolveCallsByCHA) {
	CallSiteResolverByCHA CSResolver(M);
	res |= DF.resolveCallSites(M, &CSResolver);	
      }      

      CallSiteResolverBySeaDsa CSResolver(M, getAnalysis<seadsa::CompleteCallGraph>(),
					  ResolveIncompleteCalls, MaxNumTargets);
      res |= DF.resolveCallSites(M, &CSResolver);
      
      return res;
    }
    
    virtual void getAnalysisUsage(AnalysisUsage &AU) const override {
      //AU.addRequired<CallGraphWrapperPass>();
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
  
  char DevirtualizeFunctionsDsaPass::ID = 0;
} // end namespace
} // end namespace

static llvm::RegisterPass<previrt::transforms::DevirtualizeFunctionsDsaPass>
X("Pdevirt", "Devirtualize indirect function calls");

