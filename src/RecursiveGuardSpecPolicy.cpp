//
// OCCAM
//
// Copyright © 2011-2012, SRI International
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

#include "llvm/Function.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Support/raw_ostream.h"

#include "SpecializationPolicy.h"

#include <algorithm>
#include <map>
#include <set>
#include <list>
#include <utility>

using namespace llvm;

namespace previrt
{
  class RecursiveGuardSpecPolicy : public SpecializationPolicy
  {
  public:
    typedef std::map<Function*, int> SCC;

  private:
    CallGraph& cg;
    SpecializationPolicy* const delegate;
    SCC sccs;

  private:
    RecursiveGuardSpecPolicy(SpecializationPolicy* delegate, CallGraph& CG);

  public:
    virtual
    ~RecursiveGuardSpecPolicy();
    virtual void
    release();

  private:
    bool
    allowSpecialization(Function* f) const;

  public:
    virtual llvm::Value**
    specializeOn(llvm::Function* F, llvm::User::op_iterator begin,
        llvm::User::op_iterator end) const;

    virtual bool
    specializeOn(llvm::Function* F, const PrevirtType* begin,
        const PrevirtType* end, llvm::SmallBitVector& slice) const;

    virtual bool
    specializeOn(llvm::Function* F,
        std::vector<PrevirtType>::const_iterator begin,
        std::vector<PrevirtType>::const_iterator end,
        llvm::SmallBitVector& slice) const;

  private:
    friend SpecializationPolicy*
    SpecializationPolicy::recursiveGuard(SpecializationPolicy*,
        llvm::CallGraph&);
  };

  static void
  strongconnect(CallGraphNode* from, CallGraph& cg,
      std::list<Function*>& stack, std::set<Function*>& stack_contents,
      std::map<const Function*, std::pair<int, int> >& indicies, int& next_idx,
      RecursiveGuardSpecPolicy::SCC& result)
  {
    int base_idx = next_idx;
    Function* f = from->getFunction();
    indicies[f] = std::pair<int, int>(next_idx, next_idx);
    next_idx++;
    stack.push_back(f);

    bool self = false;

    for (CallGraphNode::iterator i = from->begin(), e = from->end(); i != e; ++i) {
      Function* fi = i->second->getFunction();
      if (fi == NULL) continue;
      if (fi == f) self = true;
      if (indicies.find(fi) == indicies.end()) {
        strongconnect(i->second, cg, stack, stack_contents, indicies, next_idx, result);
        std::pair<int,int>& wi = indicies[fi];
        std::pair<int,int>& vi = indicies[f];
        vi.second = std::min(vi.second, wi.second);
      } else if (stack_contents.find(fi) != stack_contents.end()) {
        std::pair<int,int>& wi = indicies[fi];
        std::pair<int,int>& vi = indicies[f];
        vi.second = std::min(vi.second, wi.first);
      }
    }

    std::pair<int,int>& vi = indicies[f];
    if (vi.first == vi.second) {
      if (stack.back() == f && !self) {
        stack.pop_back();
        return;
      }
      Function* w = NULL;
      do {
        w = stack.back();
        stack.pop_back();
        result[w] = base_idx;
      } while (w != f);
    }
  }

  static void
  scc(CallGraph &cg, RecursiveGuardSpecPolicy::SCC& scc)
  {
    std::map<const Function*, std::pair<int, int> > indicies;
    std::list<Function*> stack;
    std::set<Function*> stack_contents;
    int index = 0;

    for (CallGraph::iterator i = cg.begin(), e = cg.end(); i != e; ++i) {
      if (indicies.find(i->first) == indicies.end()) {
        strongconnect(i->second, cg, stack, stack_contents, indicies, index, scc);
      }
    }
  }

  RecursiveGuardSpecPolicy::RecursiveGuardSpecPolicy(
      SpecializationPolicy* _delegate, CallGraph& _cg) :
    cg(_cg), delegate(_delegate)
  {
    assert(delegate != NULL);

    scc(cg, this->sccs);
  }
  RecursiveGuardSpecPolicy::~RecursiveGuardSpecPolicy()
  {
    delegate->release();
  }
  void
  RecursiveGuardSpecPolicy::release()
  {
    delete this;
  }

  bool
  RecursiveGuardSpecPolicy::allowSpecialization(Function* F) const
  {
    SCC::const_iterator i = this->sccs.find(F);
    if (i == this->sccs.end()) {
      return true;
    } else {
      errs() << "Skipping specialization of recursive function '" << F->getName() << "'\n";
      return false;
    }
  }

  Value**
  RecursiveGuardSpecPolicy::specializeOn(Function* F, User::op_iterator begin,
      User::op_iterator end) const
  {
    if (allowSpecialization(F)) {
      return this->delegate->specializeOn(F, begin, end);
    } else {
      return NULL;
    }
  }

  bool
  RecursiveGuardSpecPolicy::specializeOn(Function* F, const PrevirtType* begin,
      const PrevirtType* end, SmallBitVector& slice) const
  {
    if (allowSpecialization(F)) {
      return this->delegate->specializeOn(F, begin, end, slice);
    } else {
      return false;
    }
  }

  bool
  RecursiveGuardSpecPolicy::specializeOn(Function* F,
      std::vector<PrevirtType>::const_iterator begin,
      std::vector<PrevirtType>::const_iterator end, SmallBitVector& slice) const
  {
    if (allowSpecialization(F)) {
      return this->delegate->specializeOn(F, begin, end, slice);
    } else {
      return false;
    }
  }

  SpecializationPolicy*
  SpecializationPolicy::recursiveGuard(SpecializationPolicy* policy,
      llvm::CallGraph& cg)
  {
    return new RecursiveGuardSpecPolicy(policy, cg);
  }
}

