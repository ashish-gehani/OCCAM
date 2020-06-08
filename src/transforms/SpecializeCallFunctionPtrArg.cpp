#include "llvm/Analysis/CallGraph.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

#include "seadsa/Global.hh"
#include "seadsa/Graph.hh"
#include "seadsa/InitializePasses.hh"

#include "transforms/utils/CallPromotionUtils.hh"

#include <memory>
#include <vector>

namespace previrt {
namespace transforms {

/*
Transform a call "foo(fptr, ....)" where fptr is a function pointer to:
      if (fptr == fn_1) {
         foo(fn_1, ...);
      } else if (fptr == fn_2) {
         foo(fn_2, ...);
      }  else {
         foo(fn_N, ...);
      }

where fn_1,fn_2,...,fn_N are the possible function addresses to
      which ptr might point to.
*/
class SpecializeCallFunctionPtrArg {
  seadsa::GlobalAnalysis &m_seadsa;
  bool m_onlyExternalCalls;

public:
  SpecializeCallFunctionPtrArg(seadsa::GlobalAnalysis &dsa,
                               bool onlyExternalCalls)
      : m_seadsa(dsa), m_onlyExternalCalls(onlyExternalCalls) {}

  bool runOnModule(llvm::Module &M);
};

class SpecializeCallFunctionPtrArgPass : public llvm::ModulePass {
public:
  static char ID;
  SpecializeCallFunctionPtrArgPass();
  bool runOnModule(llvm::Module &M) override;
  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override;
};

class SpecializeExternCallFunctionPtrArgPass : public llvm::ModulePass {
public:
  static char ID;
  SpecializeExternCallFunctionPtrArgPass();
  bool runOnModule(llvm::Module &M) override;
  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override;
};

} // namespace transforms
} // namespace previrt

