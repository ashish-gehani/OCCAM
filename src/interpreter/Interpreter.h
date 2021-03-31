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
#include "llvm/ADT/DenseSet.h"
#include "llvm/ADT/DenseMap.h"
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
class ExecutionEngine;
class LoopInfo;
class BasicBlock;
} // end namespace llvm


#ifdef HAVE_FFI_H
#define TRACK_ONLY_UNACCESSIBLE_MEM
#endif

namespace previrt {

class ArgvArray {
  std::unique_ptr<char[]> Array;
  std::vector<std::unique_ptr<char[]>> Values;
public:
  /// Turn a vector of strings into a nice argv style array of pointers to null
  /// terminated strings.
  void *reset(llvm::LLVMContext &C, llvm::ExecutionEngine *EE,
              const std::vector<std::string> &InputArgv);
};

// // AllocaHolder - Object to track all of the blocks of memory allocated by
// // alloca.  When the function returns, this object is popped off the execution
// // stack, which causes the dtor to be run, which frees all the alloca'd memory.
// //
// class AllocaHolder {
//   std::vector<void *> Allocations;
// public:
//   AllocaHolder() {}
//   // Make this type move-only.
//   AllocaHolder(AllocaHolder &&) = default;
//   AllocaHolder &operator=(AllocaHolder &&RHS) = default;
//   ~AllocaHolder() {
//     for (void *Allocation : Allocations)
//       free(Allocation);
//   }
//   void add(void *Mem) { Allocations.push_back(Mem); }
// };

// MemoryHolder - Object to track memory.
class MemoryHolder {
  std::map<intptr_t, intptr_t, std::greater<intptr_t>> m_mem_map;
  //std::vector<intptr_t> m_owned_memory;
  
public:
  MemoryHolder() {}

  // Make this type move-only.
  MemoryHolder(const MemoryHolder &) = delete;
  MemoryHolder &operator=(const MemoryHolder &RHS) = delete;  
  MemoryHolder(MemoryHolder &&) = default;
  MemoryHolder &operator=(MemoryHolder &&RHS) = default;
  
  ~MemoryHolder();

  bool trackMemory(void *mem) const;
  
  void add(void *mem, unsigned size);

  void addWithOwnershipTransfer(void *mem, unsigned size);  
  
  // TODOX: remove method that free memory.
};

// we create this new type to consider the case where the generic
// value is "unknown".
typedef llvm::Optional<llvm::GenericValue> AbsGenericValue;

void printAbsGenericValue(llvm::Type *Ty, AbsGenericValue AGV);

// ExecutionContext struct - This struct represents one stack frame currently
// executing.
//
struct ExecutionContext {
  llvm::Function             *CurFunction;// The currently executing function
  llvm::BasicBlock           *CurBB;      // The currently executing BB
  llvm::BasicBlock::iterator  CurInst;    // The next instruction to execute
  llvm::CallSite              Caller;     // Holds the call that called subframes.
                                          // NULL if main func or debugger invoked fn
  // LLVM values used in this invocation
  std::map<llvm::Value *, AbsGenericValue> Values;
  // Values passed through an ellipsis
  std::vector<AbsGenericValue>  VarArgs;
  // Track memory allocated by alloca
  MemoryHolder Allocas;
  
  ExecutionContext() : CurFunction(nullptr), CurBB(nullptr), CurInst(nullptr) {}
};

// If RawVal is a pointer and the element type is a non-pointer basic
// type then DerefValue is *(RawVal.PointerVal), otherwise None.
class RawAndDerefValue {
  llvm::GenericValue RawVal;
  AbsGenericValue DerefValue;

public:
  RawAndDerefValue(llvm::GenericValue _RawVal, AbsGenericValue _DerefValue)
    : RawVal(_RawVal), DerefValue(_DerefValue) {}

  llvm::GenericValue getRawValue() const {
    return RawVal;
  }
  
  bool hasDerefValue() const {
    return DerefValue.hasValue();
  }

  llvm::GenericValue getDerefValue() const {
    assert(hasDerefValue());
    return DerefValue.getValue();
  }
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

