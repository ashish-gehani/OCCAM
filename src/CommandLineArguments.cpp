//
// OCCAM
//
// Copyright (c) 2011-2012, SRI International
//
//  All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// * Neither the name of SRI International nor the names of its contributors may
//   be used to endorse or promote products derived from this software without
//   specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#include "llvm/Pass.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Attributes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/CommandLine.h"

#include <vector>
#include <string>

#include "utils/Inliner.h"
#include "Specializer.h"
#include "CommandLineArguments.h"

using namespace llvm;

static cl::opt<std::string>
ArgumentsFileName("Parguments-input",
		  cl::init(""),
		  cl::Hidden,
		  cl::desc("specifies the input file for the arguments"));

static cl::opt<std::string>
SpecializeProgName("Parguments-name",
		   cl::init(""),
		   cl::Hidden,
		   cl::desc("specifies the program name"));

namespace previrt {
  
  char SpecializeArguments::ID;

  SpecializeArguments::SpecializeArguments(const char* filename, const char* name)
    : ModulePass(SpecializeArguments::ID) {
    
    char str[1024];
    FILE* f = fopen(filename, "r");

    if (f == NULL) {
      errs() << "SpecializeArguments(): Failed to open file '" << filename << "'\n";
      this->argc = -1;
      this->argv = NULL;
      return;
    }

    std::vector<char*> args;
    while (fgets(str, 1024, f) != NULL) {
      int len = strlen(str);
      while (len > 0 && (str[len - 1] == '\n' || str[len - 1] == '\r'))
	str[--len] = '\0';
      char* buf = new char[len + 1];
      strcpy(buf, str);
      args.push_back(buf);
    }
    
    this->argc = args.size();
    this->argv = new char*[this->argc];
    int i = 0;

    errs() << "Read " << this->argc << " command line arguments:\n";

    for (std::vector<char*>::iterator itr = args.begin(), end = args.end(); itr
	   != end; ++itr, ++i) {
      this->argv[i] = *itr;
      errs() << "\t" << this->argv[i] << "\n";
    }
    
    this->progName = name;
    
    fclose(f);
  }
  
  SpecializeArguments::SpecializeArguments(int _argc, char* _argv[], const char* name)
    : ModulePass(SpecializeArguments::ID)
    , argc(_argc)
    , argv(_argv)
    , progName(name) {}
  
  SpecializeArguments::~SpecializeArguments() {
    if (argv != NULL) {
      for (int i=0; i < argc; i++) {
	delete [] argv[i];
      }
      delete[] argv;
    }
  }
  
