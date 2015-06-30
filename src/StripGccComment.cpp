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

#include "llvm/ADT/StringMap.h"
#include "llvm/IR/User.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Pass.h"
#include "llvm/PassManager.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Bitcode/ReaderWriter.h"

#include "PrevirtualizeInterfaces.h"
#include "Previrtualize.h"

#include <vector>
#include <string>
#include <stdio.h>

using namespace llvm;

namespace previrt
{
  class StripGccComment : public ModulePass
  {
  public:
	  static char ID;
  public:
	  StripGccComment() :
		ModulePass(ID)
	  {
	  }
	  virtual ~StripGccComment()
	  {
	  }
  public:
	  virtual bool
	  runOnModule(Module &m)
	  {
		  const std::string &assembly = m.getModuleInlineAsm();
		  if (assembly.empty()) return false;

		  size_t at = assembly.find("\09.ident");
		  if (at == std::string::npos) return false;

		  std::string nassembly;
		  nassembly.reserve(assembly.length());
		  errs() << "reserving " << assembly.length() << " characters\n";
		  size_t from = 0;
		  while ((at = assembly.find(".ident", from)) != std::string::npos) {
			  size_t to = at - 1;
			  while (to > 0 && assembly.at(to) != '\n') to--;
			  errs() << "copying " << from << " - " << to << "\n";
			  nassembly.append(assembly.begin() + from, assembly.begin() + to);
			  from = assembly.find("\n", at);
		  }
		  errs() << "done\n";
		  if (from != std::string::npos)
			  nassembly.append(assembly.begin() + from, assembly.end());

		  m.setModuleInlineAsm(nassembly);
		  return true;
	  }
  };
  char StripGccComment::ID;

  static RegisterPass<StripGccComment> X("Pstrip-asm-ident",
        "remove .ident... from module assembly", false, false);
}
