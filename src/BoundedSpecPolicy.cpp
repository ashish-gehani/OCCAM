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

#include "BoundedSpecPolicy.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define BSP_LOG(...) __VA_ARGS__
//#define BSP_LOG(...)

namespace previrt {

  static StringRef OccamSpecStr = "__occam_spec.";
  
  BoundedSpecPolicy::BoundedSpecPolicy(Module &M, 
				       std::unique_ptr<SpecializationPolicy> subpolicy,
				       unsigned threshold)
    : m_subpolicy(std::move(subpolicy))
    , m_threshold(threshold) {

    // HACK: slash can run the specializer on the same module multiple
    // times.  We need to try to identify if a function has been
    // specialized already (and how many times) in order to start with
    // the right counter. Otherwise, the bounded policy will become
    // aggressive.

    for (auto &F: M) {
      if (F.isDeclaration()) continue;
      if (F.getName().startswith(OccamSpecStr)) {
    	StringRef name = F.getName();
    	// remove "__occam.spec."
    	name = name.split(OccamSpecStr).second;
    	// keep the string just before the first ( character
    	name = name.split("(").first;
    	// We might fail updating the counter if two functions have
    	// the same name.
    	if (const Function *specFunction = M.getFunction(name)) {
    	  auto it = m_num_copy_map.find(specFunction);
    	  if (it != m_num_copy_map.end()) {
    	    it->second++;
    	  } else {
    	    m_num_copy_map.insert(std::make_pair(specFunction, 1));
    	  }
    	}
      }
    }
  }
  
  unsigned BoundedSpecPolicy::addCounter(const Function &f) {
    auto it = m_num_copy_map.find(&f);
    if (it != m_num_copy_map.end()) {
      unsigned &val = it->second;
      return ++val;
    } else {
      m_num_copy_map.insert(std::make_pair(&f,1));
      return 1;
    }
  }
  
  bool BoundedSpecPolicy::intraSpecializeOn(CallSite CS,
					    std::vector<Value*>& marks) {
    const Function* calleeF = CS.getCalledFunction();
    if (!calleeF) {
      return false;
    }
    if (calleeF->getName().startswith(OccamSpecStr)) {
      return false;
    }

    if (m_subpolicy->intraSpecializeOn(CS, marks)) {
      unsigned num_copies = addCounter(*calleeF);
      bool res = (num_copies <= m_threshold);
      if (res) {
	BSP_LOG(errs() << "[BSP] " << 
		calleeF->getName() << " has been copied " << num_copies << "\n";); 
      } else {
	BSP_LOG(errs() << "[BSP] " << calleeF->getName() << " cannot be copied anymore\n";);
      } 
      return res;
    }
    
    //XXX: should we reset marks?
    return false;
  }
  
  bool BoundedSpecPolicy::interSpecializeOn(const Function& calleeF,
					    const std::vector<InterfaceType>& args,
					    const ComponentInterface& interface,
					    SmallBitVector& marks)  {

    if (calleeF.getName().startswith(OccamSpecStr)) {
      return false;
    }
    
    if (m_subpolicy->interSpecializeOn(calleeF, args, interface, marks)) {
      unsigned num_copies = addCounter(calleeF);
      bool res = (num_copies <= m_threshold);
      if (res) {
	BSP_LOG(errs() << "[BSP] " << 
		calleeF.getName() << " in library " << calleeF.getParent()->getName() << 
		" has been copied " << num_copies << "\n";); 
      } else {
	BSP_LOG(errs() << "[BSP] " << calleeF.getName() << " cannot be copied anymore\n";);
      } 
      return res;
    }

    //XXX: should we reset marks?    
    return false;
  }

} // end namespace previrt

