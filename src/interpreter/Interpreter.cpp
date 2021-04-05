//===- Interpreter.cpp - Top-Level LLVM Interpreter Implementation --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the top-level functionality for the LLVM interpreter.
// This interpreter is designed to be a very simple, portable, inefficient
// interpreter.
//
//===----------------------------------------------------------------------===//

#include "Interpreter.h"

#include "llvm/CodeGen/IntrinsicLowering.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Module.h"

#include <cstring>
#include <cstdio>

using namespace llvm;

namespace {
static struct RegisterInterp {
  RegisterInterp() { previrt::Interpreter::Register(); }
} InterpRegistrator;
}

extern "C" void LLVMLinkInInterpreter() { }

namespace previrt {

void *ArgvArray::reset(LLVMContext &C, ExecutionEngine *EE,
                       const std::vector<std::string> &InputArgv) {

  Interpreter* Interp = static_cast<Interpreter*>(EE);
  
  Values.clear();  // Free the old contents.
  Values.reserve(InputArgv.size());
  unsigned PtrSize = EE->getDataLayout().getPointerSize();
  Array = std::make_unique<char[]>((InputArgv.size()+1)*PtrSize);

  Type *SBytePtr = Type::getInt8PtrTy(C);

  for (unsigned i = 0; i != InputArgv.size(); ++i) {
    errs() << "Processing " << InputArgv[i] << "\n";
    unsigned Size = InputArgv[i].size()+1;
    auto Dest = std::make_unique<char[]>(Size);
    std::copy(InputArgv[i].begin(), InputArgv[i].end(), Dest.get());
    Dest[Size-1] = 0;

    // Endian safe: Array[i] = (PointerTy)Dest;
    EE->StoreValueToMemory(PTOGV(Dest.get()),
                           (GenericValue*)(&Array[i*PtrSize]), SBytePtr);
    // HACK: track of the address that contains argv[i]
    Interp->initializeMainParams((void*) (&Array[i*PtrSize]), PtrSize);
    Interp->initializeMainParams((void *) (Dest.get()), Size);
    Values.push_back(std::move(Dest));
  }

  // Null terminate it
  EE->StoreValueToMemory(PTOGV(nullptr),
                         (GenericValue*)(&Array[InputArgv.size()*PtrSize]),
                         SBytePtr);
  // HACK: track of the address of argv
  Interp->initializeMainParams((void*) (&Array[InputArgv.size()*PtrSize]), PtrSize);
  return Array.get();
}

/// Create a new interpreter object.
///
ExecutionEngine *Interpreter::create(std::unique_ptr<Module> M,
                                     std::string *ErrStr) {
  // Tell this Module to materialize everything and release the GVMaterializer.
  if (Error Err = M->materializeAll()) {
    std::string Msg;
    handleAllErrors(std::move(Err), [&](ErrorInfoBase &EIB) {
      Msg = EIB.message();
    });
    if (ErrStr)
      *ErrStr = Msg;
    // We got an error, just return 0
    return nullptr;
  }
  llvm::errs() << "ConfigPrime: creating an interpreter instance.\n";
  return new Interpreter(std::move(M));
}

//===----------------------------------------------------------------------===//
// Interpreter ctor - Initialize stuff
//
  
Interpreter::Interpreter(std::unique_ptr<Module> M)
  : ExecutionEngine(std::move(M)),
    StopExecution(false),
    NonZeroExitCode(false) {

  memset(&ExitValue.Untyped, 0, sizeof(ExitValue.Untyped));
  // Initialize the "backend"
  initializeExecutionEngine();
  initializeExternalFunctions();
  Interpreter::emitGlobals();

  llvm::errs() << "ConfigPrime: collecting all addresses from global initializers.\n";  
  /// OCCAM: we record all the addresses taken by the global
  /// initializers. All the memory allocation happened already in
  /// emitGlobals.
  for (unsigned m = 0, e = Modules.size(); m != e; ++m) {
    Module &M = *Modules[m];
    for (auto &GV : M.globals()) {
      if (GV.hasInitializer()) {
	initializeGlobalVariable(GV);
      }
    }
  }
    
  IL = new IntrinsicLowering(getDataLayout());
}

Interpreter::~Interpreter() {
  // Important hack for Occam: We need to release ownership of the
  // LLVM modules.  Otherwise, they will be removed and then opt will
  // crash.
  for (unsigned i = 0, sz = Modules.size(); i <sz; ++i) {
    Modules[i].release();
  }
  
  delete IL;
}

void Interpreter::runAtExitHandlers () {
  while (!AtExitHandlers.empty()) {
    llvm::errs() << "Running exit handler ... \n";
    callFunction(AtExitHandlers.back(), None);
    AtExitHandlers.pop_back();
    run();
  }
}

/// run - Start execution with the specified function and arguments.
///
GenericValue Interpreter::runFunction(Function *F,
                                      ArrayRef<GenericValue> ArgValues) {
  assert (F && "Function *F was null at entry to run()");

  // Try extra hard not to pass extra args to a function that isn't
  // expecting them.  C programmers frequently bend the rules and
  // declare main() with fewer parameters than it actually gets
  // passed, and the interpreter barfs if you pass a function more
  // parameters than it is declared to take. This does not attempt to
  // take into account gratuitous differences in declared types,
  // though.
  const size_t ArgCount = F->getFunctionType()->getNumParams();
  ArrayRef<GenericValue> ActualArgs =
      ArgValues.slice(0, std::min(ArgValues.size(), ArgCount));

  std::vector<AbsGenericValue> AActualArgs;
  AActualArgs.reserve(ActualArgs.size());
  for(unsigned i=0, sz=ActualArgs.size(); i<sz;++i) {
    AActualArgs.push_back(AbsGenericValue(ActualArgs[i]));
  }
  
  // Set up the function call.
  callFunction(F, AActualArgs);
  // Start executing the function.
  run();
  return ExitValue;
}

bool Interpreter::isExecuted(const BasicBlock &BB) const {
  return (VisitedBlocks.count(&BB) > 0);
}
  
} // end namespace previrt
