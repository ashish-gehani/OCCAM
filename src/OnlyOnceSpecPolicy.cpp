//
// OCCAM
//
// Copyright (c) 2020, SRI International
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

#include "OnlyOnceSpecPolicy.h"
#include "AggressiveSpecPolicy.h"
#include "llvm/ADT/SmallBitVector.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define OSP_LOG(...) __VA_ARGS__
//#define OSP_LOG(...)

namespace previrt {

  static StringRef OccamSpecStr = "__occam_spec.";
  
  OnlyOnceSpecPolicy::OnlyOnceSpecPolicy(Module &M) {
    // Precompute some information used by intra specialization
    DenseSet<const Function*> calledS;
    for (auto &F: M) {
      for (auto &B: F) {
	for (auto &I: B) {
	  Instruction* CI = dyn_cast<CallInst>(&I);
	  if (!CI) CI = dyn_cast<InvokeInst>(&I);
	  if (!CI) continue;
	  CallSite CS(CI);
	  if (const Function *calleeF = CS.getCalledFunction()) {
	    if (calleeF->isDeclaration()) continue;
	    if (!calledS.insert(calleeF).second) {
	      // calleeF was already in calledS so it was not inserted
	      OSP_LOG(errs() << calleeF->getName() << " called more than once\n";);
	      m_blacklist.insert(calleeF);
	    }
	  }
	}
      }
    }
  }

  bool OnlyOnceSpecPolicy::intraSpecializeOn(CallSite CS, std::vector<Value*>& marks) {    
    const Function *calleeF = CS.getCalledFunction();
    if (!calleeF) {
      return false;
    }
    // don't touch a function if has been already specialized
    if (calleeF->getName().startswith(OccamSpecStr)) {
      return false;
    }
    auto it = m_blacklist.find(calleeF);
    if (it != m_blacklist.end()) {
      return false;
    }
    AggressiveSpecPolicy always_spec_policy;
    return always_spec_policy.intraSpecializeOn(CS, marks);
  }

  bool OnlyOnceSpecPolicy::interSpecializeOn(const Function& calleeF, 
					     const std::vector<PrevirtType>& args,
					     const ComponentInterface& interface,
					     SmallBitVector& marks) {

    // don't touch a function if has been already specialized
    if (calleeF.getName().startswith(OccamSpecStr)) {
      return false;
    }
    
    // interface contains all possible calls to calleeF from *all* the
    // other modules.
    if (std::distance(interface.call_begin(calleeF.getName()),
		      interface.call_end(calleeF.getName())) > 1) {
      return false;
    }
    
    AggressiveSpecPolicy always_spec_policy;
    return always_spec_policy.interSpecializeOn(calleeF, args, interface, marks);
  }
  
} // end namespace
