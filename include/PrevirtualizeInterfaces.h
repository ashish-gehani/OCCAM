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

#ifndef __PREVIRTUALIZE_INTERFACES_H__
#define __PREVIRTUALIZE_INTERFACES_H__

#include "llvm/ADT/StringMap.h"
#include "llvm/IR/Function.h"

#include <vector>
#include <string>
#include <set>
#include <map>

#include "PrevirtTypes.h"

namespace llvm {
  //class Value;
}

namespace previrt
{
  typedef std::string FunctionHandle;

  struct CallInfo
  {
    unsigned count;
    std::vector<PrevirtType> args;
  public:
    int
    refines(llvm::User::op_iterator begin, llvm::User::op_iterator end);

  public:
    FRIEND_SERIALIZERS(CallInfo,proto::CallInfo)

  public:
    static CallInfo*
    Create(llvm::User::op_iterator, llvm::User::op_iterator, unsigned count = 0);
    static CallInfo*
    Create(unsigned len, unsigned count = 0);
    static CallInfo*
    Create(const std::vector<PrevirtType>&, unsigned count = 0);
  };

  class ComponentInterface
  {
  public:
    typedef llvm::StringMap<std::vector<CallInfo*> >::const_iterator
        FunctionIterator;
    typedef std::vector<CallInfo*>::const_iterator CallIterator;

  public:
    llvm::StringMap<std::vector<CallInfo*> > calls;
    std::set<std::string> references;

  public:
    ComponentInterface();
    virtual
    ~ComponentInterface();

  public:
    // add a call to the interface
    void
    call(FunctionHandle f, llvm::User::op_iterator args_begin,
        llvm::User::op_iterator args_end);

    void
    callAny(const llvm::Function* f);

    void
    reference(llvm::StringRef);

    CallInfo*
    getOrCreateCall(FunctionHandle f, const std::vector<PrevirtType>& args);

//    void
//    updateWith(ComponentInterface&);

    void
    dump() const;
  public:
    // iteration over the functions
    FunctionIterator
    begin() const;
    FunctionIterator
    end() const;

    // Find function
    FunctionIterator
    find(llvm::StringRef) const;

    // iteration over the calls to a function
    CallIterator
    call_begin(llvm::StringRef) const;
    CallIterator
    call_end(llvm::StringRef) const;

    CallIterator
    call_begin(FunctionIterator) const;
    CallIterator
    call_end(FunctionIterator) const;

  public:
    bool
    readFromFile(const std::string& filename);

  public:
    FRIEND_SERIALIZERS(ComponentInterface, proto::ComponentInterface)
  };

  struct CallRewrite
  {
    FunctionHandle function;
    const std::vector<unsigned> args;
  public:
    CallRewrite() :
      args()
    {
    }
    CallRewrite(FunctionHandle h, const std::vector<unsigned>& a);
    CallRewrite(const CallRewrite&);

  public:
    FRIEND_SERIALIZERS(CallRewrite, proto::CallRewrite)
  };

  class ComponentInterfaceTransform
  {
  public:
    typedef std::map<const CallInfo* const , const CallRewrite> CMap;
    typedef std::map<FunctionHandle, CMap> FMap;

  public:
    ComponentInterface* interface;
    FMap rewrites;
    bool ownsIface;

  public:
    ComponentInterfaceTransform();
    ComponentInterfaceTransform(ComponentInterface*);
    virtual
    ~ComponentInterfaceTransform();

  public:
    void
    rewrite(FunctionHandle, const CallInfo* const , FunctionHandle,
        const std::vector<unsigned>&);
    void
    rewrite(FunctionHandle, const CallInfo* const , const CallRewrite&);

    void
    dump() const;

  public:
    const ComponentInterface&
    getInterface() const;

    unsigned
    rewriteCount() const;

    const CallRewrite*
    lookupRewrite(FunctionHandle, llvm::User::op_iterator,
        llvm::User::op_iterator) const;

    const CallRewrite*
    lookupRewrite(FunctionHandle, const CallInfo* const ) const;

  public:
    bool
    readInterfaceFromFile(const std::string&);
    bool
    readTransformFromFile(const std::string&);

  public:
    FRIEND_SERIALIZERS(ComponentInterfaceTransform, proto::ComponentInterfaceTransform)
    friend void
        ::previrt::codeInto<proto::ComponentInterface,
            ComponentInterfaceTransform>(const proto::ComponentInterface&,
            ComponentInterfaceTransform&);
  };
}

#endif /** __PREVIRTUALIZE_INTERFACES_H__ **/
