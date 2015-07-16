// This pass performs function inlining, loop peeling, load forwarding and dead instruction elimination
// in concert. All analysis is performed by HypotheticalConstantFolder; this pass is solely responsbible for
// taking user input regarding what will be integrated (perhaps showing a GUI for this purpose) and actually
// committing the results to the module under consideration.

#define DEBUG_TYPE "integrator"

#include "llvm/Pass.h"
#include "llvm/IR/Module.h"
#include "llvm/Analysis/LLPE.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/CommandLine.h"

#include <errno.h>
#include <string.h>

using namespace llvm;

// For communication with wxWidgets, since there doesn't seem to be any easy way
// of passing a parameter to WxApp's constructor.
static LLPEAnalysisPass* IHP;
static bool IntegratorCancelled = false;

static cl::opt<bool> AcceptAllInt("integrator-accept-all", cl::init(false));

namespace {

  class LLPEPass : public ModulePass {
  public:

    static char ID;
    LLPEPass() : ModulePass(ID) {}

    bool runOnModule(Module& M);

    virtual void getAnalysisUsage(AnalysisUsage &AU) const;

  };

}

char LLPEPass::ID = 0;
static RegisterPass<LLPEPass> X("llpe", "LLPE Partial Evaluation",
				      false /* Only looks at CFG */,
				      false /* Analysis Pass */);

// Implement a GUI for leafing through integration results


bool LLPEPass::runOnModule(Module& M) {

  IHP = &getAnalysis<LLPEAnalysisPass>();
  IHP->commit();

  return false;

}

void LLPEPass::getAnalysisUsage(AnalysisUsage& AU) const {

  IHPSaveDOTFiles = !AcceptAllInt;
  AU.addRequired<LLPEAnalysisPass>();

}


