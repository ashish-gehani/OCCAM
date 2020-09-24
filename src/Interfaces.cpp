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
 * Previrtualizer.cpp
 *
 *  Created on: Jul 6, 2011
 *      Author: malecha
 */
#include "llvm/ADT/StringMap.h"

#include "Interfaces.h"

#include <fstream>
#include <string>
#include <vector>

#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace previrt {


/* 
   Return -1 if exits one argument for which there is no an abstract
   or exact match. Otherwise, it return a non-negative number that
   indicates the number of abstract matches. If it returns 0 then
   arguments are equal in terms of types.
 */  
  int CallInfo::refines(llvm::User::op_iterator begin,
			llvm::User::op_iterator end) {
  std::vector<InterfaceType>::const_iterator from = this->args.begin(),
                                             to = this->args.end();
  if (std::distance(begin, end) != std::distance(from, to)) {
    return -1;
  }
  int loose_matched = 0;
  for (; begin != end; ++begin, ++from) {
    TypeRefinementKind r = from->refines(begin->get());
    if (r == TypeRefinementKind::NO_MATCH) {
      return -1;
    } else if (r == TypeRefinementKind::LOOSE_MATCH) {
      loose_matched++;
    } else {
      // if exact match then do not increment counter.
    }
  }
  return loose_matched;
}

template <>
void codeInto<CallInfo, proto::CallInfo>(const CallInfo &ci,
                                         proto::CallInfo &buf) {
  buf.set_count(ci.get_count());
  for (auto ty: llvm::make_range(ci.args_begin(), ci.args_end())) {
    codeInto<InterfaceType, proto::PrevirtType>(ty, *buf.add_args());
  }
}

template <>
void codeInto<proto::CallInfo, CallInfo>(const proto::CallInfo &buf,
                                         CallInfo &ci) {
  ci.args.clear();
  ci.args.reserve(buf.args_size());
  for (unsigned i = 0, sz= buf.args_size(); i<sz; i++) {
    InterfaceType info;
    codeInto<proto::PrevirtType, InterfaceType>(buf.args(i), info);
    ci.args.push_back(info);
  }
}

CallInfo *CallInfo::Create(User::op_iterator args_begin,
                           User::op_iterator args_end, unsigned count) {
  CallInfo *result = new CallInfo();
  result->count = count;

  for (auto &A: llvm::make_range(args_begin, args_end)) {
    result->args.push_back(InterfaceType::abstract(A));
  }
  
  return result;
}
  
CallInfo *CallInfo::Create(unsigned len, unsigned count) {
  CallInfo *result = new CallInfo();
  result->count = count;
  result->args.reserve(len);
  return result;
}

CallInfo *CallInfo::Create(const std::vector<InterfaceType> &args,
                           unsigned count) {
  CallInfo *result = new CallInfo();
  result->count = count;
  result->args = args;
  return result;
}

// ComponentInterface
ComponentInterface::~ComponentInterface() {
  for (auto &kv: m_calls) {
    for (CallInfo *CI: kv.second) {
      delete CI;
    }
  }
}

