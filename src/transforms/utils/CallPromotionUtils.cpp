#include "transforms/utils/CallPromotionUtils.hh"
#include "transforms/utils/BasicBlockUtils.hh"

#include "llvm/IR/CallSite.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
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

// Copied from llvm CallPromotionUtils
static void fixupPHINodeForNormalDest(InvokeInst *Invoke, BasicBlock *OrigBlock,
                                      BasicBlock *MergeBlock) {
  for (PHINode &Phi : Invoke->getNormalDest()->phis()) {
    int Idx = Phi.getBasicBlockIndex(OrigBlock);
    if (Idx == -1)
      continue;
    Phi.setIncomingBlock(Idx, MergeBlock);
  }
}

// Copied from llvm CallPromotionUtils
static void fixupPHINodeForUnwindDest(InvokeInst *Invoke, BasicBlock *OrigBlock,
                                      BasicBlock *ThenBlock,
                                      BasicBlock *ElseBlock) {
  for (PHINode &Phi : Invoke->getUnwindDest()->phis()) {
    int Idx = Phi.getBasicBlockIndex(OrigBlock);
    if (Idx == -1)
      continue;
    auto *V = Phi.getIncomingValue(Idx);
    Phi.setIncomingBlock(Idx, ThenBlock);
    Phi.addIncoming(V, ElseBlock);
  }
}

// Copied from llvm CallPromotionUtils
static void createRetPHINode(Instruction *OrigInst, Instruction *NewInst,
                             BasicBlock *MergeBlock, IRBuilder<> &Builder) {

  if (OrigInst->getType()->isVoidTy() || OrigInst->use_empty())
    return;

  Builder.SetInsertPoint(&MergeBlock->front());
  PHINode *Phi = Builder.CreatePHI(OrigInst->getType(), 0);
  SmallVector<User *, 16> UsersToUpdate;
  for (User *U : OrigInst->users())
    UsersToUpdate.push_back(U);
  for (User *U : UsersToUpdate)
    U->replaceUsesOfWith(OrigInst, Phi);
  Phi->addIncoming(OrigInst, OrigInst->getParent());
  Phi->addIncoming(NewInst, NewInst->getParent());
}

static void specializeCallFunctionPtrArg(CallSite &CS, unsigned ArgNo,
                                         Value *Callee) {
  auto *Arg = CS.getArgument(ArgNo);
  if (Arg->getType() != Callee->getType()) {
    Callee = CastInst::CreateBitOrPointerCast(Callee, Arg->getType(), "",
                                              CS.getInstruction());
  }
  CS.setArgument(ArgNo, Callee);
}

// Code very similar to CallPromotionUtils::versionCallSite. The
// difference is that we don't split on CS.getCalledCallue() but
// instead on CS.getArgument(ArgNo).
static Instruction *versionCallSite(CallSite CS, unsigned ArgNo, Value *Callee,
                                    MDNode *BranchWeights) {
  IRBuilder<> Builder(CS.getInstruction());
  Instruction *OrigInst = CS.getInstruction();
  BasicBlock *OrigBlock = OrigInst->getParent();

  // Create the compare. The CS.getArgument(ArgNo) value and callee must
  // have the same type to be compared.
  if (CS.getArgument(ArgNo)->getType() != Callee->getType())
    Callee = Builder.CreateBitCast(Callee, CS.getArgument(ArgNo)->getType());
  auto *Cond = Builder.CreateICmpEQ(CS.getArgument(ArgNo), Callee);

  // Create an if-then-else structure. The original instruction is moved into
  // the "else" block, and a clone of the original instruction is placed in the
  // "then" block.
  Instruction *ThenTerm = nullptr;
  Instruction *ElseTerm = nullptr;
  SplitBlockAndInsertIfThenElse(Cond, CS.getInstruction(), &ThenTerm, &ElseTerm,
                                BranchWeights);
  BasicBlock *ThenBlock = ThenTerm->getParent();
  BasicBlock *ElseBlock = ElseTerm->getParent();
  BasicBlock *MergeBlock = OrigInst->getParent();

  ThenBlock->setName("if.true.specialize_funcptr");
  ElseBlock->setName("if.false.specialize_funcptr");
  MergeBlock->setName("if.end.specialize_funcptr");

  Instruction *NewInst = OrigInst->clone();
  OrigInst->moveBefore(ElseTerm);
  NewInst->insertBefore(ThenTerm);

  // If the original call site is an invoke instruction, we have extra work to
  // do since invoke instructions are terminating. We have to fix-up phi nodes
  // in the invoke's normal and unwind destinations.
  if (auto *OrigInvoke = dyn_cast<InvokeInst>(OrigInst)) {
    auto *NewInvoke = cast<InvokeInst>(NewInst);

    // Invoke instructions are terminating, so we don't need the terminator
    // instructions that were just created.
    ThenTerm->eraseFromParent();
    ElseTerm->eraseFromParent();

    // Branch from the "merge" block to the original normal destination.
    Builder.SetInsertPoint(MergeBlock);
    Builder.CreateBr(OrigInvoke->getNormalDest());

    // Fix-up phi nodes in the original invoke's normal and unwind destinations.
    fixupPHINodeForNormalDest(OrigInvoke, OrigBlock, MergeBlock);
    fixupPHINodeForUnwindDest(OrigInvoke, MergeBlock, ThenBlock, ElseBlock);

    // Now set the normal destinations of the invoke instructions to be the
    // "merge" block.
    OrigInvoke->setNormalDest(MergeBlock);
    NewInvoke->setNormalDest(MergeBlock);
  }

  // Create a phi node for the returned value of the call site.
  createRetPHINode(OrigInst, NewInst, MergeBlock, Builder);

  return NewInst;
}

void specializeCallFunctionPtrArg(CallSite &CS, unsigned ArgNo,
                                  const std::vector<Function *> &Callees) {
  for (unsigned i = 0, numCallees = Callees.size(); i < numCallees; ++i) {
    // The last callee does not create an "else" block
    // If there is only one callee we don't create an "else" block either.
    if (i == numCallees - 1) {
      specializeCallFunctionPtrArg(CS, ArgNo, Callees[i]);
    } else {
      Function *ArgV = Callees[i];
      versionCallSite(CS, ArgNo, ArgV, nullptr);
      specializeCallFunctionPtrArg(CS, ArgNo, ArgV);
    }
  }
}

} // end namespace transforms
} // end namespace previrt
