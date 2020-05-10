#include "llvm/Pass.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/IRBuilder.h"

/* 
   Passes to add/remove/rename special error function __VERIFIER_error
   used by SV-COMP (https://sv-comp.sosy-lab.org) verification tools.
*/

static llvm::cl::opt<std::string>
FunctionName("Padd-verifier-call-in-function",
       llvm::cl::desc("Function where __VERIFIER_error() is inserted at its entry block"),
       llvm::cl::init(""),
       llvm::cl::Hidden);

using namespace llvm;

namespace previrt {
namespace transforms {
  
  class AddVerifierCalls : public ModulePass {
    Constant* m_errorFn;
    CallGraph* m_cg;
    
  public:

    static char ID;

    AddVerifierCalls()
      : ModulePass (ID)
      , m_errorFn(nullptr)
      , m_cg(nullptr)
    { } 
    
    virtual bool runOnModule (Module &M) {
      CallGraphWrapperPass *cgwp = getAnalysisIfAvailable<CallGraphWrapperPass> ();
      if (cgwp) {
	m_cg = &cgwp->getCallGraph();
      }
      
      m_errorFn = cast<Constant>(M.getOrInsertFunction
				 ("__VERIFIER_error", Type::getVoidTy (M.getContext ())).getCallee());
      
      if (m_cg) {
	m_cg->getOrInsertFunction(cast<Function>(m_errorFn));
      }
      
      bool change = false;
      for (auto &F : M) {
	change |= runOnFunction (F);
      }

      return change;
    }

    virtual bool runOnFunction (Function &F) {
      
      if (F.empty () || F.isDeclaration()) {
	return false;
      }

      if (!F.getName().equals(FunctionName)) {
	return false;
      }

      BasicBlock &entry = F.getEntryBlock();
      IRBuilder<> Builder(F.getContext ());
      Builder.SetInsertPoint(entry.getFirstNonPHI());
      CallInst *call = Builder.CreateCall(m_errorFn);
      if (m_cg) {
	(*m_cg)[&F]->addCalledFunction(cast<CallBase>(call),
                                       (*m_cg)[call->getCalledFunction()]);
      }
      return true;
    }
    
    virtual void getAnalysisUsage (AnalysisUsage &AU) const {
      AU.setPreservesAll ();
      AU.addRequired<CallGraphWrapperPass>();
    }
    
  };
  
  char AddVerifierCalls::ID = 0;

  class RemoveVerifierCalls : public ModulePass {
    Function* m_errorFn;
    CallGraph* m_cg;
    
  public:

    static char ID;

    RemoveVerifierCalls()
      : ModulePass (ID)
      , m_errorFn(nullptr)
      , m_cg(nullptr)
    { } 
    
    virtual bool runOnModule (Module &M) {

      m_errorFn = M.getFunction("__VERIFIER_error");
      if (!m_errorFn) {
	return false;
      }
      
      CallGraphWrapperPass *cgwp = getAnalysisIfAvailable<CallGraphWrapperPass> ();
      if (cgwp) {
	m_cg = &cgwp->getCallGraph();
      }

      bool change = false;
      for (auto &F : M) {
	change |= runOnFunction (F);
      }

      return change;
    }

    virtual bool runOnFunction (Function &F) {
      
      if (F.empty ()) {
	return false;
      }
      
      std::vector<CallInst*> to_remove;
      for (auto &BB: F) {
	for (auto &I: BB) {
	  if (CallInst *CI = dyn_cast<CallInst>(&I)) {
	    CallSite CS(CI);
	    if (Function * callee = CS.getCalledFunction()) {
	      if (callee == m_errorFn) {
		to_remove.push_back(CI);
	      }
	    }
	  }
	}
      }

      if (to_remove.empty()) {
	return false;
      }
      
      if (m_cg) {
	if (CallGraphNode *cgn = m_cg->operator[](m_errorFn)) {
	  cgn->removeAnyCallEdgeTo(cgn);
	}
      }
      
      for (CallInst* CI: to_remove) {
	CI->eraseFromParent();
      }
      
      return true;
    }
    
    virtual void getAnalysisUsage (AnalysisUsage &AU) const {
      AU.setPreservesAll ();
      AU.addRequired<CallGraphWrapperPass>();
    }
    
  };

  char RemoveVerifierCalls::ID = 0;

  class ReplaceVerifierCallWithUnreachableInst : public ModulePass {
    Function* m_errorFn;
    CallGraph* m_cg;
    
  public:

    static char ID;

    ReplaceVerifierCallWithUnreachableInst()
      : ModulePass (ID)
      , m_errorFn(nullptr)
      , m_cg(nullptr)
    { } 
    
    virtual bool runOnModule (Module &M) {

      m_errorFn = M.getFunction("__VERIFIER_error");
      if (!m_errorFn) {
	return false;
      }
      
      CallGraphWrapperPass *cgwp = getAnalysisIfAvailable<CallGraphWrapperPass> ();
      if (cgwp) {
	m_cg = &cgwp->getCallGraph();
      }

      bool change = false;
      for (auto &F : M) {
	change |= runOnFunction (F);
      }

      return change;
    }

    virtual bool runOnFunction (Function &F) {
      
      if (F.empty ()) {
	return false;
      }
      
      std::vector<CallInst*> to_replace;
      for (auto &BB: F) {
	for (auto &I: BB) {
	  if (CallInst *CI = dyn_cast<CallInst>(&I)) {
	    CallSite CS(CI);
	    if (Function * callee = CS.getCalledFunction()) {
	      if (callee == m_errorFn) {
		to_replace.push_back(CI);
	      }
	    }
	  }
	}
      }

      if (to_replace.empty()) {
	return false;
      }

      for (CallInst *CI: to_replace) {
	IRBuilder<> Builder (F.getContext ());
	Builder.SetInsertPoint(CI);
	Builder.CreateAssumption(Builder.getFalse());
	// XXX: we cannot add an UnreachableInst because the CFG would
	// not be well-formed. Adding assume(false) makes the trick.
      }
      return true;
    }
    
    virtual void getAnalysisUsage (AnalysisUsage &AU) const {
      AU.setPreservesAll ();
      AU.addRequired<CallGraphWrapperPass>();
    }
    
  };

  char ReplaceVerifierCallWithUnreachableInst::ID = 0;
  
}
}

static RegisterPass<previrt::transforms::AddVerifierCalls>
X("Padd-verifier-calls", 
  "Add calls to __VERIFIER_error");

static RegisterPass<previrt::transforms::RemoveVerifierCalls>
Y("Premove-verifier-calls", 
  "Remove calls to __VERIFIER_error");

static RegisterPass<previrt::transforms::ReplaceVerifierCallWithUnreachableInst>
Z("Preplace-verifier-calls-with-unreachable", 
  "Replace calls to __VERIFIER_error with unreachable instructions");


