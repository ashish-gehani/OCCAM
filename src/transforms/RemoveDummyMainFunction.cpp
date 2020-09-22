/**
 * LLVM transformation pass to remove the 'Dummy' main function
 * created in DummyMainFunction.cpp . This would essentially revert
 * back the module into a library bitcode (i.e. one with no main function).
 * The resultant bitcode would be a specialized bitcode according to
 * user-specified entry-point functions and could be linked to any module
 * which uses those entry-points.
 **/

#include "llvm/Pass.h"
#include "llvm/IR/MDBuilder.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "seadsa/CompleteCallGraph.hh"
#include "seadsa/InitializePasses.hh"

namespace previrt {
namespace transforms {

using namespace llvm;

/*
 * Remove Non-Dummy main function
 */
class RemoveDummyMainFunction : public ModulePass {
public:
  static char ID;

  RemoveDummyMainFunction() : ModulePass(ID) {}

  virtual bool runOnModule(Module &M) override {

    Function *Main = M.getFunction("main");
    
    // Can't remove main function if it doesn't exist
    if (!Main) {
      errs() << "RemoveDummyMainFunction: Main doesn't exist already \n";
      return false;
    }

    // If the main exists but is not a 'Dummy' main created in
    // DummyMainFunction.cpp then abort
    if (!Main->hasMetadata() || !(Main->getMetadata("dummy.metadata"))) {
      errs() << "Module has no Dummy Main Function, exiting...\n";
      return false;
    }

    Main->eraseFromParent();

    // Remove any leftover verifier.nondet. function declarations
    for (auto fi = M.begin(), fe = M.end(); fi != fe;) {
      Function *F = &*fi;
      fi++;
      if (F->getName().startswith("verifier.nondet.")) {
        errs() << "Non det leftover:\t" << F->getName() << "\n";
        F->eraseFromParent();
      }
    }

    return true;
  }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const override {
    // We don't preserve the call graph
    // AU.setPreservesAll();
  }

  virtual StringRef getPassName() const override {
    return "Remove Main Function from Bitcode";
  }
};

char RemoveDummyMainFunction::ID = 0;

} // namespace transforms
} // namespace previrt

static llvm::RegisterPass<previrt::transforms::RemoveDummyMainFunction>
    X("PremoveMain",
      "Convert a program bitcode into a library module by removing the main "
      "function",
      false, false);
