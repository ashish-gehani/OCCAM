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
 * PrevirtTypes.h
 *
 *  Created on: Jul 8, 2011
 *      Author: malecha
 */

#ifndef __PREVIRT_TYPES_H__
#define __PREVIRT_TYPES_H__


#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "occam"

// DLOG macro makes debug logging easier.
// Include 1) llvm/Support/Debug.h and 2) define DEBUG_TYPE in the source file.
// After that you can start using it like DLOG("message to log")
#define DLOG(x) DEBUG(dbgs() << __FILE__ << "[Line: " << __LINE__ << "]: " << __func__ << " > " << (x) << "\n")


#include "Serializer.h"
#include "proto/Previrt.pb.h"

#include <map>

namespace llvm {
  class Value;
  class Type;
  class LLVMContext;
}

namespace previrt
{
#define NO_MATCH    (-1)
#define EXACT_MATCH  0
#define LOOSE_MATCH  1

  class PrevirtType
  {
  private:
    proto::PrevirtType buffer;
    typedef std::map<llvm::Type*, llvm::Function*> EqCache;
    static EqCache cacheEq;
  public:
    PrevirtType();
    PrevirtType(const proto::PrevirtType&);
    static PrevirtType
    abstract(const llvm::Value* const);
    static PrevirtType
    unknown();

  public:
    PrevirtType&
    operator=(const PrevirtType&);
    bool
    operator!=(const PrevirtType&) const;
    bool
    operator==(const PrevirtType&) const;

  public:
    int
    refines(const llvm::Value* const) const;

    llvm::Value*
    concretize(llvm::Module&, llvm::Type*) const;

    bool
    isConcrete() const;

    bool
    isUnknown() const;

    std::string
    to_string() const;

  public:
    llvm::Function*
    getEqualityFunction(llvm::Module*) const;

  public:
    FRIEND_SERIALIZERS(PrevirtType, proto::PrevirtType)
  };
}

#endif /** __PREVIRT_TYPES_H__ **/
