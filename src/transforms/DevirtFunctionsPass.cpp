/** 
 * LLVM transformation passes to resolve indirect calls 
 **/

#include "transforms/DevirtFunctions.hh"
#include "dsa/CallTargets.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace previrt {
namespace transforms {  

  /* Resolver indirect calls using aliasing and types */
  class DevirtualizeFunctionsDsaPass:  public ModulePass {
    bool m_allowIndirectCalls;

    class DsaResolver: public CallSiteResolver {
      dsa::CallTargetFinder<EQTDDataStructures>* m_CTF;
      TargetMap m_TM;

      bool isIndirectCall(CallSite &CS) {
	Value *v = CS.getCalledValue ();
	if (!v) return false;
	v = v->stripPointerCasts ();
	return !isa<Function> (v);
      }
      
    public:
      
      DsaResolver(dsa::CallTargetFinder<EQTDDataStructures>* CTF, Module& M)
	: CallSiteResolver()
	, m_CTF(CTF) {

	// build the target map
	for (auto &F: M) {
	  for (auto &BB: F) {
	    for (auto &I: BB) {
	      Instruction *CI= nullptr;
	      if (isa<CallInst>(&I)) {
		CI = &I;
	      }
	      if (!CI && isa<InvokeInst>(&I)) {
		CI = &I;
	      }
	      if (CI) {
		CallSite CS(CI);
		if (isIndirectCall(CS)) {
		  if (m_CTF->isComplete(CS)) {
		    m_TM[CI].append(CTF->begin(CS), CTF->end(CS));
		  } 
		}
	      }
	    }
	  }
	}
      }
  
      bool useAliasing() const {
	return true;
      }
      
      bool hasTargets(const llvm::Instruction* CS) const {
	return (m_TM.find(CS) != m_TM.end());
      }
      
      AliasSet& getTargets(const llvm::Instruction* CS) {
	assert(hasTargets(CS));
	auto it = m_TM.find(CS);
	return it->second;
      }
      
      const AliasSet& getTargets(const llvm::Instruction* CS) const {
	assert(hasTargets(CS));
	auto it = m_TM.find(CS);
	return it->second;
      }
    };
    
  public:
    
    static char ID;
    
    DevirtualizeFunctionsDsaPass(bool allowIndirectCalls = false)
      : ModulePass(ID)
      , m_allowIndirectCalls(allowIndirectCalls) {}
    
    virtual bool runOnModule(Module & M) override {
      // -- Get the call graph
      CallGraph* CG = &(getAnalysis<CallGraphWrapperPass> ().getCallGraph ());
      
      // -- Access to analysis pass which finds targets of indirect function calls
      dsa::CallTargetFinder<EQTDDataStructures> *CTF =
	&getAnalysis<dsa::CallTargetFinder<EQTDDataStructures>>();
      
      DevirtualizeFunctions DF(CG, m_allowIndirectCalls);
      CallSiteResolver* CSR = new DsaResolver(CTF, M);  
      bool res = DF.resolveCallSites(M, CSR);
      delete CSR;
      return res;
    }
    
    virtual void getAnalysisUsage(AnalysisUsage &AU) const override {
      AU.addRequired<CallGraphWrapperPass>();
      AU.addRequired<dsa::CallTargetFinder<EQTDDataStructures>>();
      // FIXME: DevirtualizeFunctions does not fully update the call
      // graph so we don't claim it's preserved.
      // AU.setPreservesAll();
      // AU.addPreserved<CallGraphWrapperPass>();
    }
    
    virtual StringRef getPassName() const override {
      return "Devirtualize indirect calls using aliasing and types";
    }
  };
  
  char DevirtualizeFunctionsDsaPass::ID = 0;
} // end namespace
} // end namespace

static RegisterPass<previrt::transforms::DevirtualizeFunctionsDsaPass>
X("devirt-functions-aliasing",
  "Devirtualize indirect function calls using aliasing and types");

