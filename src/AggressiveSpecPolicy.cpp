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

#include "llvm/IR/Function.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"
#include "llvm/PassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "SpecializationPolicy.h"

using namespace llvm;

namespace previrt
{
  class AggressiveSpecPolicy : public SpecializationPolicy
  {
  private:
    AggressiveSpecPolicy();
    static AggressiveSpecPolicy SINGLETON;

  public:
    virtual
    ~AggressiveSpecPolicy();
    virtual void
    release();

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
    friend SpecializationPolicy* SpecializationPolicy::aggressivePolicy();
  };

  AggressiveSpecPolicy::AggressiveSpecPolicy()
  {
  }
  AggressiveSpecPolicy::~AggressiveSpecPolicy()
  {
  }

  void
  AggressiveSpecPolicy::release()
  {
    // This is a singleton instance
  }

  Value**
  AggressiveSpecPolicy::specializeOn(Function* F, User::op_iterator begin,
      User::op_iterator end) const
  {
    Value** slice = NULL;
    const unsigned int arg_count = F->getArgumentList().size();

    for (unsigned int i = 0; i < arg_count && begin != end; ++begin, ++i) {
      Constant* cst = dyn_cast<Constant> (begin->get());
      if (SpecializationPolicy::isConstantSpecializable(cst)) {
        if (slice == NULL) {
          slice = new Value*[arg_count];
          for (unsigned int j = 0; j < i; ++j)
            slice[j] = NULL;
        }
        slice[i] = begin->get();
      } else if (slice != NULL) {
        slice[i] = NULL;
      }
    }

    return slice;
  }

  bool
  AggressiveSpecPolicy::specializeOn(Function* F, const PrevirtType* begin,
      const PrevirtType* end, SmallBitVector& slice) const
  {
    bool specialize = false;

    for (int i = 0; begin != end; ++begin, ++i) {
      if (begin->isConcrete()) {
        specialize = true;
        slice.set(i);
      }
    }

    return specialize;
  }

  bool
  AggressiveSpecPolicy::specializeOn(Function* F,
      std::vector<PrevirtType>::const_iterator begin,
      std::vector<PrevirtType>::const_iterator end, SmallBitVector& slice) const
  {
    bool specialize = false;
    for (int i = 0; begin != end; ++begin, ++i) {
      if (begin->isConcrete()) {
        specialize = true;
        slice.set(i);
      }
    }
    return specialize;
  }

  SpecializationPolicy*
  SpecializationPolicy::aggressivePolicy()
  {
    return &AggressiveSpecPolicy::SINGLETON;
  }

  AggressiveSpecPolicy AggressiveSpecPolicy::SINGLETON;
}
