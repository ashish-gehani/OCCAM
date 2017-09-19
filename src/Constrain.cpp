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

#include <stdio.h>

#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Attributes.h"
#include "llvm/Pass.h"
#include "llvm/IR/LegacyPassManager.h"
//#include "llvm/IR/PassManager.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/LinkAllPasses.h"

#include <vector>
#include <string>

#include "Specializer.h"
#include "Constrain.h"

using namespace llvm;

namespace previrt
{
  char Constrain::ID;

  Constrain::Constrain(const char* filename, const char* name) :
    ModulePass(Constrain::ID)
  {
    char str[1024];
    FILE* f = fopen(filename, "r");

    if (f == NULL)
    {
      errs() << "Constrain(): Failed to open file '" << filename << "'\n";
      this->argc = -1;
      this->argv = NULL;
      return;
    }

    std::vector<char*> args;
    while (fgets(str, 1024, f) != NULL)
    {
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
        != end; ++itr, ++i)
    {
      this->argv[i] = *itr;
      errs() << "\t" << this->argv[i] << "\n";
    }

    this->progName = name;

    fclose(f);
  }
  Constrain::Constrain(int _argc, char* _argv[], const char* name) :
    ModulePass(Constrain::ID), argc(_argc), argv(_argv), progName(name)
  {
  }
  Constrain::~Constrain()
  {
    if (argv != NULL) {
      for (int i=0; i < argc; i++)
	delete [] argv[i];

      delete[] argv;
    }
  }
  bool
  Constrain::runOnModule(Module& M)
  {
    Function* f = M.getFunction("main");

    if (f == NULL)
      {
	errs() << "Constrain::runOnModule: running on module without 'main' function.\n"
	      << "Ignoring...\n";
	return false;
      }

    if (f->arg_size() != 2)
    {
      errs() << "Constrain::runOnModule: main module has incorrect signature\n" << f->getFunctionType();
      return false;
    }


    legacy::PassManager mgr;
    mgr.add(createAlwaysInlinerLegacyPass());
    mgr.run(M);

    return true;
  }

  static cl::opt<std::string> ConstraintsFileName("Pconstraints-input",
          cl::init(""), cl::Hidden, cl::desc("specifies the constraints"));
  class RegisterConstrain : public Constrain
  {
  public:
    RegisterConstrain() :
      Constrain(ConstraintsFileName == "" ? "constraints" : ConstraintsFileName.getValue().c_str())
    {
    }
    virtual
    ~RegisterConstrain()
    {
    }
  };

  static RegisterPass<RegisterConstrain> X("Pconstraints", "Constrain main() function arguments from file 'constraints'", false,
      false);
}
