//===-- Execution.cpp - Implement code to simulate the program ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//  This file contains the actual instruction interpreter.
//
//===----------------------------------------------------------------------===//

#include "Interpreter.h"

#include "llvm/ADT/APInt.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/CodeGen/IntrinsicLowering.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/GetElementPtrTypeIterator.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/DynamicLibrary.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"

#include <algorithm>
#include <cmath>
#include <cstdarg>

//#define INTERACTIVE
#ifdef INTERACTIVE
#include <stdio.h>
#endif 
using namespace llvm;

namespace previrt {
#define LOG \
llvm::errs() 
#define ERR \
llvm::errs() << "ERROR: "

// defined in ConfigPrime.cpp
extern StringRef CONFIG_PRIME_STOP;


#define DEBUG_PTR_PROVENANCE
//===----------------------------------------------------------------------===//
//                     Memory management helpers
//===----------------------------------------------------------------------===//
bool MemoryHolder::trackMemory(void *mem) const {
  intptr_t addr = intptr_t (mem);
  auto it = m_mem_map.lower_bound (addr+1);
  if (it == m_mem_map.end()) return false;
  intptr_t lb = it->first;
  intptr_t ub = it->second;
  return (addr >= lb && addr < ub);
}

static void memlog (const char *format, ...) {
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
}

void MemoryHolder::add(void *mem, unsigned size) {
  if (trackMemory(mem)) return;
  intptr_t addr = intptr_t(mem);
  m_mem_map.insert({addr, addr + size});
  
  if (m_smallest_addr == 0 || addr < m_smallest_addr) {
    m_smallest_addr = addr;
  } 
}

void MemoryHolder::addWithOwnershipTransfer(void *mem, unsigned size) {
  add(mem, size);
  //m_owned_memory.push_back(intptr_t(mem));  
}

bool MemoryHolder::free(void *mem, size_t &size) {
  size = 0;
  if (mem == 0) {
    // if free a null then it's a non-op
    return false;
  }
  
  intptr_t addr = intptr_t (mem);
  auto it = m_mem_map.lower_bound (addr+1);
  if (it == m_mem_map.end()) {
    LOG << "Warning: the pointer " << mem << " was not allocated via malloc?\n";
    return false;
  }
  intptr_t lb = it->first;
  intptr_t ub = it->second;
  if (addr == lb) {
    m_mem_map.erase(it);
    size = (size_t)(ub - lb);
    return true;
  } else {
    LOG << "Warning: the pointer " << mem
	<< " must point to the base of a memory object\n";
    return false;
  }
}

#if 0
static const Function *getCalledFunction(const Value *V, bool LookThroughBitCast) {
  // Don't care about intrinsics in this case.
  if (isa<IntrinsicInst>(V))
    return nullptr;

  if (LookThroughBitCast)
    V = V->stripPointerCasts();

  ImmutableCallSite CS(V);
  if (!CS.getInstruction())
    return nullptr;

  const Function *Callee = CS.getCalledFunction();
  if (!Callee || !Callee->isDeclaration())
    return nullptr;
  return Callee;
}
#endif

// FIXME: use isMallocLikeFn from MemoryBuiltins  
static bool isMallocLikeFn(const Function &F) {
  return (F.getName() == "malloc" ||
	  F.getName() == "calloc" ||
	  F.getName() == "realloc");
}

//FIXME: use MemoryBuiltins to recognize free functions
static bool isFreeLikeFn(const Function &F) {
  return F.getName() == "free";
}
  
// from lib/ExecutionEngine/ExecutionEngine.cpp
void Interpreter::initMemory(const Constant *Init, void *Addr) {
			     
  if (isa<UndefValue>(Init))
    return;

  if (const ConstantVector *CP = dyn_cast<ConstantVector>(Init)) {
    unsigned ElementSize = getDataLayout().getTypeAllocSize(CP->getType()->getElementType());
    for (unsigned i = 0, e = CP->getNumOperands(); i != e; ++i)
      initMemory(CP->getOperand(i), (char*)Addr+i*ElementSize);
    return;
  }

  if (isa<ConstantAggregateZero>(Init)) {
    size_t sz = (size_t)getDataLayout().getTypeAllocSize(Init->getType());
    MemGlobals.add(Addr, sz);
    memlog("Allocated %d bytes: [%#lx,%#lx]\n", sz, intptr_t(Addr), intptr_t(Addr)+sz);    
    return;
  }

  if (const ConstantArray *CPA = dyn_cast<ConstantArray>(Init)) {
    unsigned ElementSize = getDataLayout().getTypeAllocSize(CPA->getType()->getElementType());
    for (unsigned i = 0, e = CPA->getNumOperands(); i != e; ++i)
      initMemory(CPA->getOperand(i), (char*)Addr+i*ElementSize);
    return;
  }

  if (const ConstantStruct *CPS = dyn_cast<ConstantStruct>(Init)) {
    const StructLayout *SL = getDataLayout().getStructLayout(cast<StructType>(CPS->getType()));
    for (unsigned i = 0, e = CPS->getNumOperands(); i != e; ++i)
      initMemory(CPS->getOperand(i), (char*)Addr+SL->getElementOffset(i));
    return;
  }

  if (const ConstantDataSequential *CDS = dyn_cast<ConstantDataSequential>(Init)) {
    // CDS is already laid out in host memory order.
    StringRef Data = CDS->getRawDataValues();
    MemGlobals.add(Addr, Data.size());
    memlog("Allocated %d bytes: [%#lx,%#lx]\n", Data.size(),
	   intptr_t(Addr), intptr_t(Addr)+Data.size());    
    return;
  }

  if (Init->getType()->isFirstClassType()) {
    GenericValue Val = getConstantValue(Init);
    size_t sz = getDataLayout().getTypeAllocSize(Init->getType());
    MemGlobals.add(Addr, sz);
    memlog("Allocated %d bytes: [%#lx,%#lx]\n", sz, intptr_t(Addr), intptr_t(Addr)+sz);        
    return;
  }

  llvm_unreachable("Unknown constant type to initialize memory with!");
}

/*** 
* This method keeps track of the range of addresses allocated for
* GV. The GV has been already allocated in memory before calling
* this method
**/
void Interpreter::initializeGlobalVariable(GlobalVariable &GV) {
#ifndef TRACK_ONLY_UNACCESSIBLE_MEM  
  LOG << "Collecting addresses from global initializer for " << GV.getName() << ".\n";
  if (void *GA = getPointerToGlobalIfAvailable(&GV)) {
    // Not sure if this is necessary
    // MemGlobals.add(GA, (size_t)getDataLayout().getTypeAllocSize(GV.getType()));
    // mark as initialized all the memory of the initializer
    initMemory(GV.getInitializer(), GA);
  } else {
    LOG << "\t" << "Pointer to global " << GV.getName()  << " is not available\n";
  }
#endif   
}

void Interpreter::initializeMainParams(void *Addr, unsigned Size) {
#ifdef TRACK_ONLY_UNACCESSIBLE_MEM
  LOG << "Marking as unaccessible memory at address="
      << Addr << " size=" << Size << "\n";
  UnaccessibleMem.add(Addr, Size);
  memlog("Marking as unaccessible %d bytes: [%#lx,%#lx]\n",
	 Size, intptr_t(Addr), intptr_t(Addr)+Size);   
#else
  LOG << "Collecting addresses from main argv parameter: address="
      << Addr << " size=" << Size <<".\n";  
  MemMainParams.add(Addr, Size);
  memlog("Allocated %d bytes: [%#lx,%#lx]\n",
	 Size, intptr_t(Addr), intptr_t(Addr)+Size);   
#endif 				    
}

bool Interpreter::isAllocatedMemory(void *Addr) const {
  if (((intptr_t)Addr) >= 0x0 && ((intptr_t)Addr) <= 0x400) {
    /* HACK:
       %30 = call i8* @strrchr(i8* nonnull dereferenceable(1) %29, i32 47) #20
       %31 = icmp eq i8* %30, null
       %32 = getelementptr inbounds i8, i8* %30, i64 1
       %33 = select i1 %31, i8* %29, i8* %32
       
       Since strrchr can return 0x0, then %32 will be 0x1. The program is
       fine because %32 will never be dereferenced.
    */
    return false;
  }
  
#ifdef TRACK_ONLY_UNACCESSIBLE_MEM
  return !UnaccessibleMem.trackMemory(Addr);
#else
  /* We keep track carefully of all allocated memory by the module.
     If the module calls an external function that allocates memory we
     will consider that memory as un-allocated. */
  const ExecutionContext &SF = ECStack.back();
  return (MemMainParams.trackMemory(Addr) ||
	  SF.Allocas.trackMemory(Addr) ||
	  MemGlobals.trackMemory(Addr) || 
	  MemMallocs.trackMemory(Addr));
#endif  
}

/// JN: From lib/ExecutionEngine/ExecutionEngine.cpp but it doesn't
/// report error if a global cannot be resolved.
///  
/// EmitGlobals - Emit all of the global variables to memory, storing their
/// addresses into GlobalAddress.  This must make sure to copy the contents of
/// their initializers into the memory.
void Interpreter::emitGlobals() {
  // Loop over all of the global variables in the program, allocating the memory
  // to hold them.  If there is more than one module, do a prepass over globals
  // to figure out how the different modules should link together.
  std::map<std::pair<std::string, Type*>,
           const GlobalValue*> LinkedGlobalsMap;

  if (Modules.size() != 1) {
    for (unsigned m = 0, e = Modules.size(); m != e; ++m) {
      Module &M = *Modules[m];
      for (const auto &GV : M.globals()) {
        if (GV.hasLocalLinkage() || GV.isDeclaration() ||
            GV.hasAppendingLinkage() || !GV.hasName())
          continue;// Ignore external globals and globals with internal linkage.

        const GlobalValue *&GVEntry =
          LinkedGlobalsMap[std::make_pair(GV.getName(), GV.getType())];

        // If this is the first time we've seen this global, it is the canonical
        // version.
        if (!GVEntry) {
          GVEntry = &GV;
          continue;
        }

        // If the existing global is strong, never replace it.
        if (GVEntry->hasExternalLinkage())
          continue;

        // Otherwise, we know it's linkonce/weak, replace it if this is a strong
        // symbol.  FIXME is this right for common?
        if (GV.hasExternalLinkage() || GVEntry->hasExternalWeakLinkage())
          GVEntry = &GV;
      }
    }
  }

  std::vector<const GlobalValue*> NonCanonicalGlobals;
  for (unsigned m = 0, e = Modules.size(); m != e; ++m) {
    Module &M = *Modules[m];
    for (const auto &GV : M.globals()) {
      // In the multi-module case, see what this global maps to.
      if (!LinkedGlobalsMap.empty()) {
        if (const GlobalValue *GVEntry =
              LinkedGlobalsMap[std::make_pair(GV.getName(), GV.getType())]) {
          // If something else is the canonical global, ignore this one.
          if (GVEntry != &GV) {
            NonCanonicalGlobals.push_back(&GV);
            continue;
          }
        }
      }

      if (!GV.isDeclaration()) {
        addGlobalMapping(&GV, getMemoryForGV(&GV));
      } else {
        // External variable reference. Try to use the dynamic loader to
        // get a pointer to it.
        if (void *SymAddr =
            sys::DynamicLibrary::SearchForAddressOfSymbol(GV.getName()))
          addGlobalMapping(&GV, SymAddr);
        else {
	  UnresolvedGlobals.insert(&GV);
	  llvm::errs () << "Warning: Could not resolve external global address: "
			<< GV.getName() << "\n";
        }
      }
    }

    // If there are multiple modules, map the non-canonical globals to their
    // canonical location.
    if (!NonCanonicalGlobals.empty()) {
      for (unsigned i = 0, e = NonCanonicalGlobals.size(); i != e; ++i) {
        const GlobalValue *GV = NonCanonicalGlobals[i];
        const GlobalValue *CGV =
          LinkedGlobalsMap[std::make_pair(GV->getName(), GV->getType())];
        void *Ptr = getPointerToGlobalIfAvailable(CGV);
        assert(Ptr && "Canonical global wasn't codegen'd!");
        addGlobalMapping(GV, Ptr);
      }
    }

    // Now that all of the globals are set up in memory, loop through them all
    // and initialize their contents.
    for (const auto &GV : M.globals()) {
      if (!GV.isDeclaration()) {
        if (!LinkedGlobalsMap.empty()) {
          if (const GlobalValue *GVEntry =
                LinkedGlobalsMap[std::make_pair(GV.getName(), GV.getType())])
            if (GVEntry != &GV)  // Not the canonical variable.
              continue;
        }
        EmitGlobalVariable(&GV);
      }
    }
  }
}

//===----------------------------------------------------------------------===//
//                     Various Helper Functions
//===----------------------------------------------------------------------===//

void printAbsGenericValue(Type *Ty, AbsGenericValue AGV) {
  if (!AGV.hasValue()) {
    LOG << "Unknown";
    return;
  }

  GenericValue GV = AGV.getValue();
      
  switch (Ty->getTypeID()) {
  case Type::IntegerTyID:
    if (GV.IntVal.getBitWidth() == 1) {
      if (GV.IntVal.getBoolValue()) {
	LOG << "True";
      } else {
	LOG << "False";	  
      }
    } else {
      LOG << GV.IntVal;
    }    
    break;
  case Type::FloatTyID:
    LOG << GV.FloatVal;
    break;
  case Type::DoubleTyID:
    LOG << GV.DoubleVal;
    break;
  case Type::PointerTyID:
    LOG << (void*) GV.PointerVal;
    break;
  case Type::X86_FP80TyID:
    LOG << GV.IntVal; 
    break;
  case Type::VectorTyID: {
    auto *VT = cast<VectorType>(Ty);
    Type *ElemT = VT->getElementType();
    const unsigned numElems = VT->getNumElements();
    if (ElemT->isFloatTy()) {
      LOG << "<";
      for (unsigned i = 0; i < numElems; ) {
	LOG << GV.AggregateVal[i].FloatVal;
	++i;
	if (i < numElems) {
	  LOG << ",";
	}
      }
      LOG << ">";
    }
    if (ElemT->isDoubleTy()) {
      LOG << "<";
      for (unsigned i = 0; i < numElems; ) {
	LOG << GV.AggregateVal[i].DoubleVal;
	++i;
	if (i < numElems) {
	  LOG << ",";
	}
      }
      LOG << ">";      
    }
    if (ElemT->isIntegerTy()) {
      LOG << "<";
      for (unsigned i = 0; i < numElems; ) {
	LOG << GV.AggregateVal[i].IntVal;
	++i;
	if (i < numElems) {
	  LOG << ",";
	}
      }
      LOG << ">";
    }
    break;
  }
  default:
    LOG << "UNSUPPORTED CASE\n";
  }
}

static void SetValue(Value *V, AbsGenericValue Val, ExecutionContext &SF) {
  SF.Values[V] = Val;
}

AbsGenericValue Interpreter::getOperandValue(Value *V, ExecutionContext &SF) {
  if (ConstantExpr *CE = dyn_cast<ConstantExpr>(V)) {
    return getConstantExprValue(CE, SF);
  } else if (Constant *CPV = dyn_cast<Constant>(V)) {
    return getConstantValue(CPV);         // Defined in ExecutionEngine.h
  } else if (GlobalValue *GV = dyn_cast<GlobalValue>(V)) {
    if (GlobalVariable *GVar = dyn_cast<GlobalVariable>(GV)) {
      if (UnresolvedGlobals.count(GVar) > 0) {
	return AbsGenericValue();
      }
    }
    return PTOGV(getPointerToGlobal(GV)); // Defined in ExecutionEngine.h
  } else {
    return SF.Values[V];
  }
}

AbsGenericValue Interpreter::getConstantExprValue(ConstantExpr *CE,
						  ExecutionContext &SF) {
  
  switch (CE->getOpcode()) {
  case Instruction::Trunc: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    assert(AOp1.hasValue());
    Type *Op1Ty = CE->getOperand(0)->getType();
    return executeTruncInst(AOp1.getValue(), Op1Ty, CE->getType(), SF);
  }
  case Instruction::ZExt: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    assert(AOp1.hasValue());    
    Type *Op1Ty = CE->getOperand(0)->getType();    
    return executeZExtInst(AOp1.getValue(), Op1Ty, CE->getType(), SF);
  }
  case Instruction::SExt: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    assert(AOp1.hasValue());        
    Type *Op1Ty = CE->getOperand(0)->getType();
    return executeSExtInst(AOp1.getValue(), Op1Ty, CE->getType(), SF);
  }
  case Instruction::FPTrunc: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    assert(AOp1.hasValue());        
    Type *Op1Ty = CE->getOperand(0)->getType();    
    return executeFPTruncInst(AOp1.getValue(), Op1Ty, CE->getType(), SF);
  }
  case Instruction::FPExt: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    assert(AOp1.hasValue());        
    Type *Op1Ty = CE->getOperand(0)->getType();    
    return executeFPExtInst(AOp1.getValue(), Op1Ty, CE->getType(), SF);
  }
  case Instruction::UIToFP: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    assert(AOp1.hasValue());            
    Type *Op1Ty = CE->getOperand(0)->getType();    
    return executeUIToFPInst(AOp1.getValue(), Op1Ty, CE->getType(), SF);
  }
  case Instruction::SIToFP: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    assert(AOp1.hasValue());                
    Type *Op1Ty = CE->getOperand(0)->getType();        
    return executeSIToFPInst(AOp1.getValue(), Op1Ty, CE->getType(), SF);
  }
  case Instruction::FPToUI: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    assert(AOp1.hasValue());                
    Type *Op1Ty = CE->getOperand(0)->getType();    
    return executeFPToUIInst(AOp1.getValue(), Op1Ty, CE->getType(), SF);
  }
  case Instruction::FPToSI: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    assert(AOp1.hasValue());                
    Type *Op1Ty = CE->getOperand(0)->getType();    
    return executeFPToSIInst(AOp1.getValue(), Op1Ty, CE->getType(), SF);
  }
  case Instruction::PtrToInt: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    assert(AOp1.hasValue());                
    Type *Op1Ty = CE->getOperand(0)->getType();    
    return executePtrToIntInst(AOp1.getValue(), Op1Ty, CE->getType(), SF);
  }
  case Instruction::IntToPtr: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    assert(AOp1.hasValue());                
    Type *Op1Ty = CE->getOperand(0)->getType();    
    return executeIntToPtrInst(AOp1.getValue(), Op1Ty, CE->getType(), SF);
  }
  case Instruction::BitCast: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    assert(AOp1.hasValue());                
    Type *Op1Ty = CE->getOperand(0)->getType();    
    return executeBitCastInst(AOp1.getValue(), Op1Ty, CE->getType(), SF);
  }
  case Instruction::GetElementPtr:
    return executeGEPOperation(CE->getOperand(0), gep_type_begin(CE),
                               gep_type_end(CE), SF);
  case Instruction::FCmp:
  case Instruction::ICmp: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    AbsGenericValue AOp2 = getOperandValue(CE->getOperand(1), SF);
    assert(AOp1.hasValue());
    assert(AOp2.hasValue());
    return executeCmpInst(CE->getPredicate(),
                          AOp1.getValue(),
                          AOp2.getValue(),
                          CE->getOperand(0)->getType());
  }
  case Instruction::Select: {
    AbsGenericValue AOp1 = getOperandValue(CE->getOperand(0), SF);
    AbsGenericValue AOp2 = getOperandValue(CE->getOperand(1), SF);
    AbsGenericValue AOp3 = getOperandValue(CE->getOperand(2), SF);    
    assert(AOp1.hasValue());
    assert(AOp2.hasValue());
    assert(AOp3.hasValue());    
    return executeSelectInst(AOp1.getValue(),
                             AOp2.getValue(),
                             AOp3.getValue(),
                             CE->getOperand(0)->getType());
  }
  default :
    break;
  }

  // The cases below here require a GenericValue parameter for the result
  // so we initialize one, compute it and then return it.

  AbsGenericValue AOp0 = getOperandValue(CE->getOperand(0), SF);
  AbsGenericValue AOp1 = getOperandValue(CE->getOperand(1), SF);
  assert(AOp0.hasValue());
  assert(AOp1.hasValue());

  GenericValue Op0 = AOp0.getValue();
  GenericValue Op1 = AOp1.getValue();  
  GenericValue Dest;
  Type * Ty = CE->getOperand(0)->getType();
  switch (CE->getOpcode()) {
  case Instruction::Add:  Dest.IntVal = Op0.IntVal + Op1.IntVal; break;
  case Instruction::Sub:  Dest.IntVal = Op0.IntVal - Op1.IntVal; break;
  case Instruction::Mul:  Dest.IntVal = Op0.IntVal * Op1.IntVal; break;
  case Instruction::FAdd: executeFAddInst(Dest, Op0, Op1, Ty); break;
  case Instruction::FSub: executeFSubInst(Dest, Op0, Op1, Ty); break;
  case Instruction::FMul: executeFMulInst(Dest, Op0, Op1, Ty); break;
  case Instruction::FDiv: executeFDivInst(Dest, Op0, Op1, Ty); break;
  case Instruction::FRem: executeFRemInst(Dest, Op0, Op1, Ty); break;
  case Instruction::SDiv: Dest.IntVal = Op0.IntVal.sdiv(Op1.IntVal); break;
  case Instruction::UDiv: Dest.IntVal = Op0.IntVal.udiv(Op1.IntVal); break;
  case Instruction::URem: Dest.IntVal = Op0.IntVal.urem(Op1.IntVal); break;
  case Instruction::SRem: Dest.IntVal = Op0.IntVal.srem(Op1.IntVal); break;
  case Instruction::And:  Dest.IntVal = Op0.IntVal & Op1.IntVal; break;
  case Instruction::Or:   Dest.IntVal = Op0.IntVal | Op1.IntVal; break;
  case Instruction::Xor:  Dest.IntVal = Op0.IntVal ^ Op1.IntVal; break;
  case Instruction::Shl:  
    Dest.IntVal = Op0.IntVal.shl(Op1.IntVal.getZExtValue());
    break;
  case Instruction::LShr: 
    Dest.IntVal = Op0.IntVal.lshr(Op1.IntVal.getZExtValue());
    break;
  case Instruction::AShr: 
    Dest.IntVal = Op0.IntVal.ashr(Op1.IntVal.getZExtValue());
    break;
  default:
    ERR << "Unhandled ConstantExpr: " << *CE << "\n";
    llvm_unreachable("Unhandled ConstantExpr");
  }
  return Dest;
}