// Add a call f(abstract(args_begin), ..., abstract(args_end)) in the
// interface if there is no already an entry that it's not equal to.
void ComponentInterface::callTo(FunctionHandle f, User::op_iterator args_begin,
				User::op_iterator args_end) {
  //
  // Each argument in CI.args.begin() ... CI.args.end() contains a
  // type (see InterfaceTypes.h comments for more details)
  //


  
  // Return true if types of arguments of f(args_begin,...,args_end)
  // are consistent with types of argument of CI **and** there exists
  // one f's argument "x" for which "x" has a more precise type than
  // its corresponding argument in CI.
  // auto refines = [&args_begin, &args_end](CallInfo &CI) {
  //   if (std::distance(args_begin, args_end) != CI.num_args()) {
  //     // This is possible for variadic functions
  //     return false;
  //   }
  //   auto cur = args_begin;
  //   bool is_refined = false;
  //   for (auto ty: llvm::make_range(CI.args_begin(), CI.args_end())) {
  //     // ask if type of f's argument  refines type of entry's argument
  //     TypeRefinementKind res = ty.refines(cur->get());
  //     if (res == TypeRefinementKind::NO_MATCH) {
  // 	// inconsistent types
  // 	return false;
  //     } else if (res == TypeRefinementKind::LOOSE_MATCH) {
  // 	// found f's argument which a more precise type than CI's argument
  // 	is_refined = true;
  //     } else {
  // 	// same type: do nothing
  //     }
  //     ++cur;
  //   }
  //   return is_refined;
  // };


  // Return true if types of arguments of f(args_begin,...,args_end)
  // are exactly the same than the types of argument of CI.
  auto is_equal = [](User::op_iterator fargs_begin,
		     User::op_iterator fargs_end,
		     CallInfo &CI) {
    if (std::distance(fargs_begin, fargs_end) != CI.num_args()) {
      return false;
    }
    auto cur = fargs_begin;
    for (auto ty: llvm::make_range(CI.args_begin(), CI.args_end())) {
      // ask if type of f's argument  refines type of entry's argument
      TypeRefinementKind res = ty.refines(cur->get());
      if (res == TypeRefinementKind::NO_MATCH ||
	  res == TypeRefinementKind::LOOSE_MATCH) {
  	return false;
      } 
      ++cur;
    }
    return false;
  };
    
  
  if (m_calls.find(f) == m_calls.end()) {
    std::vector<CallInfo *> calls;
    calls.push_back(CallInfo::Create(args_begin, args_end, 1));
    m_calls[f] = calls;
  } else {
    std::vector<CallInfo *> &calls = m_calls[f];
    for (CallInfo *CI: calls) {
      // if (refines(*CI)) {
      // 	// CI already subsumes the one we want to add.
      // 	CI->get_count()++;
      // 	return;
      // }
      if (is_equal(args_begin, args_end, *CI)) { 
    	// The function f(args_begin,...,args_end) is already  in m_calls
    	CI->get_count()++;
    	return;
      } 
    }
    m_calls[f].push_back(CallInfo::Create(args_begin, args_end, 1));
  }
}
  
void ComponentInterface::callFrom(const Function *f) {
  // FunctionHandle fname = f->getName();
  // if (this->calls.find(fname) == this->calls.end()) {
  //   std::vector<CallInfo *> calls;
  //   CallInfo *CI = CallInfo::Create(f->arg_size(), 1);
  //   CI->args.resize(f->arg_size(), InterfaceType::unknown());
  //   calls.push_back(CI);
  //   this->calls[fname] = calls;
  // } else {
  //   std::vector<CallInfo *> &calls = this->calls[fname];
  //   for (CallInfo *CI: calls) {
  //     if (CI->num_args() == f->arg_size() && 
  // 	  std::all_of(CI->args_begin(), CI->args_end(),
  // 		      [](const InterfaceType & ty) {
  // 			return ty.isUnknown();
  // 		      })) {
  // 	CI->get_count()++;
  // 	return;
  //     }
  //   }
  
  //   CallInfo *CI = CallInfo::Create(f->arg_size(), 1);
  //   CI->args.resize(f->arg_size(), InterfaceType::unknown());
  //   this->calls[fname].push_back(CI);
  // }
}

void ComponentInterface::reference(StringRef n) {
  m_references.insert(n);
}

CallInfo *
ComponentInterface::getOrCreateCall(FunctionHandle f,
                                    const std::vector<InterfaceType> &args) {
  auto it = m_calls.find(f);
  CallInfo *result;
  if (it == m_calls.end()) {
    std::vector<CallInfo *> infos;
    result = CallInfo::Create(args, 0);
    infos.push_back(result);
    m_calls[f] = infos;
    return result;
  } else {
    for (CallIterator c = it->second.begin(), e = it->second.end(); c != e;
         ++c) {
      if (args.size() != (*c)->args.size())
        continue;
      std::vector<InterfaceType>::const_iterator x = args.begin();
      for (std::vector<InterfaceType>::const_iterator y = (*c)->args.begin(),
                                                      z = args.end();
           x != z; ++x, ++y) {
        if (*x != *y)
          break;
      }
      if (x == args.end()) {
        return *c;
      }
    }
    result = CallInfo::Create(args, 0);
    m_calls[f].push_back(result);
    return result;
  }
}

void ComponentInterface::dump() const {
  write(llvm::errs());
}

ComponentInterface::FunctionIterator ComponentInterface::begin() const {
  return FunctionIterator(m_calls.begin());
}
ComponentInterface::FunctionIterator ComponentInterface::end() const {
  return FunctionIterator(m_calls.end());
}

