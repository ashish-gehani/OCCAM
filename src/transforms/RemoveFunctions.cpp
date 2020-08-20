#include "llvm/Pass.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/Analysis/InstructionSimplify.h"
#include "llvm/IR/Module.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Operator.h"
#include "llvm/Analysis/MemoryDependenceAnalysis.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Transforms/Utils/SimplifyLibCalls.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/ValueMap.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include <string.h>
#include <fstream>
#include <sstream>
#include <iostream>

static llvm::cl::list<std::string> function_list("functions_to_remove", llvm::cl::desc ("entry point for function removing pass"),llvm::cl::ZeroOrMore);

namespace previrt {
namespace transforms {

using namespace llvm;
using namespace std;

struct RemoveFunctions : public FunctionPass {
	
	Function* makePrintf (Module* module){

		Type* charType = Type::getInt8PtrTy(module->getContext());
                FunctionType *printf_type = FunctionType::get(charType,true);
                Function *printf = cast<Function>(module->getOrInsertFunction("printf", printf_type).getCallee());
		assert(printf && "printf not found in module");

		return printf;
	}

	Function* makeExit (Module* module){
		
		Type *voidType = Type::getVoidTy(module->getContext());
		vector<Type *> exitArgsTypes;
		exitArgsTypes.push_back(Type::getInt32Ty(module->getContext()));
		FunctionType *exitType = FunctionType::get(voidType, exitArgsTypes, false);
		Function *exit = dyn_cast<Function>(module->getOrInsertFunction("exit", exitType).getCallee());
		assert(exit && "exitFunc not found in module");

		return exit;
	}


	static char ID;
	RemoveFunctions() : FunctionPass(ID) {}
        
	bool runOnFunction(Function &F) override {

		Module* module = F.getParent();
		StringRef functionName = F.getName();
		errs()<<"\nRemoveFunctions pass. Function being analysed : "<<functionName<<"\n";
              	
	       	if( find(function_list.begin(), function_list.end(), functionName) != function_list.end()  ){

			errs()<<"\nUser asked to remove "<<functionName<<"\n";

			/*
			 *  We will remove function by inserting an empty basic block in 
			 *  the function specified by user. That basic block will have a 
			 *  call to printf to print that the function is unreabable and then exit
			 *  will be called to terminate program execution. After the call to exit,
			 *  we add an unreachable instruction. In the final step, we remove all the 
			 *  basic blocks from the functions except the empty basic block that we 
			 *  added.
			 */ 
	
			BasicBlock * entryBB = &F.getEntryBlock();
			BasicBlock *emptyBB = BasicBlock::Create(module->getContext(), "empty");
        	    	emptyBB->insertInto(&F,entryBB);
			IRBuilder<> Builder(emptyBB);

			//Add printf call in empty BB
            		Value *str = Builder.CreateGlobalStringPtr("You asked to remove this function. Program terminating!\n", "str");
            		std::vector<Value *> removeMessage({str});
			Function* printfFunc = makePrintf(module);
            		Builder.CreateCall(printfFunc, removeMessage, "unreahcable");

           		//Add exit call in empty BB
            		Value *status = ConstantInt::get(Type::getInt32Ty(module->getContext()),(-10));
			Function* exitFunc = makeExit(module);
            		Builder.CreateCall(exitFunc, status, "");
            		Type* returnType = F.getReturnType();

            		//Add terminator instruction
			Builder.CreateUnreachable();

			// Removing the Basic blocks
			for (Function::iterator b = F.begin(), be = F.end(); b != be;) {
                        	BasicBlock* BB = &*b;
                        	++b;

                        	if(BB!=emptyBB)
                            		BB->eraseFromParent();
			}


        	}
        
        return true;
        }
    }; 

char RemoveFunctions::ID = 0;
static llvm::RegisterPass<previrt::transforms::RemoveFunctions> X("RemoveFunctions", "This pass removes functions specified by user");
}  
}

static llvm::RegisterStandardPasses Y(
    llvm::PassManagerBuilder::EP_EarlyAsPossible,
    [](const llvm::PassManagerBuilder &Builder,
       llvm::legacy::PassManagerBase &PM) { PM.add(new previrt::transforms::RemoveFunctions()); });