namespace previrt {
namespace transforms {

using namespace llvm;
using namespace seadsa;

static bool isFunctionPtrType(const Type *ty) {
  if (const PointerType *PTy = dyn_cast<PointerType>(ty)) {
    return isa<FunctionType>(PTy->getElementType());
  }
  return false;
}

bool SpecializeCallFunctionPtrArg::runOnModule(Module &M) {
  // When this pass is called, -Pdevirt has been already called.

  if (M.empty()) {
    return false;
  }

  std::vector<std::pair<llvm::Instruction *, unsigned>> worklist;

  // Add in the worklist any callsite whose parameter is a function
  // pointer.
  for (auto &F : M) {
    for (inst_iterator I = inst_begin(F), E = inst_end(F); I != E; ++I) {
      CallSite CS(&*I);
      if (CS.getInstruction() && !CS.isIndirectCall()) {

        if (m_onlyExternalCalls) {
          if (Function *calleeF = CS.getCalledFunction()) {
            if (!calleeF->isDeclaration() || calleeF->isIntrinsic()) {
              continue;
            }
          }
        }

        for (unsigned i = 0, num_args = CS.arg_size(); i < num_args; ++i) {
          if (isFunctionPtrType(CS.getArgument(i)->getType())) {
	    if (!isa<Function>(CS.getArgument(i))) {
	      // if already a known function we skip it.
	      errs() << "[SpecializeCallFunctionPtrArg] Added "
		     << *CS.getInstruction() << " to the worklist\n";
	      worklist.push_back({CS.getInstruction(), i});
	    } else {
	      errs() << " [SpecializeCallFunctionPtrArg] argument " << i << " of "
		     << *CS.getInstruction() << " already known\n";
	    }
          }
        }
      }
    }
  }

  // Process the worklist
  bool Change = false;
  while (!worklist.empty()) {
    auto p = worklist.back();
    worklist.pop_back();
    CallSite CS(p.first);
    Value *ArgV = CS.getArgument(p.second);

    // Ask m_seadsa the possible allocation sites associated to the
    // function pointer
    Function &FParent = *(p.first->getParent()->getParent());
    if (m_seadsa.hasGraph(FParent)) {
      seadsa::Graph &G = m_seadsa.getGraph(FParent);
      if (G.hasCell(*ArgV)) {
        const seadsa::Cell &C = G.getCell(*ArgV);
	if (!C.getNode()->isExternal()) {
	  std::vector<Function*> Callees;
	  for (const Value *AS : C.getNode()->getAllocSites()) {
	    if (const Function *F = dyn_cast<const Function>(AS)) {
	      // XXX: remove constness
	      Callees.push_back(const_cast<Function *>(F));
	    }
	  }
	  
	  errs() << "[SpecializeCallFunctionPtrArg] Callsite= "
		 << *(CS.getInstruction()) << ". Replaced argument=" << p.second
		 << " with values={";
	  for (unsigned i=0, sz=Callees.size(); i<sz;) {
	    errs() << Callees[i]->getName();
	    ++i;
	    if (i < sz) {
	      errs() << ",";
	    }
	  }
	  errs() << "}\n";
	  
	  specializeCallFunctionPtrArg(CS, p.second, Callees);
	  Change = true;
	}
      }
    }
  }
  return Change;
}

/** Begin SpecializeCallFunctionPtrArgPass **/
void SpecializeCallFunctionPtrArgPass::getAnalysisUsage(
    AnalysisUsage &AU) const {
  AU.addRequired<seadsa::BottomUpTopDownGlobalPass>();
}

bool SpecializeCallFunctionPtrArgPass::runOnModule(Module &M) {
  auto &seadsa = getAnalysis<BottomUpTopDownGlobalPass>().getGlobalAnalysis();
  SpecializeCallFunctionPtrArg SCFA(seadsa, false /* specialize all calls */);
  return SCFA.runOnModule(M);
}

SpecializeCallFunctionPtrArgPass::SpecializeCallFunctionPtrArgPass()
    : ModulePass(ID) {
  auto &Registry = *llvm::PassRegistry::getPassRegistry();
  llvm::initializeDsaAnalysisPass(Registry);
  llvm::initializeCompleteCallGraphPass(Registry);  
}

char SpecializeCallFunctionPtrArgPass::ID = 0;

/** End SpecializeCallFunctionPtrArgPass **/

/** Begin SpecializeExternCallFunctionPtrArgPass **/
void SpecializeExternCallFunctionPtrArgPass::getAnalysisUsage(
    AnalysisUsage &AU) const {
  AU.addRequired<seadsa::BottomUpTopDownGlobalPass>();
}

bool SpecializeExternCallFunctionPtrArgPass::runOnModule(Module &M) {
  auto &seadsa = getAnalysis<BottomUpTopDownGlobalPass>().getGlobalAnalysis();
  SpecializeCallFunctionPtrArg SCFA(seadsa,
                                    true /* specialize only external calls */);
  return SCFA.runOnModule(M);
}

SpecializeExternCallFunctionPtrArgPass::SpecializeExternCallFunctionPtrArgPass()
    : ModulePass(ID) {
  auto &Registry = *llvm::PassRegistry::getPassRegistry();
  llvm::initializeDsaAnalysisPass(Registry);
  llvm::initializeCompleteCallGraphPass(Registry);
}

char SpecializeExternCallFunctionPtrArgPass::ID = 0;

/** End SpecializeExternCallFunctionPtrArgPass **/

} // namespace transforms
} // namespace previrt

static llvm::RegisterPass<previrt::transforms::SpecializeCallFunctionPtrArgPass>
    X("Pspecialize-call-function-ptr-arg",
      "Specialize all direct callsites with function pointer parameters");

static llvm::RegisterPass<
    previrt::transforms::SpecializeExternCallFunctionPtrArgPass>
    Y("Pspecialize-extern-call-function-ptr-arg",
      "Specialize external calls with function pointer parameters");