  // track memory allocated by malloc
  MemoryHolder MemMallocs;
  // track memory of main parameters Technically, they are part
  //      of the top-level stack frame. For convenience, we put them
  //      separate.
  MemoryHolder MemMainParams;
  // track global variable initializers
  MemoryHolder MemGlobals;
  // memory we know should be unaccessible
  // Used only if enabled TRACK_ONLY_UNACCESSIBLE_MEM
  MemoryHolder UnaccessibleMem;

  // keep track of unresolved globals (globals that cannot be
  // resolved by emitGlobals)
  llvm::DenseSet<const llvm::GlobalVariable*> UnresolvedGlobals;
  
  // the execution cannot continue
  bool StopExecution;

  // keep track of the blocks executed by the interpreter
  llvm::DenseSet<const llvm::BasicBlock*> VisitedBlocks;

  // Keep track of the executed memory instruction and its values.
  // If LoadInst  then its value is the lhs of the LoadInst
  // If StoreInst then its value is the stored value of the StoreInst
  std::vector<std::pair<llvm::Instruction*,llvm::GenericValue>> ExecutedMemInsts;
  
  // Whether "exit" was called with a non-zero value
  bool NonZeroExitCode;
  
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
  void callFunction(llvm::Function *F, llvm::ArrayRef<AbsGenericValue> ArgVals,
                   llvm::Instruction *CS = nullptr);
  void run();  // Execute instructions until nothing left to do

  // Opcode Implementations
  void visitReturnInst(llvm::ReturnInst &I);
  void visitBranchInst(llvm::BranchInst &I);
  void visitSwitchInst(llvm::SwitchInst &I);
  void visitIndirectBrInst(llvm::IndirectBrInst &I);

  void visitBinaryOperator(llvm::BinaryOperator &I);
  void visitICmpInst(llvm::ICmpInst &I);
  void visitFCmpInst(llvm::FCmpInst &I);

  void visitMallocInst(llvm::CallSite &CS);
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

  AbsGenericValue callExternalFunction(llvm::Instruction *CS, llvm::Function *F,
				       llvm::ArrayRef<AbsGenericValue> ArgVals);
  void exitCalled(llvm::GenericValue GV);

  void addAtExitHandler(llvm::Function *F) {
    AtExitHandlers.push_back(F);
  }

  void addExecutedMemInst(llvm::Instruction *I, llvm::GenericValue V) {
    ExecutedMemInsts.push_back({I,V});
  }
  
  llvm::GenericValue *getFirstVarArg () {
    AbsGenericValue &AVA = ECStack.back().VarArgs[0];
    if (AVA.hasValue()) {
      return &(AVA.getValue());
    } else {
      // JN: not sure if this will break things
      return nullptr;
    }
  }

  bool isAllocatedMemory(void *Addr) const;
  
  void initializeMainParams(void *Addr, unsigned Size);

  void initializeGlobalVariable(llvm::GlobalVariable &GV);

  void initMemory(const llvm::Constant *Init, void *Addr);


  llvm::Instruction* getLastExecutedInst() const ;

  const std::vector<std::pair<llvm::Instruction*,llvm::GenericValue>>&
  getExecutedMemInsts() const {
    return ExecutedMemInsts;
  }
  
  llvm::BasicBlock* inspectStackAndGlobalState(
	       llvm::DenseMap<llvm::Value*, RawAndDerefValue> &GlobalVals,
	       llvm::DenseMap<llvm::Value*, std::vector<RawAndDerefValue>> &StackVals);

  bool isExecuted(const llvm::BasicBlock &) const;

  bool exitNonZero() const { return NonZeroExitCode;}
  
private:  // Helper functions
  
  // SwitchToNewBasicBlock - Start execution in a new basic block and run any
  // PHI nodes in the top of the block.  This is used for intraprocedural
  // control flow.
  //
  void SwitchToNewBasicBlock(llvm::BasicBlock *Dest, ExecutionContext &SF);

  void *getPointerToFunction(llvm::Function *F) override { return (void*)F; }

  void initializeExecutionEngine() { }
  void initializeExternalFunctions();
  
