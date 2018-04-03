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
 * Previrtualizer.cpp
 *
 *  Created on: Jul 6, 2011
 *      Author: malecha
 */
#include "llvm/ADT/StringMap.h"

#include "PrevirtualizeInterfaces.h"

#include <vector>
#include <string>
#include <fstream>

#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace previrt
{
  // CallInfo
  int
  CallInfo::refines(llvm::User::op_iterator begin, llvm::User::op_iterator end)
  {
    int matched = 0;

    std::vector<PrevirtType>::const_iterator from = this->args.begin(), to =
        this->args.end();
    for (; begin != end; ++begin, ++from) {
      if (from == to)
        return NO_MATCH;

      int r = from->refines(begin->get());

      if (r == NO_MATCH)
        return NO_MATCH;

      matched += r;
    }
    if (from != to)
      return NO_MATCH;

    return matched;
  }

  template<>
    void
    codeInto<CallInfo, proto::CallInfo> (const CallInfo& ci,
        proto::CallInfo& buf)
    {
      buf.set_count(ci.count);
      for (std::vector<PrevirtType>::const_iterator i = ci.args.begin(), e =
          ci.args.end(); i != e; ++i) {
        codeInto<PrevirtType, proto::PrevirtType> (*i, *buf.add_args());
      }
    }

  template<>
    void
    codeInto<proto::CallInfo, CallInfo> (const proto::CallInfo& buf,
        CallInfo& ci)
    {
      ci.args.clear();
      ci.args.reserve(buf.args_size());
      for (int i = 0; i < buf.args_size(); i++) {
        PrevirtType info;
        codeInto<proto::PrevirtType, PrevirtType> (buf.args(i), info);
        ci.args.push_back(info);
      }
    }

  CallInfo*
  CallInfo::Create(User::op_iterator args_begin, User::op_iterator args_end,
      unsigned count)
  {
    CallInfo* result = new CallInfo();
    result->count = count;

    for (int i = 0; args_begin != args_end; i++, args_begin++) {
      PrevirtType tmp = PrevirtType::abstract(*args_begin);
      result->args.push_back(tmp);
    }
    return result;
  }
  CallInfo*
  CallInfo::Create(unsigned len, unsigned count)
  {
    CallInfo* result = new CallInfo();
    result->count = count;
    result->args.reserve(len);
    return result;
  }

  CallInfo*
  CallInfo::Create(const std::vector<PrevirtType>& args, unsigned count)
  {
    CallInfo* result = new CallInfo();
    result->count = count;
    result->args = args;
    return result;
  }

  // ComponentInterface
  ComponentInterface::ComponentInterface()
  {
  }

  ComponentInterface::~ComponentInterface()
  {
    const StringMap<std::vector<CallInfo*> >::iterator e = this->calls.end();
    for (StringMap<std::vector<CallInfo*> >::iterator b = this->calls.begin(); b
        != e; ++b) {
      for (std::vector<CallInfo*>::iterator cb = b->second.begin(), ce =
          b->second.end(); cb != ce; ++cb)
        delete *cb;
    }
  }

  void
  ComponentInterface::call(FunctionHandle f, User::op_iterator args_begin,
      User::op_iterator args_end)
  {
    if (this->calls.find(f) == this->calls.end()) {
      std::vector<CallInfo*> calls;
      calls.push_back(CallInfo::Create(args_begin, args_end, 1));
      this->calls[f] = calls;
    } else {
      std::vector<CallInfo*>& calls = this->calls[f];
      for (std::vector<CallInfo*>::const_iterator begin = calls.begin(), end =
          calls.end(); begin != end; ++begin) {
        User::op_iterator cur = args_begin;
        for (std::vector<PrevirtType>::const_iterator i =
            (*begin)->args.begin(), e = (*begin)->args.end(); i != e; ++i) {
          if (i->refines(cur->get()) == NO_MATCH)
            goto no;
        }
        (*begin)->count++;
        return;
        no: continue;
      }

      this->calls[f].push_back(CallInfo::Create(args_begin, args_end, 1));
    }
  }

  void
  ComponentInterface::callAny(const Function* f)
  {
    FunctionHandle fname = f->getName();
    if (this->calls.find(fname) == this->calls.end()) {
      std::vector<CallInfo*> calls;
      CallInfo* ci = CallInfo::Create(f->arg_size(), 1);
      ci->args.resize(f->arg_size(), PrevirtType::unknown());
      calls.push_back(ci);
      this->calls[fname] = calls;
    } else {
      std::vector<CallInfo*>& calls = this->calls[fname];
      for (std::vector<CallInfo*>::const_iterator begin = calls.begin(), end =
          calls.end(); begin != end; ++begin) {
        for (std::vector<PrevirtType>::const_iterator i =
            (*begin)->args.begin(), e = (*begin)->args.end(); i != e; ++i) {
          if (!i->isUnknown())
            goto no;
        }
        (*begin)->count++;
        return;
        no: continue;
      }
      CallInfo* ci = CallInfo::Create(f->arg_size(), 1);
      ci->args.resize(f->arg_size(), PrevirtType::unknown());
      this->calls[fname].push_back(ci);
    }
  }

  void
  ComponentInterface::reference(StringRef n)
  {
    this->references.insert(n);
  }

  CallInfo*
  ComponentInterface::getOrCreateCall(FunctionHandle f, const std::vector<
      PrevirtType>& args)
  {
    FunctionIterator itr = calls.find(f);
    CallInfo* result;
    if (itr == calls.end()) {
      std::vector<CallInfo*> infos;
      result = CallInfo::Create(args, 0);
      infos.push_back(result);
      calls[f] = infos;
      return result;
    } else {
      for (CallIterator c = itr->second.begin(), e = itr->second.end(); c != e; ++c) {
        if (args.size() != (*c)->args.size())
          continue;
        std::vector<PrevirtType>::const_iterator x = args.begin();
        for (std::vector<PrevirtType>::const_iterator y = (*c)->args.begin(),
            z = args.end(); x != z; ++x, ++y) {
          if (*x != *y)
            break;
        }
        if (x == args.end()) {
          return *c;
        }
      }
      result = CallInfo::Create(args, 0);
      calls[f].push_back(result);
      return result;
    }
  }

  void
  ComponentInterface::dump() const
  {
    for (FunctionIterator i = this->begin(), e = this->end(); i != e; ++i) {
      for (CallIterator ci = this->call_begin(i), ce = this->call_end(i); ci != ce; ++ci) {
        errs() << "call '" << i->first() << "'\n";
      }
    }

    for (std::set<std::string>::const_iterator i = this->references.begin(), e = this->references.end(); i != e; ++i) {
      errs() << "ref '" << *i << "'\n";
    }
  }

  ComponentInterface::FunctionIterator
  ComponentInterface::begin() const
  {
    return this->calls.begin();
  }
  ComponentInterface::FunctionIterator
  ComponentInterface::end() const
  {
    return this->calls.end();
  }

  ComponentInterface::FunctionIterator
  ComponentInterface::find(StringRef key) const
  {
    return this->calls.find(key);
  }

  ComponentInterface::CallIterator
  ComponentInterface::call_begin(StringRef n) const
  {
    FunctionIterator i = this->calls.find(n);
    assert(i != this->calls.end());
    return i->second.begin();
  }

  ComponentInterface::CallIterator
  ComponentInterface::call_end(StringRef n) const
  {
    FunctionIterator i = this->calls.find(n);
    assert (i != this->calls.end());
    return i->second.end();
  }

  ComponentInterface::CallIterator
  ComponentInterface::call_begin(FunctionIterator i) const
  {
    return i->second.begin();
  }
  ComponentInterface::CallIterator
  ComponentInterface::call_end(FunctionIterator i) const
  {
    return i->second.end();
  }

  template<>
    void
    codeInto<ComponentInterface, proto::ComponentInterface> (
        const ComponentInterface& ci, proto::ComponentInterface& buf)
    {
      for (ComponentInterface::FunctionIterator f = ci.calls.begin(), fe =
          ci.calls.end(); f != fe; ++f) {
        for (ComponentInterface::CallIterator c = f->second.begin(), ce =
            f->second.end(); c != ce; ++c) {

          proto::CallInfo* info = buf.add_calls();
          info->set_name(f->first());
          codeInto<CallInfo, proto::CallInfo> (**c, *info);
        }
      }
      buf.mutable_references()->Reserve(ci.references.size());
      for (std::set<std::string>::const_iterator i = ci.references.begin(), e =
          ci.references.end(); i != e; ++i) {
        buf.add_references(*i);
      }
    }

  template<>
    void
    codeInto<proto::ComponentInterface, ComponentInterface> (
        const proto::ComponentInterface& buf, ComponentInterface& ci)
    {
      for (int i = 0; i < buf.calls_size(); i++) {
        const proto::CallInfo& info = buf.calls(i);
        StringRef name = info.name();
        CallInfo* res = new CallInfo();
        codeInto(info, *res);
        llvm::StringMap<std::vector<CallInfo*> >::iterator itr = ci.calls.find(
            name);
        if (itr == ci.calls.end()) {
          std::vector<CallInfo*> infos;
          infos.push_back(res);
          ci.calls[name] = infos;
        } else {
          itr->second.push_back(res);
        }
      }
      for (google::protobuf::RepeatedPtrField<std::string>::const_iterator
          i = buf.references().begin(), e = buf.references().end(); i != e; ++i) {
        ci.references.insert(*i);
      }
    }

  bool
  ComponentInterface::readFromFile(const std::string& filename)
  {
    assert(filename != "");
    std::ifstream input(filename.c_str(), std::ios::binary);
    if (input.fail()) {
      return false;
    }
    proto::ComponentInterface buf;
    if (!buf.ParseFromIstream(&input)) {
      input.close();
      return false;
    }
    codeInto<proto::ComponentInterface, ComponentInterface> (buf, *this);
    input.close();
    return true;
  }

  // CallRewrite
  CallRewrite::CallRewrite(FunctionHandle h, const std::vector<unsigned>& a) :
    function(h), args(a)
  {
  }
  CallRewrite::CallRewrite(const CallRewrite& x) :
    function(x.function), args(x.args)
  {
  }

  template<>
    void
    codeInto<proto::CallRewrite, CallRewrite> (const proto::CallRewrite& buf,
        CallRewrite& ci)
    {
      ci.function = StringRef(buf.new_function());
      std::vector<unsigned>* non_const =
          const_cast<std::vector<unsigned>*> (&ci.args);
      non_const->reserve((unsigned) buf.args_size());
      non_const->assign(buf.args().begin(), buf.args().end());
    }

  template<>
    void
    codeInto<CallRewrite, proto::CallRewrite> (const CallRewrite& ci,
        proto::CallRewrite& buf)
    {
      buf.set_new_function(ci.function);
      buf.mutable_args()->Reserve(ci.args.size());
      for (std::vector<unsigned>::const_iterator i = ci.args.begin(), e =
          ci.args.end(); i != e; ++i) {
        buf.mutable_args()->AddAlreadyReserved(*i);
      }
    }

  // ComponentInterfaceTransform
  template<>
    void
    codeInto<ComponentInterfaceTransform, proto::ComponentInterfaceTransform> (
        const ComponentInterfaceTransform& ci,
        proto::ComponentInterfaceTransform& buf)
    {
      for (ComponentInterface::FunctionIterator fi = ci.interface->begin(), fe =
          ci.interface->end(); fi != fe; ++fi) {
        for (ComponentInterface::CallIterator c = ci.interface->call_begin(fi),
            e = ci.interface->call_end(fi); c != e; ++c) {
          const CallRewrite* rw = ci.lookupRewrite(fi->first(), *c);
          if (rw != NULL) {
            proto::CallRewrite* nrw = buf.add_calls();
            codeInto<CallRewrite, proto::CallRewrite> (*rw, *nrw);
            nrw->mutable_call()->set_name(fi->first());
            codeInto<CallInfo, proto::CallInfo> (**c, *nrw->mutable_call());
          }
        }
      }
    }

  template<>
    void
    codeInto<proto::ComponentInterface, ComponentInterfaceTransform> (
        const proto::ComponentInterface& buf, ComponentInterfaceTransform& ci)
    {
      if (ci.interface == NULL) {
        ci.ownsIface = true;
        ci.interface = new ComponentInterface();
      }
      codeInto<proto::ComponentInterface, ComponentInterface> (buf,
          *ci.interface);
    }

  template<>
    void
    codeInto<proto::ComponentInterfaceTransform, ComponentInterfaceTransform> (
        const proto::ComponentInterfaceTransform& buf,
        ComponentInterfaceTransform& ci)
    {
      if (ci.interface == NULL) {
        ci.ownsIface = true;
        ci.interface = new ComponentInterface();
      }
      assert (ci.interface != NULL);

      for (int i = 0; i < buf.calls_size(); i++) {
        const proto::CallRewrite& rw = buf.calls(i);
        const proto::CallInfo& info = rw.call();
        StringRef name = info.name();
        CallInfo res;
        codeInto<proto::CallInfo, CallInfo> (info, res);
        CallInfo* result = ci.interface->getOrCreateCall(name, res.args);
        result->count += info.count();

        CallRewrite rewrite;
        codeInto<proto::CallRewrite, CallRewrite> (rw, rewrite);
        ci.rewrite(name, result, rewrite);
      }
    }

  ComponentInterfaceTransform::ComponentInterfaceTransform() :
    interface(NULL), ownsIface(true)
  {
  }

  ComponentInterfaceTransform::ComponentInterfaceTransform(
      ComponentInterface* ci) :
    interface(ci), ownsIface(false)
  {
  }

  ComponentInterfaceTransform::~ComponentInterfaceTransform()
  {
    if (ownsIface && interface) {
      delete interface;
    }
  }

  void
  ComponentInterfaceTransform::rewrite(FunctionHandle hndl,
      const CallInfo* const from, FunctionHandle to,
      const std::vector<unsigned>& to_args)
  {
    rewrite(hndl, from, CallRewrite(to, to_args));
  }

  void
  ComponentInterfaceTransform::rewrite(FunctionHandle hndl,
      const CallInfo* const from, const CallRewrite& to)
  {
    if (this->rewrites.find(hndl) == this->rewrites.end()) {
      this->rewrites[hndl]
          = std::map<const CallInfo* const , const CallRewrite>();
    }

    this->rewrites[hndl].insert(std::pair<const CallInfo* const ,
        const CallRewrite>(from, to));
  }

  void
  ComponentInterfaceTransform::dump() const
  {
    for (FMap::const_iterator i = this->rewrites.begin(), e =
        this->rewrites.end(); i != e; ++i) {
      for (CMap::const_iterator ii = i->second.begin(), ee = i->second.end(); ii
          != ee; ++ii) {
        errs() << "'" << i->first << "' -> '" << ii->second.function << "'\n";
      }
    }
  }

  const ComponentInterface&
  ComponentInterfaceTransform::getInterface() const
  {
    if (this->interface == NULL) {
      ComponentInterfaceTransform* non_const =
          const_cast<ComponentInterfaceTransform*> (this);
      non_const->interface = new ComponentInterface();
      non_const->ownsIface = true;
    }
    return *this->interface;
  }

  unsigned
  ComponentInterfaceTransform::rewriteCount() const
  {
    unsigned result = 0;
    for (FMap::const_iterator i = this->rewrites.begin(), e =
        this->rewrites.end(); i != e; ++i)
      result += i->second.size();
    return result;
  }

  CallRewrite const*
  ComponentInterfaceTransform::lookupRewrite(FunctionHandle name,
      llvm::User::op_iterator op_begin, llvm::User::op_iterator op_end) const
  {
    assert(interface != NULL);
    const CallInfo* search = NULL;
    int score = -1;

    ComponentInterface::FunctionIterator itr = this->interface->calls.find(
        name.c_str());
    if (itr == this->interface->calls.end()) {
      return NULL;
    }

    for (ComponentInterface::CallIterator begin = this->interface->call_begin(
        itr), end = this->interface->call_end(itr); begin != end; ++begin) {
      int tscore = (*begin)->refines(op_begin, op_end);
      if (tscore > score) {
        score = tscore;
        search = *begin;
      }
    }

    if (search != NULL)
      return this->lookupRewrite(name, search);
    return NULL;
  }

  const CallRewrite*
  ComponentInterfaceTransform::lookupRewrite(FunctionHandle name,
      const CallInfo* const key) const
  {
    assert(key != NULL);
    assert(interface != NULL);
    FMap::iterator f = const_cast<FMap&> (this->rewrites).find(name);
    if (f == this->rewrites.end()) {
      return NULL;
    }
    CMap::const_iterator c = f->second.find(key);
    if (c == f->second.end())
      return NULL;

    return &(c->second);
  }

  bool
  ComponentInterfaceTransform::readInterfaceFromFile(
      const std::string& filename)
  {
    assert(filename != "");
    std::ifstream input(filename.c_str(), std::ios::binary);
    if (input.fail()) {
      return false;
    }
    proto::ComponentInterface buf;
    if (!buf.ParseFromIstream(&input)) {
      input.close();
      return false;
    }
    codeInto<proto::ComponentInterface, ComponentInterfaceTransform> (buf,
        *this);
    input.close();
    return true;
  }

  bool
  ComponentInterfaceTransform::readTransformFromFile(
      const std::string& filename)
  {
    assert(filename != "");
    std::ifstream input(filename.c_str(), std::ios::binary);
    if (input.fail()) {
      return false;
    }
    proto::ComponentInterfaceTransform buf;
    if (!buf.ParseFromIstream(&input)) {
      input.close();
      return false;
    }
    codeInto<proto::ComponentInterfaceTransform, ComponentInterfaceTransform> (
        buf, *this);
    input.close();
    return true;
  }
}
