#pragma once

namespace llvm {
  class BasicBlock;
  class LLVMContext;
} // end namespace llvm

namespace previrt {
namespace transforms {
  
void removeBlock(llvm::BasicBlock *BB, llvm::LLVMContext &Ctx);
 
} // end namespace
} // end namespace 
