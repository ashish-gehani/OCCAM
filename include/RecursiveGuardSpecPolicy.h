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
#pragma once

#include "llvm/ADT/DenseMap.h"
#include "llvm/Analysis/CallGraph.h"

#include "SpecializationPolicy.h"

#include <algorithm>
#include <set>
#include <list>
#include <utility>

namespace previrt
{
  
  /* This class takes as argument another specialization policy p.
     Specialize a callsite if the callee function is not recursive AND
     p also decides to specialize. */
  class RecursiveGuardSpecPolicy : public SpecializationPolicy
  {
    
    typedef llvm::DenseMap<llvm::Function*, int> SCC;

    llvm::CallGraph& cg;
    SpecializationPolicy* const delegate;
    SCC sccs;

    bool allowSpecialization(llvm::Function* f) const;

    /* Compute SCC of a callgraph */
    // FIXME: we can use scc stuff from LLVM to answer the question
    // whether a function is recursive or not. 
    void strongconnect(llvm::CallGraphNode* from, 
		       std::list<llvm::Function*>& stack,
		       std::set<llvm::Function*>& stack_contents,
		       llvm::DenseMap<const llvm::Function*, std::pair<int, int>>& indicies,
		       int& next_idx,
		       SCC& out);
    
    void build_scc(SCC& out);
    
  public:
    
    RecursiveGuardSpecPolicy(SpecializationPolicy* delegate, llvm::CallGraph& cg);

    virtual ~RecursiveGuardSpecPolicy();
    
    virtual bool specializeOn(llvm::CallSite CS,
			      std::vector<llvm::Value*>& slice) const override;

    virtual bool specializeOn(llvm::Function* F,
			      const PrevirtType* begin,
			      const PrevirtType* end,
			      llvm::SmallBitVector& slice) const override;

    virtual bool specializeOn(llvm::Function* F,
			      std::vector<PrevirtType>::const_iterator begin,
			      std::vector<PrevirtType>::const_iterator end,
			      llvm::SmallBitVector& slice) const override;

  };
} // end namespace previrt

