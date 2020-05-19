#include "transforms/utils/CallPromotionUtils.hh"
#include "transforms/utils/BasicBlockUtils.hh"

#include "llvm/IR/CallSite.h"
#include "llvm/IR/Function.h"
#include "llvm/Transforms/Utils/CallPromotionUtils.h"

using namespace llvm;

namespace previrt {
namespace transforms {
  
void promoteCallWithMultipleCallees(CallSite &CS, const std::vector<Function*> &Callees) {
  for (unsigned i=0,sz=Callees.size();i<sz;++i) {
    llvm::promoteCallWithIfThenElse(CS, Callees[i]);
  }
  
  // Remove the original callsite by removing its parent
  BasicBlock *b = CS.getInstruction()->getParent();
  removeBlock(b, CS.getInstruction()->getContext());
}

} // end namespace transforms
} // end namespace previrt 
  