ComponentInterface::CallIterator
ComponentInterface::call_begin(StringRef n) const {
  
  auto it = m_calls.find(n);
  assert(it != m_calls.end());
  return it->second.begin();
}

ComponentInterface::CallIterator
ComponentInterface::call_end(StringRef n) const {
  auto it = m_calls.find(n);
  assert(it != m_calls.end());
  return it->second.end();
}

template <>
void codeInto<ComponentInterface, proto::ComponentInterface>(
    const ComponentInterface &ci, proto::ComponentInterface &buf) {
  for (auto &kv: ci.m_calls) {
    for (auto c: kv.second) {
      proto::CallInfo *info = buf.add_calls();
      info->set_name(kv.first());
      codeInto<CallInfo, proto::CallInfo>(*c, *info);
    }
  }
  
  buf.mutable_references()->Reserve(ci.m_references.size());
  for (auto ref: ci.m_references) {
    buf.add_references(ref);
  }
}

template <>
void codeInto<proto::ComponentInterface, ComponentInterface>(
    const proto::ComponentInterface &buf, ComponentInterface &ci) {
  for (int i = 0; i < buf.calls_size(); i++) {
    const proto::CallInfo &info = buf.calls(i);
    StringRef name = info.name();
    CallInfo *res = new CallInfo();
    codeInto(info, *res);
    llvm::StringMap<std::vector<CallInfo *>>::iterator it =
        ci.m_calls.find(name);
    if (it == ci.m_calls.end()) {
      std::vector<CallInfo *> infos;
      infos.push_back(res);
      ci.m_calls[name] = infos;
    } else {
      it->second.push_back(res);
    }
  }
  for (std::string ref: buf.references()) {
    ci.m_references.insert(ref);
  }
}

bool ComponentInterface::readFromFile(const std::string &filename) {
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
  codeInto<proto::ComponentInterface, ComponentInterface>(buf, *this);
  input.close();
  return true;
}


void ComponentInterface::write(raw_ostream &o) const {
  o << "## External calls:\n";
  for (auto &kv: m_calls) {
    for (CallInfo *CI: kv.getValue()) {
      o << "\t" << kv.first() << "(";
      auto const& args = CI->get_args();
      for (unsigned i=0, sz=args.size(); i<sz; ) {
	o << args[i].to_string();
	++i;
	if (i < sz) {
	  o << ",";
	}
      }
      o << ")\n";
    }
  }
  o << "## External symbols:\n";
  for (const std::string &s: m_references) {
    o << "\t" << s << "\n";
  }
}

  
// CallRewrite
CallRewrite::CallRewrite(FunctionHandle h, const std::vector<unsigned> &a)
    : function(h), args(a) {}
CallRewrite::CallRewrite(const CallRewrite &x)
    : function(x.function), args(x.args) {}

template <>
void codeInto<proto::CallRewrite, CallRewrite>(const proto::CallRewrite &buf,
                                               CallRewrite &CR) {
  CR.function = StringRef(buf.new_function());
  std::vector<unsigned> *non_const =
      const_cast<std::vector<unsigned> *>(&CR.args);
  non_const->reserve((unsigned)buf.args_size());
  non_const->assign(buf.args().begin(), buf.args().end());
}

template <>
void codeInto<CallRewrite, proto::CallRewrite>(const CallRewrite &CR,
                                               proto::CallRewrite &buf) {
  buf.set_new_function(CR.function);
  buf.mutable_args()->Reserve(CR.args.size());
  for (unsigned i: CR.args) {
    buf.mutable_args()->AddAlreadyReserved(i);
  }
}

// ComponentInterfaceTransform
template <>
void codeInto<ComponentInterfaceTransform, proto::ComponentInterfaceTransform>(
    const ComponentInterfaceTransform &ci,
    proto::ComponentInterfaceTransform &buf) {
  for (auto fi: llvm::make_range(ci.interface->begin(), ci.interface->end())) {
    for (auto c: llvm::make_range(ci.interface->call_begin(fi),
				  ci.interface->call_end(fi))) {
      const CallRewrite *rw = ci.lookupRewrite(fi, c);
      if (rw != nullptr) {
        proto::CallRewrite *nrw = buf.add_calls();
        codeInto<CallRewrite, proto::CallRewrite>(*rw, *nrw);
        nrw->mutable_call()->set_name(fi);
        codeInto<CallInfo, proto::CallInfo>(*c, *nrw->mutable_call());
      }
    }
  }
}

