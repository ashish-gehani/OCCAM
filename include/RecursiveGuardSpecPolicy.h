//
// OCCAM
//
// Copyright (c) 2011-2020, SRI International
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
#pragma once

#include "llvm/ADT/SmallSet.h"
#include "llvm/Analysis/CallGraph.h"

#include "SpecializationPolicy.h"

namespace previrt {
  /* 
   * This policy is actually a "functor" policy (i.e., it takes as
   * argument another policy).
   *
   * Allows a new (specialized) copy of a function if it is not
   * recursive AND p also decides to specialize.
  */
  class RecursiveGuardSpecPolicy : public SpecializationPolicy {
    
    typedef llvm::SmallSet<llvm::Function*, 32> FunctionSet;

    llvm::CallGraph& m_cg;
    std::unique_ptr<SpecializationPolicy> m_subpolicy;
    FunctionSet m_rec_functions;
    
    void markRecursiveFunctions();
    bool isRecursive(const llvm::Function& f) const;    
    bool allowSpecialization(const llvm::Function& f) const;

  public:
    
    RecursiveGuardSpecPolicy(std::unique_ptr<SpecializationPolicy> subpolicy,
			     llvm::CallGraph& cg);

    virtual ~RecursiveGuardSpecPolicy() = default;
    
    virtual bool intraSpecializeOn(llvm::CallSite CS,
				   std::vector<llvm::Value*>& marks) override;

    virtual bool interSpecializeOn(const llvm::Function& F,
				   const std::vector<InterfaceType>& args,
				   const ComponentInterface& interface,
				   llvm::SmallBitVector& marks) override;

  };
} // end namespace previrt