  AbsGenericValue getConstantExprValue(llvm::ConstantExpr *CE, ExecutionContext &SF);
  AbsGenericValue getOperandValue(llvm::Value *V, ExecutionContext &SF);

  AbsGenericValue executeGEPOperation(llvm::Value *Ptr,
				      llvm::gep_type_iterator I,
				      llvm::gep_type_iterator E,
				      ExecutionContext &SF);
  
  llvm::GenericValue executeSelectInst(llvm::GenericValue Src1, llvm::GenericValue Src2,
				       llvm::GenericValue Src3, llvm::Type *Ty);
  llvm::GenericValue executeCmpInst(unsigned predicate, llvm::GenericValue Src1, 
				    llvm::GenericValue Src2, llvm::Type *Ty);
  llvm::GenericValue executeTruncInst(llvm::GenericValue Src, llvm::Type *SrcTy,
				      llvm::Type *DstTy, ExecutionContext &SF);
  llvm::GenericValue executeSExtInst(llvm::GenericValue Src, llvm::Type *SrcTy,
				     llvm::Type *DstTy, ExecutionContext &SF);
  llvm::GenericValue executeZExtInst(llvm::GenericValue Src, llvm::Type *SrcTy,
				     llvm::Type *DstTy, ExecutionContext &SF);
  llvm::GenericValue executeFPTruncInst(llvm::GenericValue Src, llvm::Type *SrcTy,
					llvm::Type *DstTy, ExecutionContext &SF);
  llvm::GenericValue executeFPExtInst(llvm::GenericValue Src, llvm::Type *SrcTy,
				      llvm::Type *DstTy, ExecutionContext &SF);
  llvm::GenericValue executeFPToUIInst(llvm::GenericValue Src, llvm::Type *SrcTy,
				       llvm::Type *DstTy, ExecutionContext &SF);
  llvm::GenericValue executeFPToSIInst(llvm::GenericValue Src, llvm::Type *SrcTy,
				       llvm::Type *DstTy, ExecutionContext &SF);
  llvm::GenericValue executeUIToFPInst(llvm::GenericValue Src, llvm::Type *SrcTy,
				       llvm::Type *DstTy, ExecutionContext &SF);
  llvm::GenericValue executeSIToFPInst(llvm::GenericValue Src, llvm::Type *SrcTy,
				       llvm::Type *DstTy, ExecutionContext &SF);
  llvm::GenericValue executePtrToIntInst(llvm::GenericValue Src, llvm::Type *SrcTy,
					 llvm::Type *DstTy, ExecutionContext &SF);
  llvm::GenericValue executeIntToPtrInst(llvm::GenericValue Src, llvm::Type *SrcTy,
					 llvm::Type *DstTy, ExecutionContext &SF);
  llvm::GenericValue executeBitCastInst(llvm::GenericValue Src, llvm::Type *SrcTy,
					llvm::Type *DstTy, ExecutionContext &SF);
  
  void executeFAddInst(llvm::GenericValue &Dest, llvm::GenericValue Src1,
		       llvm::GenericValue Src2, llvm::Type *Ty);
  void executeFSubInst(llvm::GenericValue &Dest, llvm::GenericValue Src1,
		       llvm::GenericValue Src2, llvm::Type *Ty);
  void executeFMulInst(llvm::GenericValue &Dest, llvm::GenericValue Src1,
		       llvm::GenericValue Src2, llvm::Type *Ty);
  void executeFDivInst(llvm::GenericValue &Dest, llvm::GenericValue Src1, 
		       llvm::GenericValue Src2, llvm::Type *Ty);
  void executeFRemInst(llvm::GenericValue &Dest, llvm::GenericValue Src1, 
		       llvm::GenericValue Src2, llvm::Type *Ty);
  
  void popStackAndReturnValueToCaller(llvm::Type *RetTy, AbsGenericValue Result);

  // Similar to lib/ExecutionEngine/ExecutionEngine.cpp but it doesn't
  // abort if the a global cannot be resolved.
  void emitGlobals();
};

} // End llvm previrt