  bool SpecializeArguments::runOnModule(Module& M) {
    Function* f = M.getFunction("main");
    
    if (f == NULL) {
      errs() << "SpecializeArguments::runOnModule: running on module without 'main' function.\n"
	     << "Ignoring...\n";
      return false;
    }
    
    if (f->arg_size() != 2) {
      errs() << "SpecializeArguments::runOnModule: main module has incorrect signature\n"
	     << f->getFunctionType();
      return false;
    }
    
    // Build the array constant

    // typicaly whether i32 or i64
    Type* intptrTy = M.getDataLayout().getIntPtrType(M.getContext(), 0);
    // stringTy = i8*
    Type* const stringTy = PointerType::get(IntegerType::get(M.getContext(), 8),
					      0 /*AddressSpace*/);

    Function *new_main = Function::Create(f->getFunctionType(),
					  f->getLinkage(), "", &M);
    new_main->takeName(f);
    Function::arg_iterator ai = new_main->arg_begin();
    ai++;
    Value* argvArg = (Value*) &(*ai);

    BasicBlock* bb = BasicBlock::Create(M.getContext());
    new_main->getBasicBlockList().push_front(bb);
    IRBuilder<> irb(bb);
    std::vector<Value*> cargs;
    std::vector<Constant*> init;

    if (this->progName) {
      //llvm::errs() << "Here: " << this->progName << "\n";
      GlobalVariable* gv = materializeStringLiteral(M, this->progName);
      //llvm::errs() << "gc: " << gv << "\n";
      auto* gvT = gv->getType();
      //auto* sty = cast<SequentialType>(gvT);
      auto* sty = cast<PointerType>(gvT);
      cargs.push_back(irb.CreateConstGEP2_32(sty->getElementType(), gv, 0, 0));
    } else {
      Value* progName = irb.CreateLoad(argvArg, false);
      cargs.push_back(progName);
    }

    for (int i = 0; i < this->argc; ++i) {
      GlobalVariable* gv = materializeStringLiteral(M, this->argv[i]);
      auto* gvT = gv->getType();
      //auto* sty = cast<SequentialType>(gvT);
      auto* sty = cast<PointerType>(gvT);
      cargs.push_back(irb.CreateConstGEP2_32(sty->getElementType(), gv, 0, 0));
    }

    // XXX: We cannot store the new argv in the stack.
    // 
    // If the new argv is passed to another function then the callee
    // won't have access to new_argv since it's in the caller's stack.
    // This happens with this code:
    //
    // main(...,argv) { foo(...,argv);}
    // 
    // Our code will create something like this:
    //
    // main(...,argv) { char*[N] newargv; ... foo(...,newargv);}
    //

    Value *numArgs = ConstantInt::get(intptrTy, cargs.size(), false);
    /// XXX: We cannot do stack allocation
    // Value* argv = irb.CreateAlloca(stringTy, numArgs);
    
    // Add the following instruction:
    // 
    // stringTy p = (stringTy) malloc(sizeof(type) * array_sz)
    //
    Value *ptrSz = ConstantInt::get(intptrTy, M.getDataLayout().getPointerSize(), false);

    // Insert the malloc call at the end of bb which at this point is
    // still empty.  CreateMalloc returns the BitCast instruction to
    // cast the malloced pointer to its type.  That BitCast
    // instruction is not inserted anywhere.
    Value* argv = CallInst::CreateMalloc(bb,
					 /*expected type for malloc argument (size_t)*/
					 intptrTy,
					 stringTy /*used only for cast*/, 
					 ptrSz    /*sizeof(type)*/,
					 numArgs  /*array_sz*/,
					 (Function*) nullptr, "new_argv");
    bb->getInstList().push_back(cast<Instruction>(argv));
    
    /* Prepare the IR builder to insert next time _after_ argv */
    irb.SetInsertPoint(cast<Instruction>(argv));
    auto it = irb.GetInsertPoint();
    ++it;
    irb.SetInsertPoint(bb, it);

    int idx = 0;
    for (std::vector<Value*>::iterator i = cargs.begin(), e = cargs.end(); i
	   != e; ++i, ++idx) {
      Value* argptr = irb.CreateConstGEP1_32(argv, idx);
      irb.CreateStore(*i, argptr);
    }
    
    std::vector<Value *> calleeVargs;
    calleeVargs.push_back(ConstantInt::getSigned(IntegerType::get(M.getContext(), 32), cargs.size()));
    calleeVargs.push_back(argv);
    ArrayRef<Value *> calleeArgs(calleeVargs);
    Value* res = irb.CreateCall(f, calleeArgs);
    //    Value* res = irb.CreateCall2(f, ConstantInt::getSigned(IntegerType::get(
    //        M.getContext(), 32), cargs.size()), argv);
    irb.CreateRet(res);

    // f is the old main which is now called inside new_main and
    // we would like to inline old main into new_main.
    utils::inlineOnly(M, {f});

    return true;
  }
  
  class RegisterArguments : public SpecializeArguments {
  public:
    RegisterArguments() :
      SpecializeArguments(ArgumentsFileName == "" ?
			  "arguments" :
			  ArgumentsFileName.getValue().c_str(),
                          SpecializeProgName.getValue() == "" ?
			  nullptr :
			  SpecializeProgName.getValue().c_str()) {}
    virtual ~RegisterArguments() {}
  };
  
  static RegisterPass<RegisterArguments>
  X("Parguments",
    "Specialize main() function arguments from file 'arguments'", 
    false,
    false);
}
