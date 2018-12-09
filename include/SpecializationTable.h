//
// OCCAM
//
// Copyright (c) 2011-2016, SRI International
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
 * SpecializationTable.h
 *
 *  Created on: Jun 21, 2011
 *      Author: Gregory Malecha
 */

#pragma once

#include "llvm/ADT/StringMap.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallBitVector.h"

#include <vector>

namespace llvm
{
  class Value;
  class Function;
  class Module;
}

namespace previrt
{
  class SpecializationTable
  {
  public:
    typedef std::vector<llvm::Value*> SpecScheme;

    struct Specialization {
      llvm::Function* handle;
      SpecScheme args;
      const Specialization* parent;
      std::vector<Specialization*> children;

      // Return true if l is more specific than r
      static bool refines(SpecScheme l, SpecScheme r);
    };

  private:
    
    typedef llvm::DenseMap<llvm::Function*,Specialization*> SpecTable;
    mutable SpecTable specialized;
    llvm::Module* module;

  public:
    
    SpecializationTable();
    
    SpecializationTable(llvm::Module*);
    
    virtual ~SpecializationTable();
      
    void initialize(llvm::Module*);
      
    void getSpecializations(llvm::Function*, SpecScheme,
			    std::vector<const Specialization*>&) const;
    
    bool addSpecialization(llvm::Function*, SpecScheme, llvm::Function*, bool record=true);

    const Specialization* getPrincipalSpecialization(llvm::Function*) const;
      
    Specialization* getSpecialization(llvm::Function*) const;
    
    const llvm::Function* getPrincipalFunction(const llvm::Function*) const;
    
  };
}
