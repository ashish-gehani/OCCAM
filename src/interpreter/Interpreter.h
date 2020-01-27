//===-- Interpreter.h ------------------------------------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This header file defines the interpreter structure
//
//===----------------------------------------------------------------------===//

#pragma once

#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"


namespace llvm {
class IntrinsicLowering;
template<typename T> class generic_gep_type_iterator;
class ConstantExpr;
typedef generic_gep_type_iterator<User::const_op_iterator> gep_type_iterator;
} // end namespace llvm


namespace previrt {
// AllocaHolder - Object to track all of the blocks of memory allocated by
// alloca.  When the function returns, this object is popped off the execution
// stack, which causes the dtor to be run, which frees all the alloca'd memory.
//
class AllocaHolder {
  std::vector<void *> Allocations;

public:
  AllocaHolder() {}

  // Make this type move-only.
  AllocaHolder(AllocaHolder &&) = default;
  AllocaHolder &operator=(AllocaHolder &&RHS) = default;

  ~AllocaHolder() {
    for (void *Allocation : Allocations)
      free(Allocation);
  }

  void add(void *Mem) { Allocations.push_back(Mem); }
};

typedef std::vector<llvm::GenericValue> ValuePlaneTy;

// ExecutionContext struct - This struct represents one stack frame currently
// executing.
//
struct ExecutionContext {
  llvm::Function             *CurFunction;// The currently executing function
  llvm::BasicBlock           *CurBB;      // The currently executing BB
  llvm::BasicBlock::iterator  CurInst;    // The next instruction to execute
  llvm::CallSite             Caller;     // Holds the call that called subframes.
                                   // NULL if main func or debugger invoked fn
  std::map<llvm::Value *, llvm::GenericValue> Values; // LLVM values used in this invocation
  std::vector<llvm::GenericValue>  VarArgs; // Values passed through an ellipsis
  AllocaHolder Allocas;            // Track memory allocated by alloca

  ExecutionContext() : CurFunction(nullptr), CurBB(nullptr), CurInst(nullptr) {}
};

// Interpreter - This class represents the entirety of the interpreter.
//
class Interpreter : public llvm::ExecutionEngine, public llvm::InstVisitor<Interpreter> {
  llvm::GenericValue ExitValue;          // The return value of the called function
  llvm::IntrinsicLowering *IL;

  // The runtime stack of executing code.  The top of the stack is the current
  // function record.
  std::vector<ExecutionContext> ECStack;

  // AtExitHandlers - List of functions to call when the program exits,
  // registered with the atexit() library function.
  std::vector<llvm::Function*> AtExitHandlers;

public:
  explicit Interpreter(std::unique_ptr<llvm::Module> M);
  ~Interpreter() override;

  /// runAtExitHandlers - Run any functions registered by the program's calls to
  /// atexit(3), which we intercept and store in AtExitHandlers.
  ///
  void runAtExitHandlers();

  static void Register() {
    InterpCtor = create;
  }

  /// Create an interpreter ExecutionEngine.
  ///
  static llvm::ExecutionEngine *create(std::unique_ptr<llvm::Module> M,
                                 std::string *ErrorStr = nullptr);

  /// run - Start execution with the specified function and arguments.
  ///
  llvm::GenericValue runFunction(llvm::Function *F,
				 llvm::ArrayRef<llvm::GenericValue> ArgValues) override;

  void *getPointerToNamedFunction(llvm::StringRef Name,
                                  bool AbortOnFailure = true) override {
    // FIXME: not implemented.
    return nullptr;
  }

  // Methods used to execute code:
  // Place a call on the stack
  void callFunction(llvm::Function *F, llvm::ArrayRef<llvm::GenericValue> ArgVals);
  void run();                // Execute instructions until nothing left to do

  // Opcode Implementations
  void visitReturnInst(llvm::ReturnInst &I);
  void visitBranchInst(llvm::BranchInst &I);
  void visitSwitchInst(llvm::SwitchInst &I);
  void visitIndirectBrInst(llvm::IndirectBrInst &I);

  void visitBinaryOperator(llvm::BinaryOperator &I);
  void visitICmpInst(llvm::ICmpInst &I);
  void visitFCmpInst(llvm::FCmpInst &I);
  void visitAllocaInst(llvm::AllocaInst &I);
  void visitLoadInst(llvm::LoadInst &I);
  void visitStoreInst(llvm::StoreInst &I);
  void visitGetElementPtrInst(llvm::GetElementPtrInst &I);
  void visitPHINode(llvm::PHINode &PN) { 
    llvm_unreachable("PHI nodes already handled!"); 
  }
  void visitTruncInst(llvm::TruncInst &I);
  void visitZExtInst(llvm::ZExtInst &I);
  void visitSExtInst(llvm::SExtInst &I);
  void visitFPTruncInst(llvm::FPTruncInst &I);
  void visitFPExtInst(llvm::FPExtInst &I);
  void visitUIToFPInst(llvm::UIToFPInst &I);
  void visitSIToFPInst(llvm::SIToFPInst &I);
  void visitFPToUIInst(llvm::FPToUIInst &I);
  void visitFPToSIInst(llvm::FPToSIInst &I);
  void visitPtrToIntInst(llvm::PtrToIntInst &I);
  void visitIntToPtrInst(llvm::IntToPtrInst &I);
  void visitBitCastInst(llvm::BitCastInst &I);
  void visitSelectInst(llvm::SelectInst &I);