//===----------------------------------------------------------------------===//
//                    Binary Instruction Implementations
//===----------------------------------------------------------------------===//

#define IMPLEMENT_BINARY_OPERATOR(OP, TY) \
   case Type::TY##TyID: \
     Dest.TY##Val = Src1.TY##Val OP Src2.TY##Val; \
     break

void Interpreter::executeFAddInst(GenericValue &Dest, GenericValue Src1,
				  GenericValue Src2, Type *Ty) {
  switch (Ty->getTypeID()) {
    IMPLEMENT_BINARY_OPERATOR(+, Float);
    IMPLEMENT_BINARY_OPERATOR(+, Double);
  default:
    ERR << "Unhandled type for FAdd instruction: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
}

void Interpreter::executeFSubInst(GenericValue &Dest, GenericValue Src1,
				  GenericValue Src2, Type *Ty) {
  switch (Ty->getTypeID()) {
    IMPLEMENT_BINARY_OPERATOR(-, Float);
    IMPLEMENT_BINARY_OPERATOR(-, Double);
  default:
    ERR << "Unhandled type for FSub instruction: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
}

void Interpreter::executeFMulInst(GenericValue &Dest, GenericValue Src1,
				  GenericValue Src2, Type *Ty) {
  switch (Ty->getTypeID()) {
    IMPLEMENT_BINARY_OPERATOR(*, Float);
    IMPLEMENT_BINARY_OPERATOR(*, Double);
  default:
    ERR << "Unhandled type for FMul instruction: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
}

void Interpreter::executeFDivInst(GenericValue &Dest, GenericValue Src1, 
				  GenericValue Src2, Type *Ty) {
  switch (Ty->getTypeID()) {
    IMPLEMENT_BINARY_OPERATOR(/, Float);
    IMPLEMENT_BINARY_OPERATOR(/, Double);
  default:
    ERR << "Unhandled type for FDiv instruction: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
}

void Interpreter::executeFRemInst(GenericValue &Dest, GenericValue Src1, 
				  GenericValue Src2, Type *Ty) {
  switch (Ty->getTypeID()) {
  case Type::FloatTyID:
    Dest.FloatVal = fmod(Src1.FloatVal, Src2.FloatVal);
    break;
  case Type::DoubleTyID:
    Dest.DoubleVal = fmod(Src1.DoubleVal, Src2.DoubleVal);
    break;
  default:
    ERR << "Unhandled type for Rem instruction: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
}

#define IMPLEMENT_INTEGER_ICMP(OP, TY) \
   case Type::IntegerTyID:  \
      Dest.IntVal = APInt(1,Src1.IntVal.OP(Src2.IntVal)); \
      break;

#define IMPLEMENT_VECTOR_INTEGER_ICMP(OP, TY)                        \
  case Type::VectorTyID: {                                           \
    assert(Src1.AggregateVal.size() == Src2.AggregateVal.size());    \
    Dest.AggregateVal.resize( Src1.AggregateVal.size() );            \
    for( uint32_t _i=0;_i<Src1.AggregateVal.size();_i++)             \
      Dest.AggregateVal[_i].IntVal = APInt(1,                        \
      Src1.AggregateVal[_i].IntVal.OP(Src2.AggregateVal[_i].IntVal));\
  } break;

// Handle pointers specially because they must be compared with only as much
// width as the host has.  We _do not_ want to be comparing 64 bit values when
// running on a 32-bit target, otherwise the upper 32 bits might mess up
// comparisons if they contain garbage.
#define IMPLEMENT_POINTER_ICMP(OP) \
   case Type::PointerTyID: \
      Dest.IntVal = APInt(1,(void*)(intptr_t)Src1.PointerVal OP \
                            (void*)(intptr_t)Src2.PointerVal); \
      break;

static GenericValue executeICMP_EQ(GenericValue Src1, GenericValue Src2,
                                   Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_INTEGER_ICMP(eq,Ty);
    IMPLEMENT_VECTOR_INTEGER_ICMP(eq,Ty);
    IMPLEMENT_POINTER_ICMP(==);
  default:
    ERR << "Unhandled type for ICMP_EQ predicate: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

static GenericValue executeICMP_NE(GenericValue Src1, GenericValue Src2,
                                   Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_INTEGER_ICMP(ne,Ty);
    IMPLEMENT_VECTOR_INTEGER_ICMP(ne,Ty);
    IMPLEMENT_POINTER_ICMP(!=);
  default:
    ERR << "Unhandled type for ICMP_NE predicate: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

static GenericValue executeICMP_ULT(GenericValue Src1, GenericValue Src2,
                                    Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_INTEGER_ICMP(ult,Ty);
    IMPLEMENT_VECTOR_INTEGER_ICMP(ult,Ty);
    IMPLEMENT_POINTER_ICMP(<);
  default:
    ERR << "Unhandled type for ICMP_ULT predicate: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

static GenericValue executeICMP_SLT(GenericValue Src1, GenericValue Src2,
                                    Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_INTEGER_ICMP(slt,Ty);
    IMPLEMENT_VECTOR_INTEGER_ICMP(slt,Ty);
    IMPLEMENT_POINTER_ICMP(<);
  default:
    ERR << "Unhandled type for ICMP_SLT predicate: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

static GenericValue executeICMP_UGT(GenericValue Src1, GenericValue Src2,
                                    Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_INTEGER_ICMP(ugt,Ty);
    IMPLEMENT_VECTOR_INTEGER_ICMP(ugt,Ty);
    IMPLEMENT_POINTER_ICMP(>);
  default:
    ERR << "Unhandled type for ICMP_UGT predicate: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

static GenericValue executeICMP_SGT(GenericValue Src1, GenericValue Src2,
                                    Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_INTEGER_ICMP(sgt,Ty);
    IMPLEMENT_VECTOR_INTEGER_ICMP(sgt,Ty);
    IMPLEMENT_POINTER_ICMP(>);
  default:
    ERR << "Unhandled type for ICMP_SGT predicate: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

static GenericValue executeICMP_ULE(GenericValue Src1, GenericValue Src2,
                                    Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_INTEGER_ICMP(ule,Ty);
    IMPLEMENT_VECTOR_INTEGER_ICMP(ule,Ty);
    IMPLEMENT_POINTER_ICMP(<=);
  default:
    ERR << "Unhandled type for ICMP_ULE predicate: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

static GenericValue executeICMP_SLE(GenericValue Src1, GenericValue Src2,
                                    Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_INTEGER_ICMP(sle,Ty);
    IMPLEMENT_VECTOR_INTEGER_ICMP(sle,Ty);
    IMPLEMENT_POINTER_ICMP(<=);
  default:
    ERR << "Unhandled type for ICMP_SLE predicate: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

static GenericValue executeICMP_UGE(GenericValue Src1, GenericValue Src2,
                                    Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_INTEGER_ICMP(uge,Ty);
    IMPLEMENT_VECTOR_INTEGER_ICMP(uge,Ty);
    IMPLEMENT_POINTER_ICMP(>=);
  default:
    ERR << "Unhandled type for ICMP_UGE predicate: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

static GenericValue executeICMP_SGE(GenericValue Src1, GenericValue Src2,
                                    Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_INTEGER_ICMP(sge,Ty);
    IMPLEMENT_VECTOR_INTEGER_ICMP(sge,Ty);
    IMPLEMENT_POINTER_ICMP(>=);
  default:
    ERR << "Unhandled type for ICMP_SGE predicate: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

void Interpreter::visitICmpInst(ICmpInst &I) {
  ExecutionContext &SF = ECStack.back();
  Type *Ty    = I.getOperand(0)->getType();
  AbsGenericValue ASrc1 = getOperandValue(I.getOperand(0), SF);
  AbsGenericValue ASrc2 = getOperandValue(I.getOperand(1), SF);
  AbsGenericValue R;   // Result

  if (ASrc1.hasValue() && ASrc2.hasValue()) {
    GenericValue Src1 = ASrc1.getValue();
    GenericValue Src2 = ASrc2.getValue();
    switch (I.getPredicate()) {
    case ICmpInst::ICMP_EQ:
      R = AbsGenericValue(executeICMP_EQ(Src1, Src2, Ty));
      break;
    case ICmpInst::ICMP_NE:
      R = AbsGenericValue(executeICMP_NE(Src1, Src2, Ty));
      break;
    case ICmpInst::ICMP_ULT:
      R = AbsGenericValue(executeICMP_ULT(Src1, Src2, Ty));
      break;
    case ICmpInst::ICMP_SLT:
      R = AbsGenericValue(executeICMP_SLT(Src1, Src2, Ty));
      break;
    case ICmpInst::ICMP_UGT:
      R = AbsGenericValue(executeICMP_UGT(Src1, Src2, Ty));
      break;
    case ICmpInst::ICMP_SGT:
      R = AbsGenericValue(executeICMP_SGT(Src1, Src2, Ty));
      break;
    case ICmpInst::ICMP_ULE:
      R = AbsGenericValue(executeICMP_ULE(Src1, Src2, Ty));
      break;
    case ICmpInst::ICMP_SLE:
      R = AbsGenericValue(executeICMP_SLE(Src1, Src2, Ty));
      break;
    case ICmpInst::ICMP_UGE:
      R = AbsGenericValue(executeICMP_UGE(Src1, Src2, Ty));
      break;
    case ICmpInst::ICMP_SGE:
      R = AbsGenericValue(executeICMP_SGE(Src1, Src2, Ty));
      break;
    default:
      ERR << "Don't know how to handle this ICmp predicate!\n-->" << I;
      llvm_unreachable(nullptr);
    }
  }

  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), R);
  LOG << "\n";
  
  SetValue(&I, R, SF);
}

#define IMPLEMENT_FCMP(OP, TY) \
   case Type::TY##TyID: \
     Dest.IntVal = APInt(1,Src1.TY##Val OP Src2.TY##Val); \
     break

#define IMPLEMENT_VECTOR_FCMP_T(OP, TY)                             \
  assert(Src1.AggregateVal.size() == Src2.AggregateVal.size());     \
  Dest.AggregateVal.resize( Src1.AggregateVal.size() );             \
  for( uint32_t _i=0;_i<Src1.AggregateVal.size();_i++)              \
    Dest.AggregateVal[_i].IntVal = APInt(1,                         \
    Src1.AggregateVal[_i].TY##Val OP Src2.AggregateVal[_i].TY##Val);\
  break;

#define IMPLEMENT_VECTOR_FCMP(OP)                                   \
  case Type::VectorTyID:                                            \
    if (cast<VectorType>(Ty)->getElementType()->isFloatTy()) {      \
      IMPLEMENT_VECTOR_FCMP_T(OP, Float);                           \
    } else {                                                        \
        IMPLEMENT_VECTOR_FCMP_T(OP, Double);                        \
    }

static GenericValue executeFCMP_OEQ(GenericValue Src1, GenericValue Src2,
                                   Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_FCMP(==, Float);
    IMPLEMENT_FCMP(==, Double);
    IMPLEMENT_VECTOR_FCMP(==);
  default:
    ERR << "Unhandled type for FCmp EQ instruction: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

#define IMPLEMENT_SCALAR_NANS(TY, X,Y)                                      \
  if (TY->isFloatTy()) {                                                    \
    if (X.FloatVal != X.FloatVal || Y.FloatVal != Y.FloatVal) {             \
      Dest.IntVal = APInt(1,false);                                         \
      return Dest;                                                          \
    }                                                                       \
  } else {                                                                  \
    if (X.DoubleVal != X.DoubleVal || Y.DoubleVal != Y.DoubleVal) {         \
      Dest.IntVal = APInt(1,false);                                         \
      return Dest;                                                          \
    }                                                                       \
  }

#define MASK_VECTOR_NANS_T(X,Y, TZ, FLAG)                                   \
  assert(X.AggregateVal.size() == Y.AggregateVal.size());                   \
  Dest.AggregateVal.resize( X.AggregateVal.size() );                        \
  for( uint32_t _i=0;_i<X.AggregateVal.size();_i++) {                       \
    if (X.AggregateVal[_i].TZ##Val != X.AggregateVal[_i].TZ##Val ||         \
        Y.AggregateVal[_i].TZ##Val != Y.AggregateVal[_i].TZ##Val)           \
      Dest.AggregateVal[_i].IntVal = APInt(1,FLAG);                         \
    else  {                                                                 \
      Dest.AggregateVal[_i].IntVal = APInt(1,!FLAG);                        \
    }                                                                       \
  }

#define MASK_VECTOR_NANS(TY, X,Y, FLAG)                                     \
  if (TY->isVectorTy()) {                                                   \
    if (cast<VectorType>(TY)->getElementType()->isFloatTy()) {              \
      MASK_VECTOR_NANS_T(X, Y, Float, FLAG)                                 \
    } else {                                                                \
      MASK_VECTOR_NANS_T(X, Y, Double, FLAG)                                \
    }                                                                       \
  }                                                                         \



static GenericValue executeFCMP_ONE(GenericValue Src1, GenericValue Src2,
                                    Type *Ty)
{
  GenericValue Dest;
  // if input is scalar value and Src1 or Src2 is NaN return false
  IMPLEMENT_SCALAR_NANS(Ty, Src1, Src2)
  // if vector input detect NaNs and fill mask
  MASK_VECTOR_NANS(Ty, Src1, Src2, false)
  GenericValue DestMask = Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_FCMP(!=, Float);
    IMPLEMENT_FCMP(!=, Double);
    IMPLEMENT_VECTOR_FCMP(!=);
    default:
      ERR << "Unhandled type for FCmp NE instruction: " << *Ty << "\n";
      llvm_unreachable(nullptr);
  }
  // in vector case mask out NaN elements
  if (Ty->isVectorTy())
    for( size_t _i=0; _i<Src1.AggregateVal.size(); _i++)
      if (DestMask.AggregateVal[_i].IntVal == false)
        Dest.AggregateVal[_i].IntVal = APInt(1,false);

  return Dest;
}

static GenericValue executeFCMP_OLE(GenericValue Src1, GenericValue Src2,
                                   Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_FCMP(<=, Float);
    IMPLEMENT_FCMP(<=, Double);
    IMPLEMENT_VECTOR_FCMP(<=);
  default:
    ERR << "Unhandled type for FCmp LE instruction: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

static GenericValue executeFCMP_OGE(GenericValue Src1, GenericValue Src2,
                                   Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_FCMP(>=, Float);
    IMPLEMENT_FCMP(>=, Double);
    IMPLEMENT_VECTOR_FCMP(>=);
  default:
    ERR << "Unhandled type for FCmp GE instruction: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

static GenericValue executeFCMP_OLT(GenericValue Src1, GenericValue Src2,
                                   Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_FCMP(<, Float);
    IMPLEMENT_FCMP(<, Double);
    IMPLEMENT_VECTOR_FCMP(<);
  default:
    ERR << "Unhandled type for FCmp LT instruction: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

static GenericValue executeFCMP_OGT(GenericValue Src1, GenericValue Src2,
                                     Type *Ty) {
  GenericValue Dest;
  switch (Ty->getTypeID()) {
    IMPLEMENT_FCMP(>, Float);
    IMPLEMENT_FCMP(>, Double);
    IMPLEMENT_VECTOR_FCMP(>);
  default:
    ERR << "Unhandled type for FCmp GT instruction: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }
  return Dest;
}

#define IMPLEMENT_UNORDERED(TY, X,Y)                                     \
  if (TY->isFloatTy()) {                                                 \
    if (X.FloatVal != X.FloatVal || Y.FloatVal != Y.FloatVal) {          \
      Dest.IntVal = APInt(1,true);                                       \
      return Dest;                                                       \
    }                                                                    \
  } else if (X.DoubleVal != X.DoubleVal || Y.DoubleVal != Y.DoubleVal) { \
    Dest.IntVal = APInt(1,true);                                         \
    return Dest;                                                         \
  }

#define IMPLEMENT_VECTOR_UNORDERED(TY, X, Y, FUNC)                             \
  if (TY->isVectorTy()) {                                                      \
    GenericValue DestMask = Dest;                                              \
    Dest = FUNC(Src1, Src2, Ty);                                               \
    for (size_t _i = 0; _i < Src1.AggregateVal.size(); _i++)                   \
      if (DestMask.AggregateVal[_i].IntVal == true)                            \
        Dest.AggregateVal[_i].IntVal = APInt(1, true);                         \
    return Dest;                                                               \
  }

static GenericValue executeFCMP_UEQ(GenericValue Src1, GenericValue Src2,
                                   Type *Ty) {
  GenericValue Dest;
  IMPLEMENT_UNORDERED(Ty, Src1, Src2)
  MASK_VECTOR_NANS(Ty, Src1, Src2, true)
  IMPLEMENT_VECTOR_UNORDERED(Ty, Src1, Src2, executeFCMP_OEQ)
  return executeFCMP_OEQ(Src1, Src2, Ty);

}

static GenericValue executeFCMP_UNE(GenericValue Src1, GenericValue Src2,
                                   Type *Ty) {
  GenericValue Dest;
  IMPLEMENT_UNORDERED(Ty, Src1, Src2)
  MASK_VECTOR_NANS(Ty, Src1, Src2, true)
  IMPLEMENT_VECTOR_UNORDERED(Ty, Src1, Src2, executeFCMP_ONE)
  return executeFCMP_ONE(Src1, Src2, Ty);
}

static GenericValue executeFCMP_ULE(GenericValue Src1, GenericValue Src2,
                                   Type *Ty) {
  GenericValue Dest;
  IMPLEMENT_UNORDERED(Ty, Src1, Src2)
  MASK_VECTOR_NANS(Ty, Src1, Src2, true)
  IMPLEMENT_VECTOR_UNORDERED(Ty, Src1, Src2, executeFCMP_OLE)
  return executeFCMP_OLE(Src1, Src2, Ty);
}

static GenericValue executeFCMP_UGE(GenericValue Src1, GenericValue Src2,
                                   Type *Ty) {
  GenericValue Dest;
  IMPLEMENT_UNORDERED(Ty, Src1, Src2)
  MASK_VECTOR_NANS(Ty, Src1, Src2, true)
  IMPLEMENT_VECTOR_UNORDERED(Ty, Src1, Src2, executeFCMP_OGE)
  return executeFCMP_OGE(Src1, Src2, Ty);
}

static GenericValue executeFCMP_ULT(GenericValue Src1, GenericValue Src2,
                                   Type *Ty) {
  GenericValue Dest;
  IMPLEMENT_UNORDERED(Ty, Src1, Src2)
  MASK_VECTOR_NANS(Ty, Src1, Src2, true)
  IMPLEMENT_VECTOR_UNORDERED(Ty, Src1, Src2, executeFCMP_OLT)
  return executeFCMP_OLT(Src1, Src2, Ty);
}

static GenericValue executeFCMP_UGT(GenericValue Src1, GenericValue Src2,
                                     Type *Ty) {
  GenericValue Dest;
  IMPLEMENT_UNORDERED(Ty, Src1, Src2)
  MASK_VECTOR_NANS(Ty, Src1, Src2, true)
  IMPLEMENT_VECTOR_UNORDERED(Ty, Src1, Src2, executeFCMP_OGT)
  return executeFCMP_OGT(Src1, Src2, Ty);
}

static GenericValue executeFCMP_ORD(GenericValue Src1, GenericValue Src2,
                                     Type *Ty) {
  GenericValue Dest;
  if(Ty->isVectorTy()) {
    assert(Src1.AggregateVal.size() == Src2.AggregateVal.size());
    Dest.AggregateVal.resize( Src1.AggregateVal.size() );
    if (cast<VectorType>(Ty)->getElementType()->isFloatTy()) {
      for( size_t _i=0;_i<Src1.AggregateVal.size();_i++)
        Dest.AggregateVal[_i].IntVal = APInt(1,
        ( (Src1.AggregateVal[_i].FloatVal ==
        Src1.AggregateVal[_i].FloatVal) &&
        (Src2.AggregateVal[_i].FloatVal ==
        Src2.AggregateVal[_i].FloatVal)));
    } else {
      for( size_t _i=0;_i<Src1.AggregateVal.size();_i++)
        Dest.AggregateVal[_i].IntVal = APInt(1,
        ( (Src1.AggregateVal[_i].DoubleVal ==
        Src1.AggregateVal[_i].DoubleVal) &&
        (Src2.AggregateVal[_i].DoubleVal ==
        Src2.AggregateVal[_i].DoubleVal)));
    }
  } else if (Ty->isFloatTy())
    Dest.IntVal = APInt(1,(Src1.FloatVal == Src1.FloatVal && 
                           Src2.FloatVal == Src2.FloatVal));
  else {
    Dest.IntVal = APInt(1,(Src1.DoubleVal == Src1.DoubleVal && 
                           Src2.DoubleVal == Src2.DoubleVal));
  }
  return Dest;
}

static GenericValue executeFCMP_UNO(GenericValue Src1, GenericValue Src2,
                                     Type *Ty) {
  GenericValue Dest;
  if(Ty->isVectorTy()) {
    assert(Src1.AggregateVal.size() == Src2.AggregateVal.size());
    Dest.AggregateVal.resize( Src1.AggregateVal.size() );
    if (cast<VectorType>(Ty)->getElementType()->isFloatTy()) {
      for( size_t _i=0;_i<Src1.AggregateVal.size();_i++)
        Dest.AggregateVal[_i].IntVal = APInt(1,
        ( (Src1.AggregateVal[_i].FloatVal !=
           Src1.AggregateVal[_i].FloatVal) ||
          (Src2.AggregateVal[_i].FloatVal !=
           Src2.AggregateVal[_i].FloatVal)));
      } else {
        for( size_t _i=0;_i<Src1.AggregateVal.size();_i++)
          Dest.AggregateVal[_i].IntVal = APInt(1,
          ( (Src1.AggregateVal[_i].DoubleVal !=
             Src1.AggregateVal[_i].DoubleVal) ||
            (Src2.AggregateVal[_i].DoubleVal !=
             Src2.AggregateVal[_i].DoubleVal)));
      }
  } else if (Ty->isFloatTy())
    Dest.IntVal = APInt(1,(Src1.FloatVal != Src1.FloatVal || 
                           Src2.FloatVal != Src2.FloatVal));
  else {
    Dest.IntVal = APInt(1,(Src1.DoubleVal != Src1.DoubleVal || 
                           Src2.DoubleVal != Src2.DoubleVal));
  }
  return Dest;
}

static GenericValue executeFCMP_BOOL(GenericValue Src1, GenericValue Src2,
                                     Type *Ty, const bool val) {
  GenericValue Dest;
    if(Ty->isVectorTy()) {
      assert(Src1.AggregateVal.size() == Src2.AggregateVal.size());
      Dest.AggregateVal.resize( Src1.AggregateVal.size() );
      for( size_t _i=0; _i<Src1.AggregateVal.size(); _i++)
        Dest.AggregateVal[_i].IntVal = APInt(1,val);
    } else {
      Dest.IntVal = APInt(1, val);
    }

    return Dest;
}

void Interpreter::visitFCmpInst(FCmpInst &I) {
  ExecutionContext &SF = ECStack.back();
  Type *Ty    = I.getOperand(0)->getType();
  AbsGenericValue ASrc1 = getOperandValue(I.getOperand(0), SF);
  AbsGenericValue ASrc2 = getOperandValue(I.getOperand(1), SF);
  AbsGenericValue R;   // Result

  if (ASrc1.hasValue() && ASrc2.hasValue()) {
    GenericValue Src1 = ASrc1.getValue();
    GenericValue Src2 = ASrc2.getValue();
    switch (I.getPredicate()) {
    default:
      ERR << "Don't know how to handle this FCmp predicate!\n-->" << I;
      llvm_unreachable(nullptr);
      break;
    case FCmpInst::FCMP_FALSE:
      R = AbsGenericValue(executeFCMP_BOOL(Src1, Src2, Ty, false)); 
      break;
    case FCmpInst::FCMP_TRUE:
      R = AbsGenericValue(executeFCMP_BOOL(Src1, Src2, Ty, true)); 
      break;
    case FCmpInst::FCMP_ORD:
      R = AbsGenericValue(executeFCMP_ORD(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_UNO:
      R = AbsGenericValue(executeFCMP_UNO(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_UEQ:
      R = AbsGenericValue(executeFCMP_UEQ(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_OEQ:
      R = AbsGenericValue(executeFCMP_OEQ(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_UNE:
      R = AbsGenericValue(executeFCMP_UNE(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_ONE:
      R = AbsGenericValue(executeFCMP_ONE(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_ULT:
      R = AbsGenericValue(executeFCMP_ULT(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_OLT:
      R = AbsGenericValue(executeFCMP_OLT(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_UGT:
      R = AbsGenericValue(executeFCMP_UGT(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_OGT:
      R = AbsGenericValue(executeFCMP_OGT(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_ULE:
      R = AbsGenericValue(executeFCMP_ULE(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_OLE:
      R = AbsGenericValue(executeFCMP_OLE(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_UGE:
      R = AbsGenericValue(executeFCMP_UGE(Src1, Src2, Ty));
      break;
    case FCmpInst::FCMP_OGE:
      R = AbsGenericValue(executeFCMP_OGE(Src1, Src2, Ty));
      break;
    }
  }

  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), R);
  LOG << "\n";
  
  SetValue(&I, R, SF);
}

GenericValue Interpreter::executeCmpInst(unsigned predicate, GenericValue Src1, 
					 GenericValue Src2, Type *Ty) {
  GenericValue Result;
  switch (predicate) {
  case ICmpInst::ICMP_EQ:    return executeICMP_EQ(Src1, Src2, Ty);
  case ICmpInst::ICMP_NE:    return executeICMP_NE(Src1, Src2, Ty);
  case ICmpInst::ICMP_UGT:   return executeICMP_UGT(Src1, Src2, Ty);
  case ICmpInst::ICMP_SGT:   return executeICMP_SGT(Src1, Src2, Ty);
  case ICmpInst::ICMP_ULT:   return executeICMP_ULT(Src1, Src2, Ty);
  case ICmpInst::ICMP_SLT:   return executeICMP_SLT(Src1, Src2, Ty);
  case ICmpInst::ICMP_UGE:   return executeICMP_UGE(Src1, Src2, Ty);
  case ICmpInst::ICMP_SGE:   return executeICMP_SGE(Src1, Src2, Ty);
  case ICmpInst::ICMP_ULE:   return executeICMP_ULE(Src1, Src2, Ty);
  case ICmpInst::ICMP_SLE:   return executeICMP_SLE(Src1, Src2, Ty);
  case FCmpInst::FCMP_ORD:   return executeFCMP_ORD(Src1, Src2, Ty);
  case FCmpInst::FCMP_UNO:   return executeFCMP_UNO(Src1, Src2, Ty);
  case FCmpInst::FCMP_OEQ:   return executeFCMP_OEQ(Src1, Src2, Ty);
  case FCmpInst::FCMP_UEQ:   return executeFCMP_UEQ(Src1, Src2, Ty);
  case FCmpInst::FCMP_ONE:   return executeFCMP_ONE(Src1, Src2, Ty);
  case FCmpInst::FCMP_UNE:   return executeFCMP_UNE(Src1, Src2, Ty);
  case FCmpInst::FCMP_OLT:   return executeFCMP_OLT(Src1, Src2, Ty);
  case FCmpInst::FCMP_ULT:   return executeFCMP_ULT(Src1, Src2, Ty);
  case FCmpInst::FCMP_OGT:   return executeFCMP_OGT(Src1, Src2, Ty);
  case FCmpInst::FCMP_UGT:   return executeFCMP_UGT(Src1, Src2, Ty);
  case FCmpInst::FCMP_OLE:   return executeFCMP_OLE(Src1, Src2, Ty);
  case FCmpInst::FCMP_ULE:   return executeFCMP_ULE(Src1, Src2, Ty);
  case FCmpInst::FCMP_OGE:   return executeFCMP_OGE(Src1, Src2, Ty);
  case FCmpInst::FCMP_UGE:   return executeFCMP_UGE(Src1, Src2, Ty);
  case FCmpInst::FCMP_FALSE: return executeFCMP_BOOL(Src1, Src2, Ty, false);
  case FCmpInst::FCMP_TRUE:  return executeFCMP_BOOL(Src1, Src2, Ty, true);
  default:
    ERR << "Unhandled Cmp predicate\n";
    llvm_unreachable(nullptr);
  }
}

void Interpreter::visitBinaryOperator(BinaryOperator &I) {
  ExecutionContext &SF = ECStack.back();
  Type *Ty    = I.getOperand(0)->getType();
  AbsGenericValue ASrc1 = getOperandValue(I.getOperand(0), SF);
  AbsGenericValue ASrc2 = getOperandValue(I.getOperand(1), SF);

  if (!ASrc1.hasValue() || !ASrc2.hasValue()) {
    //TODO: if And and one operand is false then return false
    //      if Or  and one operand is true then return true
    //      if Mul and one operand is zero then return zero
    //      if Div and numerator is zero then return zero
    LOG << "skipped " << I << "\n";
    SetValue(&I, llvm::None, SF);
    return;
  }

  GenericValue Src1 = ASrc1.getValue();
  GenericValue Src2 = ASrc2.getValue();
  GenericValue R;   // Result

  // First process vector operation
  if (Ty->isVectorTy()) {
    assert(Src1.AggregateVal.size() == Src2.AggregateVal.size());
    R.AggregateVal.resize(Src1.AggregateVal.size());

    // Macros to execute binary operation 'OP' over integer vectors
#define INTEGER_VECTOR_OPERATION(OP)                               \
    for (unsigned i = 0; i < R.AggregateVal.size(); ++i)           \
      R.AggregateVal[i].IntVal =                                   \
      Src1.AggregateVal[i].IntVal OP Src2.AggregateVal[i].IntVal;

    // Additional macros to execute binary operations udiv/sdiv/urem/srem since
    // they have different notation.
#define INTEGER_VECTOR_FUNCTION(OP)                                \
    for (unsigned i = 0; i < R.AggregateVal.size(); ++i)           \
      R.AggregateVal[i].IntVal =                                   \
      Src1.AggregateVal[i].IntVal.OP(Src2.AggregateVal[i].IntVal);

    // Macros to execute binary operation 'OP' over floating point type TY
    // (float or double) vectors
#define FLOAT_VECTOR_FUNCTION(OP, TY)                               \
      for (unsigned i = 0; i < R.AggregateVal.size(); ++i)          \
        R.AggregateVal[i].TY =                                      \
        Src1.AggregateVal[i].TY OP Src2.AggregateVal[i].TY;

    // Macros to choose appropriate TY: float or double and run operation
    // execution
#define FLOAT_VECTOR_OP(OP) {                                         \
  if (cast<VectorType>(Ty)->getElementType()->isFloatTy())            \
    FLOAT_VECTOR_FUNCTION(OP, FloatVal)                               \
  else {                                                              \
    if (cast<VectorType>(Ty)->getElementType()->isDoubleTy())         \
      FLOAT_VECTOR_FUNCTION(OP, DoubleVal)                            \
    else {                                                            \
      ERR << "Unhandled type for OP instruction: " << *Ty << "\n"; \
      llvm_unreachable(0);                                            \
    }                                                                 \
  }                                                                   \
}

    switch(I.getOpcode()){
    default:
      ERR << "Don't know how to handle this binary operator!\n-->" << I;
      llvm_unreachable(nullptr);
      break;
    case Instruction::Add:   INTEGER_VECTOR_OPERATION(+) break;
    case Instruction::Sub:   INTEGER_VECTOR_OPERATION(-) break;
    case Instruction::Mul:   INTEGER_VECTOR_OPERATION(*) break;
    case Instruction::UDiv:  INTEGER_VECTOR_FUNCTION(udiv) break;
    case Instruction::SDiv:  INTEGER_VECTOR_FUNCTION(sdiv) break;
    case Instruction::URem:  INTEGER_VECTOR_FUNCTION(urem) break;
    case Instruction::SRem:  INTEGER_VECTOR_FUNCTION(srem) break;
    case Instruction::And:   INTEGER_VECTOR_OPERATION(&) break;
    case Instruction::Or:    INTEGER_VECTOR_OPERATION(|) break;
    case Instruction::Xor:   INTEGER_VECTOR_OPERATION(^) break;
    case Instruction::FAdd:  FLOAT_VECTOR_OP(+) break;
    case Instruction::FSub:  FLOAT_VECTOR_OP(-) break;
    case Instruction::FMul:  FLOAT_VECTOR_OP(*) break;
    case Instruction::FDiv:  FLOAT_VECTOR_OP(/) break;
    case Instruction::FRem:
      if (cast<VectorType>(Ty)->getElementType()->isFloatTy())
        for (unsigned i = 0; i < R.AggregateVal.size(); ++i)
          R.AggregateVal[i].FloatVal = 
          fmod(Src1.AggregateVal[i].FloatVal, Src2.AggregateVal[i].FloatVal);
      else {
        if (cast<VectorType>(Ty)->getElementType()->isDoubleTy())
          for (unsigned i = 0; i < R.AggregateVal.size(); ++i)
            R.AggregateVal[i].DoubleVal = 
            fmod(Src1.AggregateVal[i].DoubleVal, Src2.AggregateVal[i].DoubleVal);
        else {
          ERR << "Unhandled type for Rem instruction: " << *Ty << "\n";
          llvm_unreachable(nullptr);
        }
      }
      break;
    }
  } else {
    switch (I.getOpcode()) {
    default:
      ERR << "Don't know how to handle this binary operator!\n-->" << I;
      llvm_unreachable(nullptr);
      break;
    case Instruction::Add:   R.IntVal = Src1.IntVal + Src2.IntVal; break;
    case Instruction::Sub:   R.IntVal = Src1.IntVal - Src2.IntVal; break;
    case Instruction::Mul:   R.IntVal = Src1.IntVal * Src2.IntVal; break;
    case Instruction::FAdd:  executeFAddInst(R, Src1, Src2, Ty); break;
    case Instruction::FSub:  executeFSubInst(R, Src1, Src2, Ty); break;
    case Instruction::FMul:  executeFMulInst(R, Src1, Src2, Ty); break;
    case Instruction::FDiv:  executeFDivInst(R, Src1, Src2, Ty); break;
    case Instruction::FRem:  executeFRemInst(R, Src1, Src2, Ty); break;
    case Instruction::UDiv:  R.IntVal = Src1.IntVal.udiv(Src2.IntVal); break;
    case Instruction::SDiv:  R.IntVal = Src1.IntVal.sdiv(Src2.IntVal); break;
    case Instruction::URem:  R.IntVal = Src1.IntVal.urem(Src2.IntVal); break;
    case Instruction::SRem:  R.IntVal = Src1.IntVal.srem(Src2.IntVal); break;
    case Instruction::And:   R.IntVal = Src1.IntVal & Src2.IntVal; break;
    case Instruction::Or:    R.IntVal = Src1.IntVal | Src2.IntVal; break;
    case Instruction::Xor:   R.IntVal = Src1.IntVal ^ Src2.IntVal; break;
    }
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), R);
  LOG << "\n";
  SetValue(&I, AbsGenericValue(R), SF);
}

GenericValue Interpreter::executeSelectInst(GenericValue Src1, GenericValue Src2,
					    GenericValue Src3, Type *Ty) {
    GenericValue Dest;
    if(Ty->isVectorTy()) {
      assert(Src1.AggregateVal.size() == Src2.AggregateVal.size());
      assert(Src2.AggregateVal.size() == Src3.AggregateVal.size());
      Dest.AggregateVal.resize( Src1.AggregateVal.size() );
      for (size_t i = 0; i < Src1.AggregateVal.size(); ++i)
        Dest.AggregateVal[i] = (Src1.AggregateVal[i].IntVal == 0) ?
          Src3.AggregateVal[i] : Src2.AggregateVal[i];
    } else {
      Dest = (Src1.IntVal == 0) ? Src3 : Src2;
    }
    return Dest;
}

void Interpreter::visitSelectInst(SelectInst &I) {
  ExecutionContext &SF = ECStack.back();
  Type * Ty = I.getOperand(0)->getType();
  AbsGenericValue ASrc1 = getOperandValue(I.getOperand(0), SF);
  AbsGenericValue ASrc2 = getOperandValue(I.getOperand(1), SF);
  AbsGenericValue ASrc3 = getOperandValue(I.getOperand(2), SF);

  if (Ty->isVectorTy()) {
    if (ASrc1.hasValue() && ASrc2.hasValue() && ASrc3.hasValue()) {
      GenericValue Src1 = ASrc1.getValue();
      GenericValue Src2 = ASrc2.getValue();
      GenericValue Src3 = ASrc3.getValue();    
      AbsGenericValue R = AbsGenericValue(executeSelectInst(Src1, Src2, Src3, Ty));
      SetValue(&I, R, SF);
    } else {
      LOG << "skipped " << I << "\n";      
      SetValue(&I, llvm::None, SF);
    }
  } else {
    if (!ASrc1.hasValue()) {
      LOG << "skipped " << I << "\n";      
      SetValue(&I, llvm::None, SF);
    } else {
      GenericValue Src1 = ASrc1.getValue();
      if (Src1.IntVal == 0) {
	SetValue(&I, ASrc3, SF);
      } else {
	SetValue(&I, ASrc2, SF);
      }
    }
  }
}

//===----------------------------------------------------------------------===//
//                     Terminator Instruction Implementations
//===----------------------------------------------------------------------===//

void Interpreter::exitCalled(GenericValue GV) {
  // runAtExitHandlers() assumes there are no stack frames, but
  // if exit() was called, then it had a stack frame. Blow away
  // the stack before interpreting atexit handlers.
  ECStack.clear();
  runAtExitHandlers();
  exit(GV.IntVal.zextOrTrunc(32).getZExtValue());
}

/// Pop the last stack frame off of ECStack and then copy the result
/// back into the result variable if we are not returning void. The
/// result variable may be the ExitValue, or the Value of the calling
/// CallInst if there was a previous stack frame. This method may
/// invalidate any ECStack iterators you have. This method also takes
/// care of switching to the normal destination BB, if we are returning
/// from an invoke.
///
void Interpreter::popStackAndReturnValueToCaller(Type *RetTy,
                                                 AbsGenericValue Result) {
  // Pop the current stack frame.
  ECStack.pop_back();

  if (ECStack.empty()) {  // Finished main.  Put result into exit code...
    if (RetTy && !RetTy->isVoidTy()) {          // Nonvoid return type?
      // Capture the exit value of the program
      if (Result.hasValue()) {
	ExitValue = Result.getValue();
      } else {
	// if the result is unknown we pretend the program succeed	
	memset(&ExitValue.Untyped, 0, sizeof(ExitValue.Untyped));
      }
    } else {
      memset(&ExitValue.Untyped, 0, sizeof(ExitValue.Untyped));
    }
  } else {
    // If we have a previous stack frame, and we have a previous call,
    // fill in the return value...
    ExecutionContext &CallingSF = ECStack.back();
    if (Instruction *I = CallingSF.Caller.getInstruction()) {
      // Save result...
      if (!CallingSF.Caller.getType()->isVoidTy())
        SetValue(I, Result, CallingSF);
      if (InvokeInst *II = dyn_cast<InvokeInst> (I))
        SwitchToNewBasicBlock (II->getNormalDest (), CallingSF);
      CallingSF.Caller = CallSite();          // We returned from the call...
    }
  }
}

void Interpreter::visitReturnInst(ReturnInst &I) {
  ExecutionContext &SF = ECStack.back();
  Type *RetTy = Type::getVoidTy(I.getContext());
  AbsGenericValue Result;

  // Save away the return value... (if we are not 'ret void')
  if (I.getNumOperands()) {
    RetTy  = I.getReturnValue()->getType();
    Result = getOperandValue(I.getReturnValue(), SF);

    #ifdef DEBUG_PTR_PROVENANCE
    if (RetTy->isPointerTy()) {
      if (Result) {
	LOG << "Returned pointer ";      
	printAbsGenericValue(RetTy, Result);
	LOG << "\n";	
      }
    }
    #endif 
  }

  popStackAndReturnValueToCaller(RetTy, Result);
}

void Interpreter::visitUnreachableInst(UnreachableInst &I) {
  llvm::errs() << "ConfigPrime: modeling an 'unreachable' instruction "
	       << " as a return instruction with an unknown value.\n";

  Type *RetTy = I.getParent()->getParent()->getReturnType();
  AbsGenericValue Result;
  popStackAndReturnValueToCaller(RetTy, Result);
}

void Interpreter::visitBranchInst(BranchInst &I) {
  ExecutionContext &SF = ECStack.back();
  BasicBlock *Dest;

  Dest = I.getSuccessor(0);          // Uncond branches have a fixed dest...
  if (!I.isUnconditional()) {
    AbsGenericValue ACondVal = getOperandValue(I.getCondition(), SF);
    if (!ACondVal.hasValue()) {
#ifdef INTERACTIVE
      errs() << "#### Branch condition is unknown. Type 0 or 1: ";
      int c = getchar();
      GenericValue CondValFromUser;
      CondValFromUser.IntVal = c;
      ACondVal = AbsGenericValue(CondValFromUser);
#else      
      /// End of our execution: we cannot keep going
      errs() << "INTERPRETER STOPPED: cannot evaluate branch condition\n";
      StopExecution = true;
      return;
#endif       
    }

    // LOG << "\tCond=";
    // printAbsGenericValue(I.getCondition()->getType(), ACondVal);
    // LOG << "\n";
    
    if (ACondVal.getValue().IntVal == 0) // If false cond...
      Dest = I.getSuccessor(1);
  }
  SwitchToNewBasicBlock(Dest, SF);
}

void Interpreter::visitSwitchInst(SwitchInst &I) {
  ExecutionContext &SF = ECStack.back();
  Value* Cond = I.getCondition();
  Type *ElTy = Cond->getType();
  AbsGenericValue ACondVal = getOperandValue(Cond, SF);
  if (!ACondVal.hasValue()) {
    /// End of our execution: we cannot keep going
    errs() << "INTERPRETER STOPPED: cannot evaluate switch condition\n";    
    StopExecution = true;
    return;
  }
  
  // Check to see if any of the cases match...
  GenericValue CondVal = ACondVal.getValue();
  BasicBlock *Dest = nullptr;
  for (auto Case : I.cases()) {
    AbsGenericValue CaseVal = getOperandValue(Case.getCaseValue(), SF);
    assert(CaseVal.hasValue());
    if (executeICMP_EQ(CondVal, CaseVal.getValue(), ElTy).IntVal != 0) {
      Dest = cast<BasicBlock>(Case.getCaseSuccessor());
      break;
    }
  }
  if (!Dest) Dest = I.getDefaultDest();   // No cases matched: use default
  SwitchToNewBasicBlock(Dest, SF);
}

void Interpreter::visitIndirectBrInst(IndirectBrInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue AAddr = getOperandValue(I.getAddress(), SF);
  if (!AAddr.hasValue()) {
    /// End of our execution: we cannot keep going
    errs() << "INTERPRETER STOPPED: cannot evaluate indirect branch\n";        
    StopExecution = true;
    return;
  }
  
  void *Dest = GVTOP(AAddr.getValue());
  SwitchToNewBasicBlock((BasicBlock*)Dest, SF);
}


// SwitchToNewBasicBlock - This method is used to jump to a new basic block.
// This function handles the actual updating of block and instruction iterators
// as well as execution of all of the PHI nodes in the destination block.
//
// This method does this because all of the PHI nodes must be executed
// atomically, reading their inputs before any of the results are updated.  Not
// doing this can cause problems if the PHI nodes depend on other PHI nodes for
// their inputs.  If the input PHI node is updated before it is read, incorrect
// results can happen.  Thus we use a two phase approach.
//
void Interpreter::SwitchToNewBasicBlock(BasicBlock *Dest, ExecutionContext &SF){
  BasicBlock *PrevBB = SF.CurBB;      // Remember where we came from...
  SF.CurBB   = Dest;                  // Update CurBB to branch destination
  SF.CurInst = SF.CurBB->begin();     // Update new instruction ptr...

  if (!isa<PHINode>(SF.CurInst)) return;  // Nothing fancy to do

  // Loop over all of the PHI nodes in the current block, reading their inputs.
  std::vector<AbsGenericValue> ResultValues;

  for (; PHINode *PN = dyn_cast<PHINode>(SF.CurInst); ++SF.CurInst) {
    // Search for the value corresponding to this previous bb...
    int i = PN->getBasicBlockIndex(PrevBB);
    assert(i != -1 && "PHINode doesn't contain entry for predecessor??");
    Value *IncomingValue = PN->getIncomingValue(i);

    // Save the incoming value for this PHI node...
    ResultValues.push_back(getOperandValue(IncomingValue, SF));
  }

  // Now loop over all of the PHI nodes setting their values...
  SF.CurInst = SF.CurBB->begin();
  for (unsigned i = 0; isa<PHINode>(SF.CurInst); ++SF.CurInst, ++i) {
    PHINode *PN = cast<PHINode>(SF.CurInst);
    SetValue(PN, ResultValues[i], SF);
  }
}

//===----------------------------------------------------------------------===//
//                     Memory Instruction Implementations
//===----------------------------------------------------------------------===//

void Interpreter::visitAllocaInst(AllocaInst &I) {
  ExecutionContext &SF = ECStack.back();

  Type *Ty = I.getType()->getElementType();  // Type to be allocated

  AbsGenericValue ANumElement = getOperandValue(I.getOperand(0), SF);
  if (!ANumElement.hasValue()) {
    LOG << "Cannot allocate memory for " << I << "\n";
    SetValue(&I, llvm::None, SF);
    return;
  }
  
  // Get the number of elements being allocated by the array...
  unsigned NumElements = ANumElement.getValue().IntVal.getZExtValue();

  unsigned TypeSize = (size_t)getDataLayout().getTypeAllocSize(Ty);

  // Avoid malloc-ing zero bytes, use max()...
  unsigned MemToAlloc = std::max(1U, NumElements * TypeSize);

  // Allocate enough memory to hold the type...
  void *Memory = malloc(MemToAlloc);
#ifndef TRACK_ONLY_UNACCESSIBLE_MEM    
  ECStack.back().Allocas.addWithOwnershipTransfer(Memory, MemToAlloc);
  memlog("Allocated %d bytes: [%#lx,%#lx]\n",
	 MemToAlloc, intptr_t(Memory), intptr_t(Addr)+MemToAlloc);     
#endif   
  LOG << "Allocated stack Type: " << *Ty << " (" << TypeSize << " bytes) x " 
      << NumElements << " (Total: " << MemToAlloc << ") at "
      << Memory << "\n";

  GenericValue Result = PTOGV(Memory);
  assert(Result.PointerVal && "Null pointer returned by malloc!");
  SetValue(&I, AbsGenericValue(Result), SF);

}

void Interpreter::visitAllocFnInst(CallSite &CS) {
  ExecutionContext &SF = ECStack.back();
  const Function *Callee = CS.getCalledFunction();
  assert(Callee);
  if (Callee->getName() == "malloc") {
    AbsGenericValue SizeGV = getOperandValue(CS.getArgument(0), SF);
    if (!SizeGV.hasValue()) {
      LOG << "Cannot allocate memory for " << *CS.getInstruction() << "\n";
      SetValue(CS.getInstruction(), llvm::None, SF);
      return;
    }
    unsigned Size = SizeGV.getValue().IntVal.getZExtValue();
    void *Result = malloc(Size);
    memlog("Allocated heap memory: %d bytes at [%#lx,%#lx]\n",
	   Size, intptr_t(Result), intptr_t(Result)+Size);     
    GenericValue ResultGV = PTOGV(Result);
    SetValue(CS.getInstruction(), ResultGV, SF);
    
    // == update memory shadowing
    MemMallocs.addWithOwnershipTransfer(Result, Size);
  } else if (Callee->getName() == "realloc") {
    AbsGenericValue PtrGV = getOperandValue(CS.getArgument(0), SF);
    AbsGenericValue SizeGV = getOperandValue(CS.getArgument(1), SF);
    if (!PtrGV.hasValue() || !SizeGV.hasValue()) {
      LOG << "Cannot allocate memory for " << *CS.getInstruction() << "\n";
      SetValue(CS.getInstruction(), llvm::None, SF);
      return;
    }

    unsigned Size = SizeGV.getValue().IntVal.getZExtValue();
    void *Ptr = (void*)GVTOP(PtrGV.getValue());
    void *Result = realloc(Ptr, Size);
    memlog("Allocated heap memory: %d bytes at [%#lx,%#lx]\n",
	   Size, intptr_t(Result), intptr_t(Result)+Size);     
    GenericValue ResultGV = PTOGV(Result);
    SetValue(CS.getInstruction(), ResultGV, SF);

    // == update memory shadowing
    size_t OldSize;
    bool ok = MemMallocs.free(Ptr, OldSize); 
    if (ok) {
     #ifdef TRACK_ONLY_UNACCESSIBLE_MEM
      UnaccessibleMem.add(Ptr, OldSize);
      memlog("Marking as unaccessible %d bytes: [%#lx,%#lx]\n",
             OldSize, intptr_t(Ptr), intptr_t(Ptr)+OldSize);
     #endif  
    }
    MemMallocs.addWithOwnershipTransfer(Result, Size);
  } else if (Callee->getName() == "calloc") {
    AbsGenericValue NumGV  = getOperandValue(CS.getArgument(0), SF);
    AbsGenericValue SizeGV = getOperandValue(CS.getArgument(1), SF);    
    if (!NumGV.hasValue() || !SizeGV.hasValue()) {
      LOG << "Cannot allocate memory for " << *CS.getInstruction() << "\n";
      SetValue(CS.getInstruction(), llvm::None, SF);
      return;
    }
    unsigned Num  = NumGV.getValue().IntVal.getZExtValue();    
    unsigned Size = SizeGV.getValue().IntVal.getZExtValue();
    void *Result = calloc(Num, Size);
    // FIXME(https://en.cppreference.com/w/c/memory/calloc):
    // Due to the alignment requirements, the number of allocated
    // bytes is not necessarily equal to num*size.
    unsigned AllocatedBytes = Num*Size;    
    memlog("Allocated heap memory: %d bytes at [%#lx,%#lx]\n",
	   AllocatedBytes, intptr_t(Result), intptr_t(Result)+AllocatedBytes);     
    GenericValue ResultGV = PTOGV(Result);
    SetValue(CS.getInstruction(), ResultGV, SF);
    
    // == update memory shadowing
    MemMallocs.addWithOwnershipTransfer(Result, AllocatedBytes);
  } else {
    LOG << "Warning: unsupported allocation function " << *CS.getInstruction() << "\n";
  }
  
}

void Interpreter::visitFreeInst(CallSite &CS) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue PtrToFree = getOperandValue(CS.getArgument(0), SF);
  if (!PtrToFree.hasValue()) {
    LOG << "Warning: cannot free memory for " << *CS.getArgument(0) << "\n";
    return;
  } 

  void *Ptr = (void*)GVTOP(PtrToFree.getValue());
  size_t sz;
  bool ok = MemMallocs.free(Ptr, sz); // marked as free
  if (ok) {
    free(Ptr); // the actual free
    #ifdef TRACK_ONLY_UNACCESSIBLE_MEM
    UnaccessibleMem.add(Ptr, sz);
    memlog("Marking as unaccessible %d bytes: [%#lx,%#lx]\n",
           sz, intptr_t(Ptr), intptr_t(Ptr)+sz);
    #else
    memlog("Free bytes [%#lx,%#lx]\n", intptr_t(Ptr), intptr_t(Ptr)+sz);    
    #endif
  } else {
    LOG << "Warning: cannot free memory for " << *CS.getArgument(0)
	<< " because memory not recognized as allocated by the interpreter\n";
  }
}
  
// getElementOffset - The workhorse for getelementptr.
//
AbsGenericValue Interpreter::executeGEPOperation(Value *Ptr, gep_type_iterator I,
						 gep_type_iterator E,
						 ExecutionContext &SF) {
  assert(Ptr->getType()->isPointerTy() &&
         "Cannot getElementOffset of a nonpointer type!");

  AbsGenericValue APtrOp = getOperandValue(Ptr, SF);
  if (!APtrOp.hasValue()) {
    return llvm::None;
  }

  GenericValue PtrOp = APtrOp.getValue();  
  uint64_t Total = 0;

  for (; I != E; ++I) {
    if (StructType *STy = I.getStructTypeOrNull()) {
      const StructLayout *SLO = getDataLayout().getStructLayout(STy);

      const ConstantInt *CPU = cast<ConstantInt>(I.getOperand());
      unsigned Index = unsigned(CPU->getZExtValue());

      Total += SLO->getElementOffset(Index);
    } else {
      // Get the index number for the array... which must be long type...
      AbsGenericValue AIdxGV = getOperandValue(I.getOperand(), SF);
      if (!AIdxGV.hasValue()) {
	return llvm::None;
      }
      
      GenericValue IdxGV = AIdxGV.getValue();
      int64_t Idx;
      unsigned BitWidth = 
        cast<IntegerType>(I.getOperand()->getType())->getBitWidth();
      if (BitWidth == 32)
        Idx = (int64_t)(int32_t)IdxGV.IntVal.getZExtValue();
      else {
        assert(BitWidth == 64 && "Invalid index type for getelementptr");
        Idx = (int64_t)IdxGV.IntVal.getZExtValue();
      }
      Total += getDataLayout().getTypeAllocSize(I.getIndexedType()) * Idx;
    }
  }

  GenericValue Result;    
  Result.PointerVal = ((char*)PtrOp.PointerVal) + Total;
  LOG << "GEP Index " << Total << " bytes.\n";
  return AbsGenericValue(Result);
}

void Interpreter::visitGetElementPtrInst(GetElementPtrInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue Res = executeGEPOperation(I.getPointerOperand(),
					    gep_type_begin(I), gep_type_end(I), SF);
  if (!Res.hasValue()) {
    LOG << "skipped " << I << "\n";    
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), Res);
  LOG << "\n";
  
  SetValue(&I, Res, SF);
}

void Interpreter::visitLoadInst(LoadInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getPointerOperand(), SF);
  if (!ASrc.hasValue()) {
    LOG << "reading from an unknown pointer.\n";
    SetValue(&I, llvm::None, SF);    
    return;
  }
  GenericValue Src = ASrc.getValue();
  GenericValue *Ptr = (GenericValue*)GVTOP(Src);

  if (!isa<GlobalVariable>(I.getPointerOperand()->stripPointerCasts())) {
    // global variables are always allocated in memory and
    // isAllocatedMemory should know that. However, for global
    // variables like this one:
    // 
    //    @__stdoutp = external local_unnamed_addr global %struct.__sFILE*, align 8
    // 
    // isAllocatedMemory is unaware of.
    if (!isAllocatedMemory((void*) Ptr)) {
      LOG << "Reading from an untrackable memory location " << (void*)Ptr << ".\n";
      SetValue(&I, llvm::None, SF);        
      return;
    }
  }

  GenericValue Result;
  LoadValueFromMemory(Result, Ptr, I.getType());
  //GenericValue Result = readFromMemory(Ptr, I.getType());

  addExecutedMemInst(&I, Result);  
  
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), Result);
  LOG << "\n";

  SetValue(&I, Result, SF);
  // if (I.isVolatile() && PrintVolatile)
  //   dbgs() << "Volatile load " << I;
}

void Interpreter::visitStoreInst(StoreInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getPointerOperand(), SF);
  if (!ASrc.hasValue()) {
    LOG << "Writing to an unknown pointer.\n";
    return;
  }

  GenericValue Src = ASrc.getValue();
  GenericValue *Ptr = (GenericValue*)GVTOP(Src);
  
  AbsGenericValue AVal = getOperandValue(I.getOperand(0), SF);
  if (!AVal.hasValue()) {
    LOG << "Writing an unknown value\n";
    #ifdef TRACK_ONLY_UNACCESSIBLE_MEM
    // If we are here is because I.getOperand(0) must come from main's
    // argv
    Type *Ty = I.getOperand(0)->getType();
    const unsigned StoreBytes = getDataLayout().getTypeStoreSize(Ty);
    UnaccessibleMem.add((void*)Ptr, StoreBytes);
    memlog("Marking as unaccessible %d bytes: [%#lx,%#lx]\n",
	 StoreBytes, intptr_t(Ptr), intptr_t(Ptr)+StoreBytes);         
    #endif 
    return;
  }
  
  GenericValue Val = AVal.getValue();
  if (!isa<GlobalVariable>(I.getPointerOperand()->stripPointerCasts())) {
    // see explanation in VisitLoadInst
    if (!isAllocatedMemory((void*) Ptr)) {
      LOG << "Writing to untrackable memory location.\n";
      return;
    }
  }
  
  addExecutedMemInst(&I, Val);
  StoreValueToMemory(Val, Ptr, I.getOperand(0)->getType());
  
  // writeToMemory(Val, Ptr, I.getOperand(0)->getType());
  // if (I.isVolatile() && PrintVolatile)
  //   dbgs() << "Volatile store: " << I;
}

//===----------------------------------------------------------------------===//
//                 Miscellaneous Instruction Implementations
//===----------------------------------------------------------------------===//

void Interpreter::visitCallSite(CallSite CS) {
  ExecutionContext &SF = ECStack.back();

  // Check to see if this is an intrinsic function call...
  Value * V = CS.getCalledValue();
  V = V->stripPointerCasts();
  
  //Function *F = CS.getCalledFunction();
  Function *F = dyn_cast<Function>(V);
  if (F && F->isDeclaration()) {

    if (F->getName() == CONFIG_PRIME_STOP) {
      errs() << "INTERPRETER STOPPED: found " << *CS.getInstruction() << "\n";
      StopExecution = true;
      return;
    }
    

    if (isMallocLikeFn(*F)) {
      visitAllocFnInst(CS);
      return;
    }

    if (isFreeLikeFn(*F)) {
      visitFreeInst(CS);
      return;
    }
    
    // Ignore debug llvm functions
    if (F->getName().startswith("llvm.dbg")) {
      return;
    }
    
    switch (F->getIntrinsicID()) {
    case Intrinsic::not_intrinsic:
      break;
    case Intrinsic::vastart: { // va_start
      // This modeling of va_start assumes that the code uses VAArgInst
      // to access to each variable argument. However, the frontend
      // might lower VAArgInst so the interpreter will get lost.
      //

      #if 1
      // HACK if Clang does not add VAArgInst:
      // Assumes %struct.__va_list_tag = type { i32, i32, i8*, i8* }
      ExecutionContext &PenultimateSF = ECStack[ECStack.size()-2];
      if (Function *CalleeF = PenultimateSF.Caller.getCalledFunction()) {
	// Value *FirstVarArg =
	//   PenultimateSF.Caller.getArgument(
	//        (PenultimateSF.Caller.arg_size() - CalleeF->arg_size())+1);

	Value *FirstVarArg =
	  PenultimateSF.Caller.getArgument(0);
	
	llvm::errs() << "First vararg=" << FirstVarArg
		     << " -> " << *FirstVarArg << "\n";
	  
	assert(CS.getArgument(0)->getType()->isPointerTy());
	LLVMContext &ctx = CS.getInstruction()->getContext();	
	AbsGenericValue abs_va_list = getOperandValue(CS.getArgument(0),
						      SF);
	if (abs_va_list.hasValue()) {
	  GenericValue va_list = abs_va_list.getValue();
	  va_list.PointerVal = ((char*)va_list.PointerVal) + 8;	  
	  llvm::errs() << "Storing " << FirstVarArg 
		       << " to memory address="
		       << (void*)va_list.PointerVal << "\n";
	  Type *i8PtrTy = static_cast<Type*>(Type::getInt8PtrTy(ctx));
	  StoreValueToMemory(PTOGV(FirstVarArg), (GenericValue*)GVTOP(va_list), i8PtrTy);
	}
      }
      #endif 

      // Variable arguments are stored in ExecutionContext.VarArgs. A
      // variable argument is encoded as GenericValue.UIntPairVal
      // where the first pair element is the index in ECStack
      // associated to the last execution context and the second
      // element is 0 indicating the first variable
      // argument. VAArgInst will increase the second pair element
      // after each access.
      
      GenericValue ArgIndex;
      ArgIndex.UIntPairVal.first = ECStack.size() - 1;
      ArgIndex.UIntPairVal.second = 0;
      SetValue(CS.getInstruction(), AbsGenericValue(ArgIndex), SF);
      return;
    }
    case Intrinsic::vaend:    // va_end is a noop for the interpreter
      return;
    case Intrinsic::vacopy:   // va_copy: dest = src
      SetValue(CS.getInstruction(), getOperandValue(*CS.arg_begin(), SF), SF);
      return;
    case Intrinsic::uadd_sat:
    case Intrinsic::sadd_sat:
    case Intrinsic::usub_sat:
    case Intrinsic::ssub_sat:
      // LowerIntrinsicCall (llvm10) cannot lower these intrinsics
      #if 1
      // HACK: we approximate these intrinsics with +,-, and *
      {
	ExecutionContext &SF = ECStack.back();
	AbsGenericValue AOp1 = getOperandValue(CS.getArgument(0), SF);
	AbsGenericValue AOp2 = getOperandValue(CS.getArgument(1), SF);
	bool isVectorType = CS.getInstruction()->getType()->isVectorTy();
	if (AOp1.hasValue() && AOp2.hasValue()) {
	  GenericValue Op1 = AOp1.getValue();
	  GenericValue Op2 = AOp2.getValue();
	  GenericValue R;   // Result
	  if (F->getIntrinsicID() == Intrinsic::usub_sat ||
	      F->getIntrinsicID() == Intrinsic::ssub_sat) {
	      R.IntVal = Op1.IntVal - Op2.IntVal;
	  } else {
	    assert(F->getIntrinsicID() == Intrinsic::uadd_sat ||
		   F->getIntrinsicID() == Intrinsic::sadd_sat);
	    R.IntVal = Op1.IntVal + Op2.IntVal;
	  } 
	  SetValue(CS.getInstruction(), AbsGenericValue(R), SF);
	  return;
	} 
      }
      #endif 
      SetValue(CS.getInstruction(), llvm::None, SF);
      return;
    case Intrinsic::uadd_with_overflow:
    case Intrinsic::sadd_with_overflow:
    case Intrinsic::usub_with_overflow:
    case Intrinsic::ssub_with_overflow:
    case Intrinsic::umul_with_overflow:
    case Intrinsic::smul_with_overflow:
      // LowerIntrinsicCall (llvm10) cannot lower these intrinsics
      #if 1
      // HACK: we approximate these intrinsics with +,-, and * and
      // assume that there is overflow.
      {
	ExecutionContext &SF = ECStack.back();
	AbsGenericValue AOp1 = getOperandValue(CS.getArgument(0), SF);
	AbsGenericValue AOp2 = getOperandValue(CS.getArgument(1), SF);
	bool isVectorType = CS.getInstruction()->getType()->isVectorTy();
	if (AOp1.hasValue() && AOp2.hasValue()) {
	  GenericValue Op1 = AOp1.getValue();
	  GenericValue Op2 = AOp2.getValue();
	  GenericValue R;   // Result
	  R.AggregateVal.resize(2);
	  if (F->getIntrinsicID() == Intrinsic::usub_with_overflow ||
	      F->getIntrinsicID() == Intrinsic::ssub_with_overflow) {
	    R.AggregateVal[0].IntVal = Op1.IntVal - Op2.IntVal;
	    R.AggregateVal[1].IntVal = 0; // no overflow
	  } else if (F->getIntrinsicID() == Intrinsic::uadd_with_overflow ||
		     F->getIntrinsicID() == Intrinsic::sadd_with_overflow) {
	    R.AggregateVal[0].IntVal = Op1.IntVal + Op2.IntVal;	    
	    R.AggregateVal[1].IntVal = 0; // no overflow
	  } else {
	    assert(F->getIntrinsicID() == Intrinsic::umul_with_overflow ||
		   F->getIntrinsicID() == Intrinsic::smul_with_overflow);
	    R.AggregateVal[0].IntVal = Op1.IntVal * Op2.IntVal;	    	    
	    R.AggregateVal[1].IntVal = 0; // no overflow
	  }
	  SetValue(CS.getInstruction(), AbsGenericValue(R), SF);
	  return;
	}
      }
      #endif 
      SetValue(CS.getInstruction(), llvm::None, SF);
      return;
    default:
      // If it is an unknown intrinsic function, use the intrinsic lowering
      // class to transform it into hopefully tasty LLVM code.
      //
      BasicBlock::iterator me(CS.getInstruction());
      BasicBlock *Parent = CS.getInstruction()->getParent();
      bool atBegin(Parent->begin() == me);
      if (!atBegin)
        --me;
      IL->LowerIntrinsicCall(cast<CallInst>(CS.getInstruction()));

      // Restore the CurInst pointer to the first instruction newly inserted, if
      // any.
      if (atBegin) {
        SF.CurInst = Parent->begin();
      } else {
        SF.CurInst = me;
        ++SF.CurInst;
      }
      return;
    }
  }

  SF.Caller = CS;
  std::vector<AbsGenericValue> ArgVals;
  const unsigned NumArgs = SF.Caller.arg_size();
  ArgVals.reserve(NumArgs);
  uint16_t pNum = 1;
  for (CallSite::arg_iterator i = SF.Caller.arg_begin(),
         e = SF.Caller.arg_end(); i != e; ++i, ++pNum) {
    Value *V = *i;
    ArgVals.push_back(getOperandValue(V, SF));
  }

  // To handle indirect calls, we must get the pointer value from the argument
  // and treat it as a function pointer.
  AbsGenericValue SRC = getOperandValue(SF.Caller.getCalledValue(), SF);

  if (!SRC.hasValue()) {
    errs() << "INTERPRETER STOPPED: cannot resolve indirect call.\n";
    StopExecution = true;
  } else {
    // This call can also set StopExecution to true
    callFunction((Function*)GVTOP(SRC.getValue()), ArgVals,
		 CS.getInstruction());
  }
}

// auxiliary function for shift operations
static unsigned getShiftAmount(uint64_t orgShiftAmount,
                               llvm::APInt valueToShift) {
  unsigned valueWidth = valueToShift.getBitWidth();
  if (orgShiftAmount < (uint64_t)valueWidth)
    return orgShiftAmount;
  // according to the llvm documentation, if orgShiftAmount > valueWidth,
  // the result is undfeined. but we do shift by this rule:
  return (NextPowerOf2(valueWidth-1) - 1) & orgShiftAmount;
}

void Interpreter::visitShl(BinaryOperator &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc1 = getOperandValue(I.getOperand(0), SF);
  AbsGenericValue ASrc2 = getOperandValue(I.getOperand(1), SF);

  if (!ASrc1.hasValue() || !ASrc2.hasValue()) {
    LOG << "skipped " << I << "\n";    
    SetValue(&I, llvm::None, SF);
    return;
  }

  GenericValue Src1 = ASrc1.getValue();
  GenericValue Src2 = ASrc2.getValue();
  GenericValue Dest;
  Type *Ty = I.getType();

  if (Ty->isVectorTy()) {
    uint32_t src1Size = uint32_t(Src1.AggregateVal.size());
    assert(src1Size == Src2.AggregateVal.size());
    for (unsigned i = 0; i < src1Size; i++) {
      GenericValue Result;
      uint64_t shiftAmount = Src2.AggregateVal[i].IntVal.getZExtValue();
      llvm::APInt valueToShift = Src1.AggregateVal[i].IntVal;
      Result.IntVal = valueToShift.shl(getShiftAmount(shiftAmount, valueToShift));
      Dest.AggregateVal.push_back(Result);
    }
  } else {
    // scalar
    uint64_t shiftAmount = Src2.IntVal.getZExtValue();
    llvm::APInt valueToShift = Src1.IntVal;
    Dest.IntVal = valueToShift.shl(getShiftAmount(shiftAmount, valueToShift));
  }

  SetValue(&I, Dest, SF);
}

void Interpreter::visitLShr(BinaryOperator &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc1 = getOperandValue(I.getOperand(0), SF);
  AbsGenericValue ASrc2 = getOperandValue(I.getOperand(1), SF);

  if (!ASrc1.hasValue() || !ASrc2.hasValue()) {
    LOG << "skipped " << I << "\n";
    SetValue(&I, llvm::None, SF);
    return;
  }

  GenericValue Src1 = ASrc1.getValue();
  GenericValue Src2 = ASrc2.getValue();  
  GenericValue Dest;
  Type *Ty = I.getType();

  if (Ty->isVectorTy()) {
    uint32_t src1Size = uint32_t(Src1.AggregateVal.size());
    assert(src1Size == Src2.AggregateVal.size());
    for (unsigned i = 0; i < src1Size; i++) {
      GenericValue Result;
      uint64_t shiftAmount = Src2.AggregateVal[i].IntVal.getZExtValue();
      llvm::APInt valueToShift = Src1.AggregateVal[i].IntVal;
      Result.IntVal = valueToShift.lshr(getShiftAmount(shiftAmount, valueToShift));
      Dest.AggregateVal.push_back(Result);
    }
  } else {
    // scalar
    uint64_t shiftAmount = Src2.IntVal.getZExtValue();
    llvm::APInt valueToShift = Src1.IntVal;
    Dest.IntVal = valueToShift.lshr(getShiftAmount(shiftAmount, valueToShift));
  }

  SetValue(&I, Dest, SF);
}

void Interpreter::visitAShr(BinaryOperator &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc1 = getOperandValue(I.getOperand(0), SF);
  AbsGenericValue ASrc2 = getOperandValue(I.getOperand(1), SF);

  if (!ASrc1.hasValue() || !ASrc2.hasValue()) {
    LOG << "skipped " << I << "\n";    
    SetValue(&I, llvm::None, SF);
    return;
  }

  GenericValue Src1 = ASrc1.getValue();
  GenericValue Src2 = ASrc2.getValue();  
  GenericValue Dest;
  Type *Ty = I.getType();

  if (Ty->isVectorTy()) {
    size_t src1Size = Src1.AggregateVal.size();
    assert(src1Size == Src2.AggregateVal.size());
    for (unsigned i = 0; i < src1Size; i++) {
      GenericValue Result;
      uint64_t shiftAmount = Src2.AggregateVal[i].IntVal.getZExtValue();
      llvm::APInt valueToShift = Src1.AggregateVal[i].IntVal;
      Result.IntVal = valueToShift.ashr(getShiftAmount(shiftAmount, valueToShift));
      Dest.AggregateVal.push_back(Result);
    }
  } else {
    // scalar
    uint64_t shiftAmount = Src2.IntVal.getZExtValue();
    llvm::APInt valueToShift = Src1.IntVal;
    Dest.IntVal = valueToShift.ashr(getShiftAmount(shiftAmount, valueToShift));
  }

  SetValue(&I, Dest, SF);
}

GenericValue Interpreter::executeTruncInst(GenericValue Src, Type *SrcTy, Type *DstTy,
                                           ExecutionContext &SF) {
  GenericValue Dest;
  if (SrcTy->isVectorTy()) {
    Type *DstVecTy = DstTy->getScalarType();
    unsigned DBitWidth = cast<IntegerType>(DstVecTy)->getBitWidth();
    unsigned NumElts = Src.AggregateVal.size();
    // the sizes of src and dst vectors must be equal
    Dest.AggregateVal.resize(NumElts);
    for (unsigned i = 0; i < NumElts; i++)
      Dest.AggregateVal[i].IntVal = Src.AggregateVal[i].IntVal.trunc(DBitWidth);
  } else {
    IntegerType *DITy = cast<IntegerType>(DstTy);
    unsigned DBitWidth = DITy->getBitWidth();
    Dest.IntVal = Src.IntVal.trunc(DBitWidth);
  }
  return Dest;
}

GenericValue Interpreter::executeSExtInst(GenericValue Src, Type *SrcTy, Type *DstTy,
                                          ExecutionContext &SF) {
  GenericValue Dest;
  if (SrcTy->isVectorTy()) {
    Type *DstVecTy = DstTy->getScalarType();
    unsigned DBitWidth = cast<IntegerType>(DstVecTy)->getBitWidth();
    unsigned size = Src.AggregateVal.size();
    // the sizes of src and dst vectors must be equal.
    Dest.AggregateVal.resize(size);
    for (unsigned i = 0; i < size; i++)
      Dest.AggregateVal[i].IntVal = Src.AggregateVal[i].IntVal.sext(DBitWidth);
  } else {
    auto *DITy = cast<IntegerType>(DstTy);
    unsigned DBitWidth = DITy->getBitWidth();
    Dest.IntVal = Src.IntVal.sext(DBitWidth);
  }
  return Dest;
}

GenericValue Interpreter::executeZExtInst(GenericValue Src, Type *SrcTy, Type *DstTy,
                                          ExecutionContext &SF) {
  GenericValue Dest;
  if (SrcTy->isVectorTy()) {
    Type *DstVecTy = DstTy->getScalarType();
    unsigned DBitWidth = cast<IntegerType>(DstVecTy)->getBitWidth();

    unsigned size = Src.AggregateVal.size();
    // the sizes of src and dst vectors must be equal.
    Dest.AggregateVal.resize(size);
    for (unsigned i = 0; i < size; i++)
      Dest.AggregateVal[i].IntVal = Src.AggregateVal[i].IntVal.zext(DBitWidth);
  } else {
    auto *DITy = cast<IntegerType>(DstTy);
    unsigned DBitWidth = DITy->getBitWidth();
    Dest.IntVal = Src.IntVal.zext(DBitWidth);
  }
  return Dest;
}

GenericValue Interpreter::executeFPTruncInst(GenericValue Src, Type *SrcTy,
					     Type *DstTy, ExecutionContext &SF) {
  GenericValue Dest;

  if (SrcTy->getTypeID() == Type::VectorTyID) {
    assert(SrcTy->getScalarType()->isDoubleTy() &&
           DstTy->getScalarType()->isFloatTy() &&
           "Invalid FPTrunc instruction");

    unsigned size = Src.AggregateVal.size();
    // the sizes of src and dst vectors must be equal.
    Dest.AggregateVal.resize(size);
    for (unsigned i = 0; i < size; i++)
      Dest.AggregateVal[i].FloatVal = (float)Src.AggregateVal[i].DoubleVal;
  } else {
    assert(SrcTy->isDoubleTy() && DstTy->isFloatTy() &&
           "Invalid FPTrunc instruction");
    Dest.FloatVal = (float)Src.DoubleVal;
  }

  return Dest;
}

GenericValue Interpreter::executeFPExtInst(GenericValue Src, Type *SrcTy,
					   Type *DstTy, ExecutionContext &SF) {
                                           
  GenericValue Dest;
  if (SrcTy->getTypeID() == Type::VectorTyID) {
    assert(SrcTy->getScalarType()->isFloatTy() &&
           DstTy->getScalarType()->isDoubleTy() && "Invalid FPExt instruction");

    unsigned size = Src.AggregateVal.size();
    // the sizes of src and dst vectors must be equal.
    Dest.AggregateVal.resize(size);
    for (unsigned i = 0; i < size; i++)
      Dest.AggregateVal[i].DoubleVal = (double)Src.AggregateVal[i].FloatVal;
  } else {
    assert(SrcTy->isFloatTy() && DstTy->isDoubleTy() &&
           "Invalid FPExt instruction");
    Dest.DoubleVal = (double)Src.FloatVal;
  }
  return Dest;
}

GenericValue Interpreter::executeFPToUIInst(GenericValue Src, Type *SrcTy,
					    Type *DstTy, ExecutionContext &SF) {
                                            
  GenericValue Dest;
  if (SrcTy->getTypeID() == Type::VectorTyID) {
    Type *DstVecTy = DstTy->getScalarType();
    Type *SrcVecTy = SrcTy->getScalarType();
    uint32_t DBitWidth = cast<IntegerType>(DstVecTy)->getBitWidth();
    unsigned size = Src.AggregateVal.size();
    // the sizes of src and dst vectors must be equal.
    Dest.AggregateVal.resize(size);

    if (SrcVecTy->getTypeID() == Type::FloatTyID) {
      assert(SrcVecTy->isFloatingPointTy() && "Invalid FPToUI instruction");
      for (unsigned i = 0; i < size; i++)
        Dest.AggregateVal[i].IntVal = APIntOps::RoundFloatToAPInt(
            Src.AggregateVal[i].FloatVal, DBitWidth);
    } else {
      for (unsigned i = 0; i < size; i++)
        Dest.AggregateVal[i].IntVal = APIntOps::RoundDoubleToAPInt(
            Src.AggregateVal[i].DoubleVal, DBitWidth);
    }
  } else {
    // scalar
    uint32_t DBitWidth = cast<IntegerType>(DstTy)->getBitWidth();
    assert(SrcTy->isFloatingPointTy() && "Invalid FPToUI instruction");

    if (SrcTy->getTypeID() == Type::FloatTyID)
      Dest.IntVal = APIntOps::RoundFloatToAPInt(Src.FloatVal, DBitWidth);
    else {
      Dest.IntVal = APIntOps::RoundDoubleToAPInt(Src.DoubleVal, DBitWidth);
    }
  }

  return Dest;
}

GenericValue Interpreter::executeFPToSIInst(GenericValue Src, Type *SrcTy,
					    Type *DstTy, ExecutionContext &SF) {
  GenericValue Dest;
  if (SrcTy->getTypeID() == Type::VectorTyID) {
    Type *DstVecTy = DstTy->getScalarType();
    Type *SrcVecTy = SrcTy->getScalarType();
    uint32_t DBitWidth = cast<IntegerType>(DstVecTy)->getBitWidth();
    unsigned size = Src.AggregateVal.size();
    // the sizes of src and dst vectors must be equal
    Dest.AggregateVal.resize(size);

    if (SrcVecTy->getTypeID() == Type::FloatTyID) {
      assert(SrcVecTy->isFloatingPointTy() && "Invalid FPToSI instruction");
      for (unsigned i = 0; i < size; i++)
        Dest.AggregateVal[i].IntVal = APIntOps::RoundFloatToAPInt(
            Src.AggregateVal[i].FloatVal, DBitWidth);
    } else {
      for (unsigned i = 0; i < size; i++)
        Dest.AggregateVal[i].IntVal = APIntOps::RoundDoubleToAPInt(
            Src.AggregateVal[i].DoubleVal, DBitWidth);
    }
  } else {
    // scalar
    unsigned DBitWidth = cast<IntegerType>(DstTy)->getBitWidth();
    assert(SrcTy->isFloatingPointTy() && "Invalid FPToSI instruction");

    if (SrcTy->getTypeID() == Type::FloatTyID)
      Dest.IntVal = APIntOps::RoundFloatToAPInt(Src.FloatVal, DBitWidth);
    else {
      Dest.IntVal = APIntOps::RoundDoubleToAPInt(Src.DoubleVal, DBitWidth);
    }
  }
  return Dest;
}

GenericValue Interpreter::executeUIToFPInst(GenericValue Src, Type *SrcTy,
					    Type *DstTy, ExecutionContext &SF) {
  GenericValue Dest;

  if (SrcTy->getTypeID() == Type::VectorTyID) {
    Type *DstVecTy = DstTy->getScalarType();
    unsigned size = Src.AggregateVal.size();
    // the sizes of src and dst vectors must be equal
    Dest.AggregateVal.resize(size);

    if (DstVecTy->getTypeID() == Type::FloatTyID) {
      assert(DstVecTy->isFloatingPointTy() && "Invalid UIToFP instruction");
      for (unsigned i = 0; i < size; i++)
        Dest.AggregateVal[i].FloatVal =
            APIntOps::RoundAPIntToFloat(Src.AggregateVal[i].IntVal);
    } else {
      for (unsigned i = 0; i < size; i++)
        Dest.AggregateVal[i].DoubleVal =
            APIntOps::RoundAPIntToDouble(Src.AggregateVal[i].IntVal);
    }
  } else {
    // scalar
    assert(DstTy->isFloatingPointTy() && "Invalid UIToFP instruction");
    if (DstTy->getTypeID() == Type::FloatTyID)
      Dest.FloatVal = APIntOps::RoundAPIntToFloat(Src.IntVal);
    else {
      Dest.DoubleVal = APIntOps::RoundAPIntToDouble(Src.IntVal);
    }
  }
  return Dest;
}

GenericValue Interpreter::executeSIToFPInst(GenericValue Src, Type *SrcTy,
					    Type *DstTy, ExecutionContext &SF) {
  GenericValue Dest;
  if (SrcTy->getTypeID() == Type::VectorTyID) {
    Type *DstVecTy = DstTy->getScalarType();
    unsigned size = Src.AggregateVal.size();
    // the sizes of src and dst vectors must be equal
    Dest.AggregateVal.resize(size);

    if (DstVecTy->getTypeID() == Type::FloatTyID) {
      assert(DstVecTy->isFloatingPointTy() && "Invalid SIToFP instruction");
      for (unsigned i = 0; i < size; i++)
        Dest.AggregateVal[i].FloatVal =
            APIntOps::RoundSignedAPIntToFloat(Src.AggregateVal[i].IntVal);
    } else {
      for (unsigned i = 0; i < size; i++)
        Dest.AggregateVal[i].DoubleVal =
            APIntOps::RoundSignedAPIntToDouble(Src.AggregateVal[i].IntVal);
    }
  } else {
    // scalar
    assert(DstTy->isFloatingPointTy() && "Invalid SIToFP instruction");

    if (DstTy->getTypeID() == Type::FloatTyID)
      Dest.FloatVal = APIntOps::RoundSignedAPIntToFloat(Src.IntVal);
    else {
      Dest.DoubleVal = APIntOps::RoundSignedAPIntToDouble(Src.IntVal);
    }
  }

  return Dest;
}

GenericValue Interpreter::executePtrToIntInst(GenericValue Src, Type *SrcTy,
					      Type *DstTy, ExecutionContext &SF) {
  uint32_t DBitWidth = cast<IntegerType>(DstTy)->getBitWidth();
  GenericValue Dest;
  assert(SrcTy->isPointerTy() && "Invalid PtrToInt instruction");

  Dest.IntVal = APInt(DBitWidth, (intptr_t) Src.PointerVal);
  return Dest;
}

GenericValue Interpreter::executeIntToPtrInst(GenericValue Src, Type *SrcTy,
					      Type *DstTy, ExecutionContext &SF) {
  GenericValue Dest;
  assert(DstTy->isPointerTy() && "Invalid PtrToInt instruction");

  uint32_t PtrSize = getDataLayout().getPointerSizeInBits();
  if (PtrSize != Src.IntVal.getBitWidth())
    Src.IntVal = Src.IntVal.zextOrTrunc(PtrSize);

  Dest.PointerVal = PointerTy(intptr_t(Src.IntVal.getZExtValue()));
  return Dest;
}

GenericValue Interpreter::executeBitCastInst(GenericValue Src, Type *SrcTy,
					     Type *DstTy, ExecutionContext &SF) {

  // This instruction supports bitwise conversion of vectors to integers and
  // to vectors of other types (as long as they have the same size)
  GenericValue Dest;

  if ((SrcTy->getTypeID() == Type::VectorTyID) ||
      (DstTy->getTypeID() == Type::VectorTyID)) {
    // vector src bitcast to vector dst or vector src bitcast to scalar dst or
    // scalar src bitcast to vector dst
    bool isLittleEndian = getDataLayout().isLittleEndian();
    GenericValue TempDst, TempSrc, SrcVec;
    Type *SrcElemTy;
    Type *DstElemTy;
    unsigned SrcBitSize;
    unsigned DstBitSize;
    unsigned SrcNum;
    unsigned DstNum;

    if (SrcTy->getTypeID() == Type::VectorTyID) {
      SrcElemTy = SrcTy->getScalarType();
      SrcBitSize = SrcTy->getScalarSizeInBits();
      SrcNum = Src.AggregateVal.size();
      SrcVec = Src;
    } else {
      // if src is scalar value, make it vector <1 x type>
      SrcElemTy = SrcTy;
      SrcBitSize = SrcTy->getPrimitiveSizeInBits();
      SrcNum = 1;
      SrcVec.AggregateVal.push_back(Src);
    }

    if (DstTy->getTypeID() == Type::VectorTyID) {
      DstElemTy = DstTy->getScalarType();
      DstBitSize = DstTy->getScalarSizeInBits();
      DstNum = (SrcNum * SrcBitSize) / DstBitSize;
    } else {
      DstElemTy = DstTy;
      DstBitSize = DstTy->getPrimitiveSizeInBits();
      DstNum = 1;
    }

    if (SrcNum * SrcBitSize != DstNum * DstBitSize)
      llvm_unreachable("Invalid BitCast");

    // If src is floating point, cast to integer first.
    TempSrc.AggregateVal.resize(SrcNum);
    if (SrcElemTy->isFloatTy()) {
      for (unsigned i = 0; i < SrcNum; i++)
        TempSrc.AggregateVal[i].IntVal =
            APInt::floatToBits(SrcVec.AggregateVal[i].FloatVal);

    } else if (SrcElemTy->isDoubleTy()) {
      for (unsigned i = 0; i < SrcNum; i++)
        TempSrc.AggregateVal[i].IntVal =
            APInt::doubleToBits(SrcVec.AggregateVal[i].DoubleVal);
    } else if (SrcElemTy->isIntegerTy()) {
      for (unsigned i = 0; i < SrcNum; i++)
        TempSrc.AggregateVal[i].IntVal = SrcVec.AggregateVal[i].IntVal;
    } else {
      // Pointers are not allowed as the element type of vector.
      llvm_unreachable("Invalid Bitcast");
    }

    // now TempSrc is integer type vector
    if (DstNum < SrcNum) {
      // Example: bitcast <4 x i32> <i32 0, i32 1, i32 2, i32 3> to <2 x i64>
      unsigned Ratio = SrcNum / DstNum;
      unsigned SrcElt = 0;
      for (unsigned i = 0; i < DstNum; i++) {
        GenericValue Elt;
        Elt.IntVal = 0;
        Elt.IntVal = Elt.IntVal.zext(DstBitSize);
        unsigned ShiftAmt = isLittleEndian ? 0 : SrcBitSize * (Ratio - 1);
        for (unsigned j = 0; j < Ratio; j++) {
          APInt Tmp;
          Tmp = Tmp.zext(SrcBitSize);
          Tmp = TempSrc.AggregateVal[SrcElt++].IntVal;
          Tmp = Tmp.zext(DstBitSize);
          Tmp <<= ShiftAmt;
          ShiftAmt += isLittleEndian ? SrcBitSize : -SrcBitSize;
          Elt.IntVal |= Tmp;
        }
        TempDst.AggregateVal.push_back(Elt);
      }
    } else {
      // Example: bitcast <2 x i64> <i64 0, i64 1> to <4 x i32>
      unsigned Ratio = DstNum / SrcNum;
      for (unsigned i = 0; i < SrcNum; i++) {
        unsigned ShiftAmt = isLittleEndian ? 0 : DstBitSize * (Ratio - 1);
        for (unsigned j = 0; j < Ratio; j++) {
          GenericValue Elt;
          Elt.IntVal = Elt.IntVal.zext(SrcBitSize);
          Elt.IntVal = TempSrc.AggregateVal[i].IntVal;
          Elt.IntVal.lshrInPlace(ShiftAmt);
          // it could be DstBitSize == SrcBitSize, so check it
          if (DstBitSize < SrcBitSize)
            Elt.IntVal = Elt.IntVal.trunc(DstBitSize);
          ShiftAmt += isLittleEndian ? DstBitSize : -DstBitSize;
          TempDst.AggregateVal.push_back(Elt);
        }
      }
    }

    // convert result from integer to specified type
    if (DstTy->getTypeID() == Type::VectorTyID) {
      if (DstElemTy->isDoubleTy()) {
        Dest.AggregateVal.resize(DstNum);
        for (unsigned i = 0; i < DstNum; i++)
          Dest.AggregateVal[i].DoubleVal =
              TempDst.AggregateVal[i].IntVal.bitsToDouble();
      } else if (DstElemTy->isFloatTy()) {
        Dest.AggregateVal.resize(DstNum);
        for (unsigned i = 0; i < DstNum; i++)
          Dest.AggregateVal[i].FloatVal =
              TempDst.AggregateVal[i].IntVal.bitsToFloat();
      } else {
        Dest = TempDst;
      }
    } else {
      if (DstElemTy->isDoubleTy())
        Dest.DoubleVal = TempDst.AggregateVal[0].IntVal.bitsToDouble();
      else if (DstElemTy->isFloatTy()) {
        Dest.FloatVal = TempDst.AggregateVal[0].IntVal.bitsToFloat();
      } else {
        Dest.IntVal = TempDst.AggregateVal[0].IntVal;
      }
    }
  } else { //  if ((SrcTy->getTypeID() == Type::VectorTyID) ||
           //     (DstTy->getTypeID() == Type::VectorTyID))

    // scalar src bitcast to scalar dst
    if (DstTy->isPointerTy()) {
      assert(SrcTy->isPointerTy() && "Invalid BitCast");
      Dest.PointerVal = Src.PointerVal;
    } else if (DstTy->isIntegerTy()) {
      if (SrcTy->isFloatTy())
        Dest.IntVal = APInt::floatToBits(Src.FloatVal);
      else if (SrcTy->isDoubleTy()) {
        Dest.IntVal = APInt::doubleToBits(Src.DoubleVal);
      } else if (SrcTy->isIntegerTy()) {
        Dest.IntVal = Src.IntVal;
      } else {
        llvm_unreachable("Invalid BitCast");
      }
    } else if (DstTy->isFloatTy()) {
      if (SrcTy->isIntegerTy())
        Dest.FloatVal = Src.IntVal.bitsToFloat();
      else {
        Dest.FloatVal = Src.FloatVal;
      }
    } else if (DstTy->isDoubleTy()) {
      if (SrcTy->isIntegerTy())
        Dest.DoubleVal = Src.IntVal.bitsToDouble();
      else {
        Dest.DoubleVal = Src.DoubleVal;
      }
    } else {
      llvm_unreachable("Invalid Bitcast");
    }
  }

  return Dest;
}

void Interpreter::visitTruncInst(TruncInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getOperand(0), SF);
  Type *SrcTy = I.getOperand(0)->getType();
  if (ASrc.hasValue()) {
    SetValue(&I, executeTruncInst(ASrc.getValue(), SrcTy, I.getType(), SF), SF);
  } else {
    SetValue(&I, llvm::None, SF);
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), ASrc);
  LOG << "\n";    
  
}

void Interpreter::visitSExtInst(SExtInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getOperand(0), SF);
  Type *SrcTy = I.getOperand(0)->getType();
  if (ASrc.hasValue()) {
    SetValue(&I, executeSExtInst(ASrc.getValue(), SrcTy, I.getType(), SF), SF);
  } else {
    SetValue(&I, llvm::None, SF);
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), ASrc);
  LOG << "\n";    
  
}

void Interpreter::visitZExtInst(ZExtInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getOperand(0), SF);
  Type *SrcTy = I.getOperand(0)->getType();
  if (ASrc.hasValue()) {  
    SetValue(&I, executeZExtInst(ASrc.getValue(), SrcTy, I.getType(), SF), SF);
  } else {
    SetValue(&I, llvm::None, SF);
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), ASrc);
  LOG << "\n";    
  
}

void Interpreter::visitFPTruncInst(FPTruncInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getOperand(0), SF);
  Type *SrcTy = I.getOperand(0)->getType();
  if (ASrc.hasValue()) {  
    SetValue(&I, executeFPTruncInst(ASrc.getValue(), SrcTy, I.getType(), SF), SF);
  } else {
    SetValue(&I, llvm::None, SF);
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), ASrc);
  LOG << "\n";    
}

void Interpreter::visitFPExtInst(FPExtInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getOperand(0), SF);
  Type *SrcTy = I.getOperand(0)->getType();
  if (ASrc.hasValue()) {  
    SetValue(&I, executeFPExtInst(ASrc.getValue(), SrcTy, I.getType(), SF), SF);
  } else {
    SetValue(&I, llvm::None, SF);
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), ASrc);
  LOG << "\n";    
  
}

void Interpreter::visitUIToFPInst(UIToFPInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getOperand(0), SF);
  Type *SrcTy = I.getOperand(0)->getType();
  if (ASrc.hasValue()) {  
    SetValue(&I, executeUIToFPInst(ASrc.getValue(), SrcTy, I.getType(), SF), SF);
  } else {
    SetValue(&I, llvm::None, SF);
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), ASrc);
  LOG << "\n";    
}

void Interpreter::visitSIToFPInst(SIToFPInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getOperand(0), SF);
  Type *SrcTy = I.getOperand(0)->getType();
  if (ASrc.hasValue()) {  
    SetValue(&I, executeSIToFPInst(ASrc.getValue(), SrcTy, I.getType(), SF), SF);
  } else {
    SetValue(&I, llvm::None, SF);
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), ASrc);
  LOG << "\n";          
}

void Interpreter::visitFPToUIInst(FPToUIInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getOperand(0), SF);
  Type *SrcTy = I.getOperand(0)->getType();
  if (ASrc.hasValue()) {  
    SetValue(&I, executeFPToUIInst(ASrc.getValue(), SrcTy, I.getType(), SF), SF);
  } else {
    SetValue(&I, llvm::None, SF);    
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), ASrc);
  LOG << "\n";    
}

void Interpreter::visitFPToSIInst(FPToSIInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getOperand(0), SF);
  Type *SrcTy = I.getOperand(0)->getType();
  if (ASrc.hasValue()) {  
    SetValue(&I, executeFPToSIInst(ASrc.getValue(), SrcTy, I.getType(), SF), SF);
  } else {
    SetValue(&I, llvm::None, SF);
  }     
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), ASrc);
  LOG << "\n";    
}

void Interpreter::visitPtrToIntInst(PtrToIntInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getOperand(0), SF);
  Type *SrcTy = I.getOperand(0)->getType();
  if (ASrc.hasValue()) {  
    SetValue(&I, executePtrToIntInst(ASrc.getValue(), SrcTy, I.getType(), SF), SF);
  } else {
    SetValue(&I, llvm::None, SF);
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), ASrc);
  LOG << "\n";    
}

void Interpreter::visitIntToPtrInst(IntToPtrInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getOperand(0), SF);
  Type *SrcTy = I.getOperand(0)->getType();
  if (ASrc.hasValue()) {  
    SetValue(&I, executeIntToPtrInst(ASrc.getValue(), SrcTy, I.getType(), SF), SF);
  } else {
    SetValue(&I, llvm::None, SF);
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), ASrc);
  LOG << "\n";    
}

void Interpreter::visitBitCastInst(BitCastInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc = getOperandValue(I.getOperand(0), SF);
  Type *SrcTy = I.getOperand(0)->getType();
  if (ASrc.hasValue()) {  
    SetValue(&I, executeBitCastInst(ASrc.getValue(), SrcTy, I.getType(), SF), SF);
  } else {
    SetValue(&I, llvm::None, SF);
  }
  LOG << "\tVal=";
  printAbsGenericValue(I.getType(), ASrc);
  LOG << "\n";    
}

#define IMPLEMENT_VAARG(TY) \
   case Type::TY##TyID: Dest.TY##Val = Src.TY##Val; break

void Interpreter::visitVAArgInst(VAArgInst &I) {
  ExecutionContext &SF = ECStack.back();

  // Get the incoming valist parameter.  LLI treats the valist as a
  // (ec-stack-depth var-arg-index) pair.
  AbsGenericValue AVAList = getOperandValue(I.getOperand(0), SF);
  if (!AVAList.hasValue()) {
    LOG << "skipped " << I << "\n";    
    SetValue(&I, llvm::None, SF);
    return;
  }

  GenericValue VAList = AVAList.getValue();
  GenericValue Dest;
  AbsGenericValue ASrc = ECStack[VAList.UIntPairVal.first]
                         .VarArgs[VAList.UIntPairVal.second];

  if (!ASrc.hasValue()) {
    LOG << "skipped " << I << "\n";    
    SetValue(&I, llvm::None, SF);
    return;    
  }

  GenericValue Src = ASrc.getValue();
  Type *Ty = I.getType();
  switch (Ty->getTypeID()) {
  case Type::IntegerTyID:
    Dest.IntVal = Src.IntVal;
    break;
  IMPLEMENT_VAARG(Pointer);
  IMPLEMENT_VAARG(Float);
  IMPLEMENT_VAARG(Double);
  default:
    ERR << "Unhandled dest type for vaarg instruction: " << *Ty << "\n";
    llvm_unreachable(nullptr);
  }

  // Set the Value of this Instruction.
  SetValue(&I, Dest, SF);

  // Move the pointer to the next vararg.
  ++VAList.UIntPairVal.second;
}

void Interpreter::visitExtractElementInst(ExtractElementInst &I) {
  ExecutionContext &SF = ECStack.back();
  AbsGenericValue ASrc1 = getOperandValue(I.getOperand(0), SF); // vector
  AbsGenericValue ASrc2 = getOperandValue(I.getOperand(1), SF); // index

  if (!ASrc1.hasValue() || !ASrc2.hasValue()) {
    LOG << "skipped " << I << "\n";    
    SetValue(&I, llvm::None, SF);
    return;
  }

  GenericValue Src1 = ASrc1.getValue();
  GenericValue Src2 = ASrc2.getValue();  
  GenericValue Dest;
  Type *Ty = I.getType();
  const unsigned indx = unsigned(Src2.IntVal.getZExtValue());

  if(Src1.AggregateVal.size() > indx) {
    switch (Ty->getTypeID()) {
    default:
      ERR << "Unhandled destination type for extractelement instruction: "
      << *Ty << "\n";
      llvm_unreachable(nullptr);
      break;
    case Type::IntegerTyID:
      Dest.IntVal = Src1.AggregateVal[indx].IntVal;
      break;
    case Type::FloatTyID:
      Dest.FloatVal = Src1.AggregateVal[indx].FloatVal;
      break;
    case Type::DoubleTyID:
      Dest.DoubleVal = Src1.AggregateVal[indx].DoubleVal;
      break;
    }
  } else {
    ERR << "Invalid index in extractelement instruction\n";
  }

  SetValue(&I, Dest, SF);
}

void Interpreter::visitInsertElementInst(InsertElementInst &I) {
  ExecutionContext &SF = ECStack.back();
  Type *Ty = I.getType();

  if(!(Ty->isVectorTy()) )
    llvm_unreachable("Unhandled dest type for insertelement instruction");

  AbsGenericValue ASrc1 = getOperandValue(I.getOperand(0), SF); // vector
  AbsGenericValue ASrc2 = getOperandValue(I.getOperand(1), SF); // value 
  AbsGenericValue ASrc3 = getOperandValue(I.getOperand(2), SF); // index

  if (!ASrc1.hasValue() || !ASrc2.hasValue() || !ASrc3.hasValue()) {
    LOG << "skipped " << I << "\n";
    SetValue(&I, llvm::None, SF);
    return;
  }

  GenericValue Src1 = ASrc1.getValue();
  GenericValue Src2 = ASrc2.getValue();
  GenericValue Src3 = ASrc3.getValue(); 
  GenericValue Dest;

  Type *TyContained = Ty->getContainedType(0);

  const unsigned indx = unsigned(Src3.IntVal.getZExtValue());
  Dest.AggregateVal = Src1.AggregateVal;

  if(Src1.AggregateVal.size() <= indx)
      llvm_unreachable("Invalid index in insertelement instruction");
  switch (TyContained->getTypeID()) {
    default:
      llvm_unreachable("Unhandled dest type for insertelement instruction");
    case Type::IntegerTyID:
      Dest.AggregateVal[indx].IntVal = Src2.IntVal;
      break;
    case Type::FloatTyID:
      Dest.AggregateVal[indx].FloatVal = Src2.FloatVal;
      break;
    case Type::DoubleTyID:
      Dest.AggregateVal[indx].DoubleVal = Src2.DoubleVal;
      break;
  }
  SetValue(&I, Dest, SF);
}

void Interpreter::visitShuffleVectorInst(ShuffleVectorInst &I){
  ExecutionContext &SF = ECStack.back();

  Type *Ty = I.getType();
  if(!(Ty->isVectorTy()))
    llvm_unreachable("Unhandled dest type for shufflevector instruction");

  AbsGenericValue ASrc1 = getOperandValue(I.getOperand(0), SF); // vector
  AbsGenericValue ASrc2 = getOperandValue(I.getOperand(1), SF); // vector
  AbsGenericValue ASrc3 = getOperandValue(I.getOperand(2), SF); // mask
  
  if (!ASrc1.hasValue() || !ASrc2.hasValue() || !ASrc3.hasValue()) {
    LOG << "skipped " << I << "\n";
    SetValue(&I, llvm::None, SF);
    return;
  }

  GenericValue Src1 = ASrc1.getValue();
  GenericValue Src2 = ASrc2.getValue();
  GenericValue Src3 = ASrc3.getValue(); 
  GenericValue Dest;

  // There is no need to check types of src1 and src2, because the compiled
  // bytecode can't contain different types for src1 and src2 for a
  // shufflevector instruction.

  Type *TyContained = Ty->getContainedType(0);
  unsigned src1Size = (unsigned)Src1.AggregateVal.size();
  unsigned src2Size = (unsigned)Src2.AggregateVal.size();
  unsigned src3Size = (unsigned)Src3.AggregateVal.size();

  Dest.AggregateVal.resize(src3Size);

  switch (TyContained->getTypeID()) {
    default:
      llvm_unreachable("Unhandled dest type for insertelement instruction");
      break;
    case Type::IntegerTyID:
      for( unsigned i=0; i<src3Size; i++) {
        unsigned j = Src3.AggregateVal[i].IntVal.getZExtValue();
        if(j < src1Size)
          Dest.AggregateVal[i].IntVal = Src1.AggregateVal[j].IntVal;
        else if(j < src1Size + src2Size)
          Dest.AggregateVal[i].IntVal = Src2.AggregateVal[j-src1Size].IntVal;
        else
          // The selector may not be greater than sum of lengths of first and
          // second operands and llasm should not allow situation like
          // %tmp = shufflevector <2 x i32> <i32 3, i32 4>, <2 x i32> undef,
          //                      <2 x i32> < i32 0, i32 5 >,
          // where i32 5 is invalid, but let it be additional check here:
          llvm_unreachable("Invalid mask in shufflevector instruction");
      }
      break;
    case Type::FloatTyID:
      for( unsigned i=0; i<src3Size; i++) {
        unsigned j = Src3.AggregateVal[i].IntVal.getZExtValue();
        if(j < src1Size)
          Dest.AggregateVal[i].FloatVal = Src1.AggregateVal[j].FloatVal;
        else if(j < src1Size + src2Size)
          Dest.AggregateVal[i].FloatVal = Src2.AggregateVal[j-src1Size].FloatVal;
        else
          llvm_unreachable("Invalid mask in shufflevector instruction");
        }
      break;
    case Type::DoubleTyID:
      for( unsigned i=0; i<src3Size; i++) {
        unsigned j = Src3.AggregateVal[i].IntVal.getZExtValue();
        if(j < src1Size)
          Dest.AggregateVal[i].DoubleVal = Src1.AggregateVal[j].DoubleVal;
        else if(j < src1Size + src2Size)
          Dest.AggregateVal[i].DoubleVal =
            Src2.AggregateVal[j-src1Size].DoubleVal;
        else
          llvm_unreachable("Invalid mask in shufflevector instruction");
      }
      break;
  }
  SetValue(&I, Dest, SF);
}

void Interpreter::visitExtractValueInst(ExtractValueInst &I) {
  ExecutionContext &SF = ECStack.back();
  Value *Agg = I.getAggregateOperand();
  GenericValue Dest;
  AbsGenericValue ASrc = getOperandValue(Agg, SF);
  if (!ASrc.hasValue()) {
    LOG << "skipped " << I << "\n";
    SetValue(&I, llvm::None, SF);
    return;    
  }

  GenericValue Src = ASrc.getValue();
  ExtractValueInst::idx_iterator IdxBegin = I.idx_begin();
  unsigned Num = I.getNumIndices();
  GenericValue *pSrc = &Src;

  for (unsigned i = 0 ; i < Num; ++i) {
    pSrc = &pSrc->AggregateVal[*IdxBegin];
    ++IdxBegin;
  }

  Type *IndexedType = ExtractValueInst::getIndexedType(Agg->getType(), I.getIndices());
  switch (IndexedType->getTypeID()) {
    default:
      llvm_unreachable("Unhandled dest type for extractelement instruction");
    break;
    case Type::IntegerTyID:
      Dest.IntVal = pSrc->IntVal;
    break;
    case Type::FloatTyID:
      Dest.FloatVal = pSrc->FloatVal;
    break;
    case Type::DoubleTyID:
      Dest.DoubleVal = pSrc->DoubleVal;
    break;
    case Type::ArrayTyID:
    case Type::StructTyID:
    case Type::VectorTyID:
      Dest.AggregateVal = pSrc->AggregateVal;
    break;
    case Type::PointerTyID:
      Dest.PointerVal = pSrc->PointerVal;
    break;
  }

  SetValue(&I, Dest, SF);
}

void Interpreter::visitInsertValueInst(InsertValueInst &I) {

  ExecutionContext &SF = ECStack.back();
  Value *Agg = I.getAggregateOperand();

  AbsGenericValue ASrc1 = getOperandValue(Agg, SF);  
  AbsGenericValue ASrc2 = getOperandValue(I.getOperand(1), SF);

  if (!ASrc1.hasValue() || !ASrc2.hasValue()) {
    LOG << "skipped " << I << "\n";    
    SetValue(&I, llvm::None, SF);
    return;
  }


  GenericValue Src1 = ASrc1.getValue();
  GenericValue Src2 = ASrc2.getValue();    
  GenericValue Dest = Src1; // Dest is a slightly changed Src1 

  ExtractValueInst::idx_iterator IdxBegin = I.idx_begin();
  unsigned Num = I.getNumIndices();

  GenericValue *pDest = &Dest;
  for (unsigned i = 0 ; i < Num; ++i) {
    pDest = &pDest->AggregateVal[*IdxBegin];
    ++IdxBegin;
  }
  // pDest points to the target value in the Dest now

  Type *IndexedType = ExtractValueInst::getIndexedType(Agg->getType(), I.getIndices());

  switch (IndexedType->getTypeID()) {
    default:
      llvm_unreachable("Unhandled dest type for insertelement instruction");
    break;
    case Type::IntegerTyID:
      pDest->IntVal = Src2.IntVal;
    break;
    case Type::FloatTyID:
      pDest->FloatVal = Src2.FloatVal;
    break;
    case Type::DoubleTyID:
      pDest->DoubleVal = Src2.DoubleVal;
    break;
    case Type::ArrayTyID:
    case Type::StructTyID:
    case Type::VectorTyID:
      pDest->AggregateVal = Src2.AggregateVal;
    break;
    case Type::PointerTyID:
      pDest->PointerVal = Src2.PointerVal;
    break;
  }

  SetValue(&I, Dest, SF);
}

//===----------------------------------------------------------------------===//
//                        Dispatch and Execution Code
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// callFunction - Execute the specified function...
//
void Interpreter::callFunction(Function *F, ArrayRef<AbsGenericValue> ArgVals,
			       Instruction *CS) {
  assert((ECStack.empty() || !ECStack.back().Caller.getInstruction() ||
          ECStack.back().Caller.arg_size() == ArgVals.size()) &&
         "Incorrect number of arguments passed into function call!");
  // Make a new stack frame... and fill it in.
  ECStack.emplace_back();
  ExecutionContext &StackFrame = ECStack.back();
  StackFrame.CurFunction = F;

  // Special handling for external functions.
  if (F->isDeclaration()) {
    // As a side-effect, it sets StopExecution to true if the
    // interpreter should be stopped here.
    AbsGenericValue Result = callExternalFunction (CS, F, ArgVals);
    #ifdef DEBUG_PTR_PROVENANCE
    if (CS->getType()->isPointerTy()) {
      if (Result) {
	LOG << "External call Returned pointer ";
	printAbsGenericValue(CS->getType(), Result);
	LOG << " from " << *CS << "\n";	
      }
    }
    #endif    
    // Simulate a 'ret' instruction of the appropriate type.
    popStackAndReturnValueToCaller (F->getReturnType (), Result);
    return;
  }

  // Get pointers to first LLVM BB & Instruction in function.
  StackFrame.CurBB     = &F->front();
  StackFrame.CurInst   = StackFrame.CurBB->begin();

  // Run through the function arguments and initialize their values...
  assert((ArgVals.size() == F->arg_size() ||
         (ArgVals.size() > F->arg_size() && F->getFunctionType()->isVarArg()))&&
         "Invalid number of values passed to function invocation!");

  // Handle non-varargs arguments...
  unsigned i = 0;
  for (Function::arg_iterator AI = F->arg_begin(), E = F->arg_end(); 
       AI != E; ++AI, ++i)
    SetValue(&*AI, ArgVals[i], StackFrame);

  // Handle varargs arguments...
  StackFrame.VarArgs.assign(ArgVals.begin()+i, ArgVals.end());
}

void Interpreter::run() {
  unsigned NumDynamicInsts = 0;
  while (!ECStack.empty()) {
    // Interpret a single instruction & increment the "PC".
    ExecutionContext &SF = ECStack.back();  // Current stack frame
    Instruction &I = *SF.CurInst++;         // Increment before execute

    // Track the number of dynamic instructions executed.
    ++NumDynamicInsts;

    LOG << "About to interpret: " << I << "\n";
    if (VisitedBlocks.insert(I.getParent()).second) {
      LOG << "Marked " << I.getParent()->getParent()->getName() << "::"
	  << (I.getParent()->hasName() ? I.getParent()->getName() : "unnamed_block")
	  << " as visited \n";
    }
    
    visit(I);   // Dispatch to one of the visit* methods...
    if (StopExecution) {
      --SF.CurInst; // we want to point to the last executed instruction
      break;
    }
  }
  LOG << "============================================================\n";
  LOG << "  Finished execution after " << NumDynamicInsts << " instructions "
      << " and " << VisitedBlocks.size() << " blocks\n";      ;
  LOG << "============================================================\n";  
}

llvm::Instruction* Interpreter::getLastExecutedInst() const {
  if (!ECStack.empty()) {
    const ExecutionContext &SF = ECStack.back();
    return &*SF.CurInst;
  } else {
    return nullptr;
  }
}

// From lib/ExecutionEngine/ExecutionEngine.cpp
static void LoadIntFromMemory(APInt &IntVal, uint8_t *Src, unsigned LoadBytes) {
  assert((IntVal.getBitWidth()+7)/8 >= LoadBytes && "Integer too small!");
  uint8_t *Dst = reinterpret_cast<uint8_t *>(
                   const_cast<uint64_t *>(IntVal.getRawData()));

  if (sys::IsLittleEndianHost)
    // Little-endian host - the destination must be ordered from LSB to MSB.
    // The source is ordered from LSB to MSB: Do a straight copy.
    memcpy(Dst, Src, LoadBytes);
  else {
    // Big-endian - the destination is an array of 64 bit words ordered from
    // LSW to MSW.  Each word must be ordered from MSB to LSB.  The source is
    // ordered from MSB to LSB: Reverse the word order, but not the bytes in
    // a word.
    while (LoadBytes > sizeof(uint64_t)) {
      LoadBytes -= sizeof(uint64_t);
      // May not be aligned so use memcpy.
      memcpy(Dst, Src + LoadBytes, sizeof(uint64_t));
      Dst += sizeof(uint64_t);
    }

    memcpy(Dst + sizeof(uint64_t) - LoadBytes, Src, LoadBytes);
  }
}

static AbsGenericValue dereferencePointerIfBasicElementType(AbsGenericValue Val,
							    Type* Ty,
							    const DataLayout &dl) {
  if (!Val.hasValue() || !Ty->isPointerTy()) {
    return llvm::None;
  }

  if (Type* ElementType = Ty->getPointerElementType()) {
    if (ElementType->getTypeID() == Type::IntegerTyID ||
	ElementType->getTypeID() == Type::FloatTyID ||
	ElementType->getTypeID() == Type::DoubleTyID) {
      if (void * addr = Val.getValue().PointerVal) {
	GenericValue Res;
	switch(ElementType->getTypeID()) {
	case Type::IntegerTyID: {
	  APInt val(cast<IntegerType>(ElementType)->getBitWidth(), 0);		
	  ::LoadIntFromMemory(val, (uint8_t*)addr, dl.getTypeStoreSize(ElementType));
	  Res.IntVal = val;
	  break;
	}
	case Type::FloatTyID:
	  Res.FloatVal = *((float*) addr);
	  break;
	case Type::DoubleTyID:
	  Res.DoubleVal = *((double*) addr);
	  break;
	default:
	  ERR << "Unexpected basic type in dereferencePointer\n";
	  llvm_unreachable(nullptr);	    
	}
	return Res;
      }
    }
  }
  return llvm::None;
}


// Return the last basic block visited by the execution. It can be
// null if the execution terminated. 
BasicBlock* Interpreter::inspectStackAndGlobalState(
			  DenseMap<Value*, RawAndDerefValue> &globalVals,
			  DenseMap<Value*, std::vector<RawAndDerefValue>> &stackVals) {
  
  for (unsigned m = 0, e = Modules.size(); m != e; ++m) {
    Module &M = *Modules[m];
    for (auto &GV : M.globals()) {
      if (UnresolvedGlobals.count(&GV) > 0) {
	continue;
      }
      GenericValue RawVal = PTOGV(getPointerToGlobal(&GV));
      auto DerefVal =
	dereferencePointerIfBasicElementType(RawVal,GV.getType(), getDataLayout());
      RawAndDerefValue RDV(RawVal, DerefVal);
      globalVals.insert(std::make_pair(&GV, RDV));
    }
  }
  
  for (unsigned i=0, sz=ECStack.size();i<sz;++i) {
    ExecutionContext &SF = ECStack[i];
    for (auto &kv: SF.Values) {
      Value *V = kv.first;
      AbsGenericValue RawVal = kv.second;
      if (!RawVal.hasValue()) continue;
      
      if (void *addr = RawVal.getValue().PointerVal) {
	if (!isAllocatedMemory(addr)) {
	  llvm::errs() << "ConfigPrime: skips " << *V << "\n"
		       << "Because address "
		       << addr << " might not be allocated in memory.\n";
	  continue;
	}
      }

      auto DerefVal = dereferencePointerIfBasicElementType
	(RawVal, V->getType(), getDataLayout());
      RawAndDerefValue RDV(RawVal.getValue(), DerefVal);

      auto it = stackVals.find(V);
      if (it!=stackVals.end()) {
	it->second.push_back(RDV);
      } else {
	std::vector<RawAndDerefValue> stack{RDV};
	stackVals.insert(std::make_pair(V, stack));	
      }
    }
  }

  if (!ECStack.empty()) {
    ExecutionContext &SF = ECStack.back();
    return SF.CurBB;
  } else {
    return nullptr;
  }       
}

} // end namespace previrt 
