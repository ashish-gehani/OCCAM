/** 
 * LLVM transformation passes to resolve indirect calls 
 **/

#include "transforms/DevirtFunctions.hh"
#include "llvm/Pass.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Support/raw_ostream.h"
// llvm-dsa 
#include "dsa/CallTargets.h"

namespace previrt {
namespace transforms {  

  using namespace llvm;
  
  class DevirtualizeFunctionsDsaPass:  public ModulePass {
  public:
    
    static char ID;
    
    DevirtualizeFunctionsDsaPass(bool allowIndirectCalls = false)
      : ModulePass(ID)
      , m_allowIndirectCalls(allowIndirectCalls) {}
    
    virtual bool runOnModule(Module& M) override {
      // -- Get the call graph
      CallGraph* CG = &(getAnalysis<CallGraphWrapperPass> ().getCallGraph ());
      
      // -- Access to analysis pass which finds targets of indirect function calls
      LlvmDsaResolver* CTF = &getAnalysis<LlvmDsaResolver>();
      DevirtualizeFunctions DF(CG, m_allowIndirectCalls);
      CallSiteResolver* CSR = new CallSiteResolverByDsa<LlvmDsaResolver>(M, *CTF);
      bool res = DF.resolveCallSites(M, CSR);
      delete CSR;
      return res;
    }
    
    virtual void getAnalysisUsage(AnalysisUsage &AU) const override {
      AU.addRequired<CallGraphWrapperPass>();
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
    bool m_allowIndirectCalls;
  };
  
  char DevirtualizeFunctionsDsaPass::ID = 0;
} // end namespace
} // end namespace

static RegisterPass<previrt::transforms::DevirtualizeFunctionsDsaPass>
X("Pdevirt-functions",
  "Devirtualize indirect function calls");