template <>
void codeInto<proto::ComponentInterface, ComponentInterfaceTransform>(
    const proto::ComponentInterface &buf, ComponentInterfaceTransform &ci) {
  if (!ci.interface) {
    ci.interface = std::make_unique<ComponentInterface>();
  }
  codeInto<proto::ComponentInterface, ComponentInterface>(buf, *ci.interface);
}

template <>
void codeInto<proto::ComponentInterfaceTransform, ComponentInterfaceTransform>(
    const proto::ComponentInterfaceTransform &buf,
    ComponentInterfaceTransform &ci) {
  if (ci.interface == nullptr) {
    ci.interface = std::make_unique<ComponentInterface>();
  }
  assert(ci.interface != nullptr);

  for (int i = 0; i < buf.calls_size(); i++) {
    const proto::CallRewrite &rw = buf.calls(i);
    const proto::CallInfo &info = rw.call();
    StringRef name = info.name();
    CallInfo res;
    codeInto<proto::CallInfo, CallInfo>(info, res);
    CallInfo *result = ci.interface->getOrCreateCall(name, res.get_args());
    result->get_count() += info.count();

    CallRewrite rewrite;
    codeInto<proto::CallRewrite, CallRewrite>(rw, rewrite);
    ci.rewrite(name, result, rewrite);
  }
}

void ComponentInterfaceTransform::rewrite(
    FunctionHandle hndl, const CallInfo *const from, FunctionHandle to,
    const std::vector<unsigned> &to_args) {
  rewrite(hndl, from, CallRewrite(to, to_args));
}

void ComponentInterfaceTransform::rewrite(FunctionHandle hndl,
                                          const CallInfo *const from,
                                          const CallRewrite &to) {
  if (this->rewrites.find(hndl) == this->rewrites.end()) {
    this->rewrites[hndl] = std::map<const CallInfo *const, const CallRewrite>();
  }

  this->rewrites[hndl].insert(
      std::pair<const CallInfo *const, const CallRewrite>(from, to));
}

void ComponentInterfaceTransform::dump() const {
  for (auto &kv_fmap: rewrites) {
    for (auto &kv_cmap: kv_fmap.second) {
      errs() << "'" << kv_fmap.first << "' -> '" << kv_cmap.second.get_function()
	     << "'\n";      
    }
  }
}

const ComponentInterface &ComponentInterfaceTransform::getInterface() const {
  assert(hasInterface());
  return *interface;
}

unsigned ComponentInterfaceTransform::rewriteCount() const {
  unsigned result = 0;
  for (FMap::const_iterator i = this->rewrites.begin(),
                            e = this->rewrites.end();
       i != e; ++i)
    result += i->second.size();
  return result;
}

CallRewrite const *ComponentInterfaceTransform::lookupRewrite(
    FunctionHandle name, llvm::User::op_iterator op_begin,
    llvm::User::op_iterator op_end) const {
  
  assert(interface);
  const CallInfo *search = nullptr;
  int score = -1;


  for (CallInfo *CI: llvm::make_range(interface->call_begin(name.c_str()),
				     interface->call_end(name.c_str()))) {
    int tscore = CI->refines(op_begin, op_end);
    if (tscore > score) {
      score = tscore;
      search = CI;
    }
  }
    
  return (search ? this->lookupRewrite(name, search): nullptr);
}

const CallRewrite *
ComponentInterfaceTransform::lookupRewrite(FunctionHandle name,
                                           const CallInfo *const key) const {
  assert(key != nullptr);
  assert(interface != nullptr);
  FMap::iterator f = const_cast<FMap &>(this->rewrites).find(name);
  if (f == this->rewrites.end()) {
    return nullptr;
  }
  CMap::const_iterator c = f->second.find(key);
  if (c == f->second.end())
    return nullptr;

  return &(c->second);
}

bool ComponentInterfaceTransform::readInterfaceFromFile(
    const std::string &filename) {
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
  codeInto<proto::ComponentInterface, ComponentInterfaceTransform>(buf, *this);
  input.close();
  return true;
}

bool ComponentInterfaceTransform::readTransformFromFile(
    const std::string &filename) {
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
  codeInto<proto::ComponentInterfaceTransform, ComponentInterfaceTransform>(
      buf, *this);
  input.close();
  return true;
}
}