  void visitCallSite(llvm::CallSite CS);
  void visitCallInst(llvm::CallInst &I) { visitCallSite(llvm::CallSite(&I)); }
  void visitInvokeInst(llvm::InvokeInst &I) { visitCallSite(llvm::CallSite(&I)); }
  void visitUnreachableInst(llvm::UnreachableInst &I);

  void visitShl(llvm::BinaryOperator &I);
  void visitLShr(llvm::BinaryOperator &I);
  void visitAShr(llvm::BinaryOperator &I);

  void visitVAArgInst(llvm::VAArgInst &I);
  void visitExtractElementInst(llvm::ExtractElementInst &I);
  void visitInsertElementInst(llvm::InsertElementInst &I);
  void visitShuffleVectorInst(llvm::ShuffleVectorInst &I);

  void visitExtractValueInst(llvm::ExtractValueInst &I);
  void visitInsertValueInst(llvm::InsertValueInst &I);

  void visitInstruction(llvm::Instruction &I) {
    llvm::errs() << I << "\n";
    llvm_unreachable("Instruction not interpretable yet!");
  }

  llvm::GenericValue callExternalFunction(llvm::Function *F,
					  llvm::ArrayRef<llvm::GenericValue> ArgVals);
  void exitCalled(llvm::GenericValue GV);

  void addAtExitHandler(llvm::Function *F) {
    AtExitHandlers.push_back(F);
  }

  llvm::GenericValue *getFirstVarArg () {
    return &(ECStack.back ().VarArgs[0]);
  }

private:  // Helper functions
  llvm::GenericValue executeGEPOperation(llvm::Value *Ptr,
					 llvm::gep_type_iterator I,
					 llvm::gep_type_iterator E,
					 ExecutionContext &SF);

  // SwitchToNewBasicBlock - Start execution in a new basic block and run any
  // PHI nodes in the top of the block.  This is used for intraprocedural
  // control flow.
  //
  void SwitchToNewBasicBlock(llvm::BasicBlock *Dest, ExecutionContext &SF);

  void *getPointerToFunction(llvm::Function *F) override { return (void*)F; }

  void initializeExecutionEngine() { }
  void initializeExternalFunctions();
  llvm::GenericValue getConstantExprValue(llvm::ConstantExpr *CE, ExecutionContext &SF);
  llvm::GenericValue getOperandValue(llvm::Value *V, ExecutionContext &SF);
  llvm::GenericValue executeTruncInst(llvm::Value *SrcVal, llvm::Type *DstTy,
				      ExecutionContext &SF);
  llvm::GenericValue executeSExtInst(llvm::Value *SrcVal, llvm::Type *DstTy,
				     ExecutionContext &SF);
  llvm::GenericValue executeZExtInst(llvm::Value *SrcVal, llvm::Type *DstTy,
				     ExecutionContext &SF);
  llvm::GenericValue executeFPTruncInst(llvm::Value *SrcVal, llvm::Type *DstTy,
					ExecutionContext &SF);
  llvm::GenericValue executeFPExtInst(llvm::Value *SrcVal, llvm::Type *DstTy,
				      ExecutionContext &SF);
  llvm::GenericValue executeFPToUIInst(llvm::Value *SrcVal, llvm::Type *DstTy,
				       ExecutionContext &SF);
  llvm::GenericValue executeFPToSIInst(llvm::Value *SrcVal, llvm::Type *DstTy,
				       ExecutionContext &SF);
  llvm::GenericValue executeUIToFPInst(llvm::Value *SrcVal, llvm::Type *DstTy,
				       ExecutionContext &SF);
  llvm::GenericValue executeSIToFPInst(llvm::Value *SrcVal, llvm::Type *DstTy,
				       ExecutionContext &SF);
  llvm::GenericValue executePtrToIntInst(llvm::Value *SrcVal, llvm::Type *DstTy,
					 ExecutionContext &SF);
  llvm::GenericValue executeIntToPtrInst(llvm::Value *SrcVal, llvm::Type *DstTy,
					 ExecutionContext &SF);
  llvm::GenericValue executeBitCastInst(llvm::Value *SrcVal, llvm::Type *DstTy,
					ExecutionContext &SF);
  llvm::GenericValue executeCastOperation(llvm::Instruction::CastOps opcode,
					  llvm::Value *SrcVal, 
					  llvm::Type *Ty, ExecutionContext &SF);
  void popStackAndReturnValueToCaller(llvm::Type *RetTy, llvm::GenericValue Result);

};

} // End llvm previrt

