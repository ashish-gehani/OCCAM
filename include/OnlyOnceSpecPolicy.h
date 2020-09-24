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
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#pragma once

#include "SpecializationPolicy.h"
#include "llvm/ADT/DenseSet.h"

namespace previrt {

/*
 * Allow a new (specialized) copy of a function if there will be
 * only one copy. I.e., the function will be called only once.
 *
 * Note that this is different from BoundedSpecPolicy with threshold
 * 1.
 */
class OnlyOnceSpecPolicy : public SpecializationPolicy {
  // Functions that cannot be copied because it is called more than
  // once. Used only for intra specialization.
  llvm::DenseSet<const llvm::Function *> m_blacklist;

public:
  // Constructor for inter specialization
  OnlyOnceSpecPolicy() = default;

  // Constructor for intra specialization: the module is used to
  // precompute information for faster queries.
  OnlyOnceSpecPolicy(llvm::Module &M);

  virtual ~OnlyOnceSpecPolicy() = default;

  virtual bool intraSpecializeOn(llvm::CallSite CS,
                                 std::vector<llvm::Value *> &marks) override;

  virtual bool interSpecializeOn(const llvm::Function &F,
                                 const std::vector<InterfaceType> &args,
                                 const ComponentInterface &interface,
                                 llvm::SmallBitVector &marks) override;
};

} // end namespace
