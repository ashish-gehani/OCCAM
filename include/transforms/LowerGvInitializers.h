#pragma once

#include "llvm/IR/Module.h"
#include "llvm/Pass.h"

/**
    Pass to lower scalar initializers to global variables into
    explicit initialization code.
**/

namespace previrt {
namespace transforms {

class LowerGvInitializersPass : public llvm::ModulePass {
public:
  static char ID;

  LowerGvInitializersPass();

  ~LowerGvInitializersPass() override;

  bool runOnModule(llvm::Module &M) override;

  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override;
};
}
}
