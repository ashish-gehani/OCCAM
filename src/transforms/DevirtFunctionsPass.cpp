/** 
 * LLVM transformation passes to resolve indirect calls 
 **/

#include "transforms/DevirtFunctions.hh"
#include "llvm/Pass.h"
//#include "llvm/Analysis/CallGraph.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
// llvm-dsa 
#include "dsa/CallTargets.h"


static llvm::cl::opt<bool>
PAllowIndirectCalls("Pallow-indirect-calls",
		    llvm::cl::desc("Allow creation of indirect calls "
				   "during devirtualization "
				   "(required for soundness)"),
		    llvm::cl::init(false));

static llvm::cl::opt<bool>
PResolveIncompleteCalls("Presolve-incomplete-calls",
		       llvm::cl::desc("Resolve indirect calls that might still require "
				      "reasoning about other modules"
				      "(required for soundness)"),
		       llvm::cl::init(false));

static llvm::cl::opt<unsigned>
PMaxNumTargets("Pmax-num-targets",
	       llvm::cl::desc("Do not resolve if number of targets is greater than this number."),
	       llvm::cl::init(9999));

static llvm::cl::opt<bool>
PResolveCallsByCHA("Pdevirt-with-cha",
		   llvm::cl::desc("Resolve virtual calls by using CHA "
				  "(useful for C++ programs)"),
		   llvm::cl::init(false));

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
       
      // -- Access to analysis pass which finds targets of indirect function calls
      LlvmDsaResolver* CTF = &getAnalysis<LlvmDsaResolver>();
      DevirtualizeFunctions DF(/*CG*/ nullptr, PAllowIndirectCalls);

      CallSiteResolver* CSR = nullptr;
      bool res = false;
      
      if (PResolveCallsByCHA) {
	CallSiteResolverByCHA csr_cha(M);
	CSR = &csr_cha;
	res |= DF.resolveCallSites(M, CSR);
      }

      CallSiteResolverByDsa<LlvmDsaResolver> csr_dsa(M, *CTF,
      						     PResolveIncompleteCalls, PMaxNumTargets);
      CSR = &csr_dsa;
      res |= DF.resolveCallSites(M, CSR);
      return res;
    }
    
    virtual void getAnalysisUsage(AnalysisUsage &AU) const override {
      //AU.addRequired<CallGraphWrapperPass>();
      AU.addRequired<LlvmDsaResolver>();
      // FIXME: DevirtualizeFunctions does not fully update the call
      // graph so we don't claim it's preserved.
      // AU.setPreservesAll();
      // AU.addPreserved<CallGraphWrapperPass>();
    }
    
    virtual StringRef getPassName() const override {
      return "Devirtualize indirect calls";
    }
    
  private:
    using LlvmDsaResolver = dsa::CallTargetFinder<EQTDDataStructures>;
  };
  
  char DevirtualizeFunctionsDsaPass::ID = 0;
} // end namespace
} // end namespace

static RegisterPass<previrt::transforms::DevirtualizeFunctionsDsaPass>
X("Pdevirt",
  "Devirtualize indirect function calls");

