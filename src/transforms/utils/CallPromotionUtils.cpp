#include "transforms/utils/CallPromotionUtils.hh"
#include "transforms/utils/BasicBlockUtils.hh"

#include "llvm/IR/CallSite.h"
#include "llvm/IR/Function.h"
#include "llvm/Transforms/Utils/CallPromotionUtils.h"

using namespace llvm;

namespace previrt {
namespace transforms {
///
/// Create a sequence of if-then-else statements at the location of
/// the callsite.  The "if" condition compares the callsite's called
/// value with a function f from Callees.  The direct call to f is
/// moved to the "then" block. The "else" block contains the next
/// "if". For the last callsite's called value we don't create an
/// "else" block.
///
/// For example, the call instruction below:
///
///   orig_bb:
///     %t0 = call i32 %ptr()  with callees = {foo, bar}
///     ...
///
/// Is replaced by the following:
///
///   orig_bb:
///     %cond = icmp eq i32 ()* %ptr, @foo
///     br i1 %cond, %then_bb, %else_bb
///
///   then_bb:
///     %t1 = call i32 @foo()
///     br merge_bb
///
///   else_bb:
///     %t0 = call i32 %bar()
///     br merge_bb
///
///   merge_bb:
///     ; Uses of the original call instruction are replaced by uses of the phi
///     ; node.
///     %t2 = phi i32 [ %t0, %else_bb ], [ %t1, %then_bb ]
///     ...
///
void promoteIndirectCall(CallSite &CS, const std::vector<Function *> &Callees) {
  for (unsigned i = 0, numCallees = Callees.size(); i < numCallees; ++i) {
    // The last callee does not create an "else" block
    // If there is only one callee we don't create an "else" block either.
    if (i == numCallees - 1) {
      llvm::promoteCall(CS, Callees[i]);
    } else {
      llvm::promoteCallWithIfThenElse(CS, Callees[i]);
    }
  }
}

} // end namespace transforms
} // end namespace previrt
