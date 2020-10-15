#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

static llvm::cl::list<std::string>
    function_list("remove-function-list",
                  llvm::cl::desc("Functions to remove"),
                  llvm::cl::ZeroOrMore);
/*
 * Remove a function and add a runtime check in case the function is called. 
 * The function is removed by replacing the body a function with 
 *
 *    printf("You asked to remove this function. Program terminating!\n");
 *    call exit(1);
 *    unreachable;
 * 
 * and marking the function as "inline" so that it's inlined later.
 */

namespace previrt {
namespace transforms {

using namespace llvm;
using namespace std;

struct RemoveFunction : public ModulePass {

  Function *makePrintf(Module &M) {
    LLVMContext &ctx = M.getContext();
    Type *charPtrType = Type::getInt8PtrTy(ctx);
    Type *int32Type = Type::getInt32Ty(ctx);

    FunctionType *printf_type = FunctionType::get(int32Type, {charPtrType}, true);
    Function *printf = cast<Function>(
        M.getOrInsertFunction("printf", printf_type).getCallee());
    assert(printf && "printf not found in module");
    return printf;
  }

  Function *makeExit(Module &M) {
    LLVMContext &ctx = M.getContext();
    Type *voidType = Type::getVoidTy(ctx);
    Type *int32Type = Type::getInt32Ty(ctx);
    
    FunctionType *exitType = FunctionType::get(voidType, {int32Type}, false);
    Function *exit = dyn_cast<Function>(
        M.getOrInsertFunction("exit", exitType).getCallee());
    assert(exit && "exitFunc not found in module");
    return exit;
  }

  static char ID;
  
  RemoveFunction() : ModulePass(ID) {}

  void getAnalysisUsage(AnalysisUsage &AU) const override {}
  
  bool runOnModule(Module &M) override {
    bool change = false;
    for (auto &F: M) {
      if (!F.empty()) {
	if (std::find(function_list.begin(), function_list.end(), F.getName()) !=
	    function_list.end()) {
	  change |= runOnFunction(F);
	}
      }
    }
    return change;
  }
  
  bool runOnFunction(Function &F) {
    errs() << "\nUser asked to remove " << F.getName() << "\n";
    BasicBlock *entryBB = &F.getEntryBlock();
    Module &M = *(F.getParent());      
    BasicBlock *emptyBB = BasicBlock::Create(M.getContext(), "empty");
    emptyBB->insertInto(&F, entryBB);
    IRBuilder<> Builder(emptyBB);
    
    // Add printf call in empty BB
    Value *str = Builder.CreateGlobalStringPtr(
          "You asked to remove this function. Program terminating!\n", "str");
    std::vector<Value *> removeMessage({str});
    Function *printfFunc = makePrintf(M);
    Builder.CreateCall(printfFunc, removeMessage);
    
    // Add exit call in empty BB
    Value *status =
      ConstantInt::get(Type::getInt32Ty(M.getContext()), (-10));
    Function *exitFunc = makeExit(M);
    Builder.CreateCall(exitFunc, status, "");
    Type *returnType = F.getReturnType();
    
    // Add terminator instruction
    Builder.CreateUnreachable();
    
    // Removing the Basic blocks
    for (Function::iterator b = F.begin(), be = F.end(); b != be;) {
      BasicBlock *BB = &*b;
      ++b;
      
      if (BB != emptyBB)
	BB->eraseFromParent();
    }

    if (F.getName() != "main") {
      // Mark the function as "inline"
      F.removeFnAttr(Attribute::NoInline);
      F.removeFnAttr(Attribute::OptimizeNone);
      F.addFnAttr(Attribute::AlwaysInline);
    }
    
    return true;
  }
};

char RemoveFunction::ID = 0;
static llvm::RegisterPass<previrt::transforms::RemoveFunction>
    X("Premove-function",
      "Remove a function and add a runtime check in case the function is executed");
} // namespace transforms
} // namespace previrt

// static llvm::RegisterStandardPasses
//     Y(llvm::PassManagerBuilder::EP_EarlyAsPossible,
//       [](const llvm::PassManagerBuilder &Builder,
//          llvm::legacy::PassManagerBase &PM) {
//         PM.add(new previrt::transforms::RemoveFunction());
//       });
