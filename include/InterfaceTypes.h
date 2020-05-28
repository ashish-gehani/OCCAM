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

/*
 * PrevirtTypes.h
 *
 *  Created on: Jul 8, 2011
 *      Author: malecha
 */

#pragma once

#include "Serializer.h"
#include "proto/Previrt.pb.h"

#include <map>

namespace llvm {
class Value;
class Function;
class Module;
class Type;
class LLVMContext;
}

namespace previrt {
#define NO_MATCH (-1)
#define EXACT_MATCH 0
#define LOOSE_MATCH 1

/*
 * An interface for a module M records its external calls.  Each
 * call argument is annotated with a type.
 *
 * This class represents these types and describes operations on
 * them.
 *
 * Some LLVM values can be abstracted by its "interface type".
 *
 * The set of interface types T consists of:
 * 
 * {U, StrCst(V), IntCst(V), FPCst(V), GV(V)}
 *
 * Note that U is a single element but the rest represent actually
 * the sets of string constants, integer constants, floating point
 * constants, and global values, respectively.
 * 
 * T is equipped with an ordering "<=" between elements in the set,
 * where U is greatest element of the partial order.
 * 
 *    That is, \forall e \in T:: e <= U.
 * 
 * StrCst(_) is incomparable with IntCst(_), FPCst(_), and GV(_)
 * IntCst(_) is incomparable with StrCst(_), FPCst(_), and GV(_)
 * FPCst(_) is incomparable with StrCst(_), IntCst(_), and GV(_)
 * GV(_) is incomparable with StrCst(_), IntCst(_), and FPCst(_)  
 *
 * StrCst(V1) <= StrCst(V2) iff V1 == V2
 * IntCst(V1) <= IntCst(V2) iff V1 == V2
 * FPCst(V1)  <= FPCst(V2)  iff V1 == V2
 * GVCst(V1)  <= GVCst(V2)  iff V1 == V2  
 *
 * So the "interface type" abstraction is pretty similar to constant
 * propagation, but constant are split into groups (integer, fp, etc).
 *
 */
class InterfaceType {
private:
  proto::PrevirtType buffer;
  typedef std::map<llvm::Type *, llvm::Function *> EqCache;
  static EqCache cacheEq;

public:
  InterfaceType();
  InterfaceType(const proto::PrevirtType &);
  InterfaceType &operator=(const InterfaceType &);
  bool operator!=(const InterfaceType &) const;
  bool operator==(const InterfaceType &) const;

  // Return 0 or 1 if abstract(V) <= "this". Otherwise, it returns -1.
  // 
  // 0 : indicates EXACT_MATCH (i.e., "this" is not U)
  // 1 : indicates LOOSE_MATCH (i.e., "this" is U)
  // -1: indicates NO_MATCH
  //
  int refines(const llvm::Value *const V) const;
  // Abstract a LLVM value to an interface type
  static InterfaceType abstract(const llvm::Value *const);
  // Return U
  static InterfaceType unknown();
  llvm::Value *concretize(llvm::Module &, llvm::Type *) const;
  bool isConcrete() const;
  bool isUnknown() const;
  std::string to_string() const;

  llvm::Function *getEqualityFunction(llvm::Module *) const;

  FRIEND_SERIALIZERS(InterfaceType, proto::PrevirtType)
};
}
