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

/*
 * Component.h
 *
 *  Created on: Jul 6, 2011
 *      Author: malecha
 */

#ifndef COMPONENT_H_
#define COMPONENT_H_

#include "llvm/Function.h"

namespace previrt
{
  class PrevirtComponent
  {
  protected:
    PrevirtComponent();
    virtual
    ~PrevirtComponent() = 0;

  public:
    virtual bool
    owns(Function*) const = 0;
    virtual FunctionType*
    request(const Function const*, User::op_iterator, User::op_iterator,
        SmallBitVector&) const = 0;
  };

  class ModuleComponent : public PrevirtComponent
  {
  private:
    typedef Function LocalFunction;
    const Module* module;
    SpecializationTable specTree;

  public:
    ModuleComponent(Module* M)
    : module(M)
    {
    }
    virtual
    ~ModuleComponent()
    {
    }

  public:
    virtual bool
    owns(Function* F) const
    {
      if (F->isDeclaration())
        return false;
      // TODO: For now, modules own all functions defined in them,
      //       there may come a point when we want to be able to split
      //       modules into different components
      return true;
    }
    virtual FunctionType*
    request(const Function const* target,
        User::op_iterator arg_begin, User::op_iterator arg_end,
        SmallBitVector& out_args) const
    {
      // determine if there is already a specialization

      // determine if the function can be specialized
      // call specialize()
      // return the handle to the function so that the caller can update
      //   the call
    }

  private:
    LocalFunction*
    specialize(LocalFunction*, User::op_iterator, User::op_iterator,
        SmallBitVector&)
    {
      // This is the "clone" code
      // Add meta-data
      // add to "specialize work queue"
    }
  };

  class Previrtualizer : public ModulePass
  {
  private:
    PrevirtComponent* strategy;
    StringMap<std::vector<Specialized> > specialized;
    StringMap<char*> principal;

  public:
    static char ID;

  public:
    Previrtualizer(SpecializationPolicy*);
    virtual
    ~Previrtualizer();

  public:
    virtual bool
    runOnModule(Module&);
  };

#endif /* COMPONENT_H_ */
