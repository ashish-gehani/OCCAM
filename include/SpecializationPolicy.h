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

/*
 *  Initial implementation created on: Jul 11, 2011
 *  Author: malecha
 */

#pragma once

#include "llvm/IR/Function.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/CallSite.h"
#include "PrevirtTypes.h"
#include "PrevirtualizeInterfaces.h"
#include <vector>

namespace llvm {
  class SmallBitVector;
}

namespace previrt {
  
  /* Here specialization policies */
  enum class SpecializationPolicyType {
    NOSPECIALIZE, // never specialize
    AGGRESSIVE,   // always specialize
    BOUNDED,      // always specialize up to certain threshold
    ONLY_ONCE,    // specialize if function called only once
    NONREC        // always specialize if function is non-recursive
  };
  
  class SpecializationPolicy {
  protected:
    
    SpecializationPolicy(){}
    
    static bool isConstantSpecializable(llvm::Constant* cst) {
      if (!cst) return false;
      return PrevirtType::abstract(cst).isConcrete();
    }    
    
  public:
    
    virtual ~SpecializationPolicy(){}

    // Decide whether a callsite CS should be specialized.
    //
    // marks[i] is either null or Constant* containing the value of
    // i-th actual parameter of the call.
    virtual bool intraSpecializeOn(llvm::CallSite CS,
				   std::vector<llvm::Value*>& marks) = 0;

    // Decide whether we should create a specialized version of
    // CalleeF by looking at its interface (i.e., how other modules
    // call CalleeF).
    // 
    // marks[i] is true iff i-th parameter of the call can be
    // specialized.
    virtual bool interSpecializeOn(const llvm::Function& CalleeF,
				   const std::vector<PrevirtType>& args,
				   const ComponentInterface& interface,
				   llvm::SmallBitVector& marks) = 0;

  };
} // end namespace
