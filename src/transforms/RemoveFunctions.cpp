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

static llvm::cl::opt<std::string> filePath("filePath", llvm::cl::init(""));

namespace previrt {
namespace transforms {

using namespace llvm;
using namespace std;

struct RemoveFunctions : public FunctionPass {
	
	static char ID;
	RemoveFunctions() : FunctionPass(ID) {}
        
	bool runOnFunction(Function &F) override {

/***
*   This is one option of getting input. 
*   User can provide names of functions to be removed in a file as a commandline argument (-filePath=removeFunctions.txt)
*   currently names of functions to be removed are specified in a vector (removeFunctions) below.
*
*	ifstream f;
*	vector<string> removeFunctions_copy;
*   string str;
*	if(filePath.size())
*		f.open(filePath);
*
*	if(filePath.size()){
*
*       while(getline(f, str))
*		removeFunctions_copy.push_back(str);
*	}
***/
		Module* module = F.getParent();
		vector<string> removeFunctions{"func1","func2","func3","func4","add"};
    
		// Declare printf function
		Type *intType = Type::getInt32Ty(module->getContext());
		std::vector<Type *> printfArgsTypes({Type::getInt8PtrTy(module->getContext())});
		FunctionType *printfType = FunctionType::get(intType, printfArgsTypes, true);
		Function *printfFunc = dyn_cast<Function>(module->getOrInsertFunction("printf", printfType).getCallee()); 
		// Declare exit function
		Type *voidType = Type::getVoidTy(module->getContext());
		vector<Type *> exitArgsTypes;
		exitArgsTypes.push_back(Type::getInt32Ty(module->getContext()));
		FunctionType *exitType = FunctionType::get(voidType, exitArgsTypes, false);
		Function *exitFunc = dyn_cast<Function>(module->getOrInsertFunction("exit", exitType).getCallee());

		string functionName = F.getName().str();
	
	       	if( find(removeFunctions.begin(), removeFunctions.end(), functionName) != removeFunctions.end()  ){
	
			BasicBlock * entryBB = &F.getEntryBlock();
			BasicBlock *emptyBB = BasicBlock::Create(module->getContext(), "empty");
        	    	emptyBB->insertInto(&F,entryBB);
			IRBuilder<> Builder(emptyBB);
			//Add printf call in empty BB
            		Value *str = Builder.CreateGlobalStringPtr("You asked to remove this function. Program terminating!\n", "str");
            		std::vector<Value *> removeMessage({str});
            		Builder.CreateCall(printfFunc, removeMessage, "unreahcable");
           		//Add exit call in empty BB
            		Value *status = ConstantInt::get(Type::getInt32Ty(module->getContext()),(-10));
            		Builder.CreateCall(exitFunc, status, "");
            		Type* returnType = F.getReturnType();
            		//Add terminator instruction
            		ReturnInst::Create(module->getContext(), UndefValue::get(returnType), emptyBB);

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
