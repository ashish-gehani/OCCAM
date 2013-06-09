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

#include "llvm/Analysis/CallGraph.h"
#include "llvm/ADT/SmallBitVector.h"

#include "PrevirtualizeInterfaces.h"

#include <list>

namespace llvm
{
  class AliasAnalysis;
}

namespace previrt
{
  /*
   * Compute the minimal interface that the given module depends on
   * - This is the dependents of the externally visible functions
   */
  void
  GatherInterface(llvm::Module& M, ComponentInterface& I,
      llvm::AliasAnalysis* aa = NULL);

  /*
   * Compute the minimal interface that the given function depends on
   * NOTE: Use GatherInterface2 instead
   */
  void
  GatherInterface(llvm::Function& M, ComponentInterface& I,
      llvm::AliasAnalysis* aa = NULL);

  /*
   * Compute the minimal interface that the given function depends on
   */
  void
  GatherInterface2(const llvm::CallGraph&, ComponentInterface&, std::list<llvm::Function*>* roots = NULL);

  /*
   * Reduce this module with respect to the given interface.
   * - The interface suggests some of the uses of the functions,
   *   so here we can generate special versions of those functions.
   * Generate a ComponentInterfaceTransform for clients to rewrite their
   * code to use the new API
   */
  class SpecializationPolicy;

  bool
  SpecializeComponent(llvm::Module& M, ComponentInterfaceTransform& T,
      SpecializationPolicy &policy);

  /*
   * Rewrite the given module according to the ComponentInterfaceTransformer.
   */
  bool
  TransformComponent(llvm::Module& M, ComponentInterfaceTransform& T);

  /*
   * Remove all code from the given module that is not necessary to
   * implement the given interface.
   */
  bool
  MinimizeComponent(llvm::Module& M, ComponentInterface& I);

  /*
   * Policy for how to split
   */
  struct SlicePolicy
  {
  protected:
    SlicePolicy();
  public:
    virtual
    ~SlicePolicy();

    virtual bool
    keepFunction(const llvm::Function& f) const = 0;
    virtual bool
    keepAsm() const = 0;
  };

  bool
  sliceComponent(llvm::Module& M, const SlicePolicy& policy);

  /*
   * Interface Enforcement & Watching
   * - watch is more expressive
   *   - actually able to express "function x can not be called"
   */
  bool
  enforceInterface(llvm::Module& M, ComponentInterface&, bool);

  bool
  watchFunction(llvm::Function* inside, llvm::Function* const delegate,
      const proto::ActionTree& policy, llvm::Constant* policyError,
      bool fancyFail = false);
}
