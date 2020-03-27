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

#include "RecursiveGuardSpecPolicy.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/ADT/SmallBitVector.h"

using namespace llvm;

namespace previrt {
  
  RecursiveGuardSpecPolicy::
  RecursiveGuardSpecPolicy(std::unique_ptr<SpecializationPolicy> subpolicy,
			   CallGraph& cg)
    : m_cg(cg)
    , m_subpolicy(std::move(subpolicy)) {
    
    markRecursiveFunctions();
  }
  
  RecursiveGuardSpecPolicy::~RecursiveGuardSpecPolicy() {}

  void RecursiveGuardSpecPolicy::markRecursiveFunctions() {
    for (auto it = scc_begin(&m_cg); !it.isAtEnd(); ++it) {
      auto &scc = *it;
      bool recursive = false;
      
      if (scc.size() == 1 && it.hasLoop()) {
	// direct recursive
	recursive = true;
      } else if (scc.size() > 1) {
	// indirect recursive
	recursive = true;
      }

      if (recursive) {
	for (CallGraphNode *cgn : scc) {
	  Function *fn = cgn->getFunction();
	  if (!fn || fn->isDeclaration() || fn->empty()) {
	    continue;
	  }
	  m_rec_functions.insert(fn);
	}
      }
    }
  }

  bool RecursiveGuardSpecPolicy::isRecursive(Function* F) const {
    return m_rec_functions.count(F) > 0;
  }
  
  // Return true if F is not recursive  
  bool RecursiveGuardSpecPolicy::allowSpecialization(Function* F) const {
    return (!isRecursive(F));
  }

  bool RecursiveGuardSpecPolicy::specializeOn(CallSite CS,
					      std::vector<Value*>& marks) {
    Function* callee = CS.getCalledFunction();
    if (callee && allowSpecialization(callee)) {
      return m_subpolicy->specializeOn(CS, marks);
    } else {
      return false;
    }
  }

  bool RecursiveGuardSpecPolicy::specializeOn(Function* F,
					      const std::vector<PrevirtType>& args,
					      SmallBitVector& marks)  {
    if (allowSpecialization(F)) {
      return m_subpolicy->specializeOn(F, args, marks);
    } else {
      return false;
    }
  }

} // end namespace previrt

