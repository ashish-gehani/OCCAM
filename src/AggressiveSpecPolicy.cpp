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

#include "AggressiveSpecPolicy.h"
#include "llvm/ADT/SmallBitVector.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define ASP_LOG(...) __VA_ARGS__
//#define ASP_LOG(...)

namespace previrt {
  
  bool AggressiveSpecPolicy::intraSpecializeOn(CallSite CS, std::vector<Value*>& marks) {
    const Function *calleeF = CS.getCalledFunction();
    if (!calleeF) {
      return false;
    }

    ASP_LOG(errs() << "[ASP] Checking if " << *CS.getInstruction()
	    << " can be specialized ... ";);
    bool specialize = false;
    marks.reserve(CS.arg_size());
    for (unsigned i=0, e = CS.arg_size(); i<e; ++i) {
      Constant* cst = dyn_cast<Constant> (CS.getArgument(i));
      // XXX: cst can be nullptr
      if (SpecializationPolicy::isConstantSpecializable(cst)) {
	marks.push_back(cst);
	specialize=true;
      } else {
	marks.push_back(nullptr);
      } 
    }
    ASP_LOG(errs() << (specialize ? "yes\n" : "no\n"));
    return specialize;
  }

  bool AggressiveSpecPolicy::interSpecializeOn(const Function& CalleeF /*unused*/,
					       const std::vector<PrevirtType>& args,
					       const ComponentInterface& interface /*unused*/,
					       SmallBitVector& marks) {
    bool specialize = false;
    ASP_LOG(errs() << "[ASP] Checking if call to " << CalleeF.getName()
	    << " can be specialized ... ";);
    for (unsigned int i = 0, sz = args.size(); i<sz; ++i) {
      if (args[i].isConcrete()) {
        specialize = true;
        marks.set(i);
      }
    }
    ASP_LOG(errs() << (specialize ? "yes\n" : "no\n"));    
    return specialize;
  }
  
} // end namespace
