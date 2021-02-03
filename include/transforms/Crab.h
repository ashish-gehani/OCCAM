#pragma once

#include "llvm/Pass.h"
#include "llvm/ADT/StringRef.h"

/**
 * Use Crab (abstract interpreter) invariants to optimize llvm bitcode.
 **/
namespace previrt {
namespace transforms {
class CrabPass : public llvm::ModulePass {
public:
  static char ID;
  CrabPass();
  virtual bool runOnModule(llvm::Module &M) override;
  virtual void getAnalysisUsage(llvm::AnalysisUsage &AU) const override;
  virtual llvm::StringRef getPassName() const override {
    return "Crab Pass: use Crab invariants to simplify code";
  }
};
} // end namespace
} // end namespace
