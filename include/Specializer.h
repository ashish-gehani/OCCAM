//
// OCCAM
//
// Copyright (c) 2011-2018, SRI International
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

#include <vector>

namespace llvm
{
  class Function;
  class Value;
  class BasicBlock;
  class GlobalVariable;
}

namespace previrt
{
  /*
   * Make a copy of f and specialize f wrt to args. args[i] is null if
   * the argument is not known, otherwise args[i] is a Constant.
  */
  llvm::Function* specializeFunction(llvm::Function *f,
				     const std::vector<llvm::Value*>& args);

  /*
   * Specialize a call site and return the new instruction.
   * Return null if I is not CallInst or InvokeInst.
   * 
   * Create a new callsite whose arguments are the actual parameters
   * {perm[0],...,perm[perm.size()-1]} of the original callsite.
   */
  llvm::Instruction* specializeCallSite(llvm::Instruction* cs,
					llvm::Function*,
					const std::vector<unsigned>&perm);

  /*
   * Create a LLVM global variable from a string.
   */
  llvm::GlobalVariable* materializeStringLiteral(llvm::Module& m, const char* data);

  llvm::Constant* charStarFromStringConstant(llvm::Module& m, llvm::Constant* v);
}
