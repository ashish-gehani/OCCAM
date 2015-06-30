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
 * SpecializationTable.cpp
 *
 *  Created on: Jun 22, 2011
 *      Author: malecha
 */

#include "SpecializationTable.h"

#include "llvm/IR/Value.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Constants.h"
#include "llvm/Support/raw_ostream.h"

#include <string.h>

using namespace llvm;

namespace previrt
{
  typedef SpecializationTable::Specialization Specialization;

  bool
  Specialization::refines(int len, ConstSpecScheme l, ConstSpecScheme r)
  {
    for (int i = 0; i < len; i++) {
      if (r[i] == NULL)
        continue;
      if (r[i] == l[i])
        continue;
      return false;
    }
    return true;
  }

  bool
  Specialization::refinesExt(const SmallBitVector &wrt, ConstSpecScheme l,
      ConstSpecScheme r)
  {
    // wrt is the set of indicies included in r, e.g.
    // wrt = [1,0,1,0,0] means:
    //   args 0,1,3 are NOT included in r
    //   args 2,3 are included in r
    const int len = wrt.size();
    for (int lp = 0, rp = 0; lp < len; lp++) {
      if (wrt[lp]) {
        if (r[rp] == NULL || l[lp] == r[rp])
          rp++;
        else
          return false;
      }
    }
    return true;
  }

  SpecializationTable::SpecializationTable() :
    module(NULL)
  {
  }

  SpecializationTable::SpecializationTable(Module* m) :
      module(NULL)
  {
    this->initialize(m);
  }

  void
  SpecializationTable::initialize(Module* m)
  {
    assert(this->module == NULL);
    this->module = m;
#ifdef RECORD_IN_METADATA
    // Parse the module metadata to populate the table
    NamedMDNode* specs = m->getNamedMetadata("previrt::specializations");
    if (specs == NULL)
    return;

    errs() << "Specialization Count: " << specs->getNumOperands() << "\n";

    for (unsigned int i = 0; i < specs->getNumOperands(); ++i) {
      MDNode* funNode = specs->getOperand(i);
      if (funNode == NULL) {
        continue;
      }
      assert (funNode->getNumOperands() > 2);
      MDString* prinName = dyn_cast_or_null<MDString>(funNode->getOperand(0));
      MDString* specName = dyn_cast_or_null<MDString>(funNode->getOperand(1));
      if (prinName == NULL || specName == NULL) {
        errs() << "must skip " << (prinName == NULL ? "?" : prinName->getString()) << "\n";
        continue;
      }
      Function* prin = m->getFunction(prinName->getString());
      Function* spec = m->getFunction(specName->getString());
      if (prin == NULL || spec == NULL) {
        errs() << "must skip " << (prin == NULL ? "?" : prin->getName()) << "\n";
        continue;
      }

      const unsigned int arg_count = prin->getArgumentList().size();
      if (funNode->getNumOperands() != 2 + arg_count) {
        continue;
      }

      SpecScheme scheme = new Value*[arg_count];
      for (unsigned int i = 0; i < arg_count; i++) {
        Value* opr = funNode->getOperand(2 + i);
        if (opr == NULL) {
          scheme[i] = NULL;
        } else {
          assert (dyn_cast<Constant>(opr) != NULL);
          scheme[i] = opr;
        }
      }

      this->addSpecialization(prin, scheme, spec, false);
      errs() << "recording specialization of '" << prin->getName() << "' to '" << spec->getName() << "'\n";
    }
#endif /* RECORD_IN_METADATA */
  }

  SpecializationTable::~SpecializationTable()
  {
    for (SpecTable::iterator i = this->specialized.begin(), e =
        this->specialized.end(); i != e; ++i) {
      delete i->second;
    }
  }

#if 0
  static void
  collectRefinements(const Specialization* spec, SmallBitVector wrt,
      SpecializationTable::ConstSpecScheme scheme, std::vector<
      const Specialization*>& result)
  {
    assert (spec != NULL);
    if (Specialization::refinesExt(wrt, spec->args, scheme)) {
      result.push_back(spec);

      SmallBitVector wrt2 = wrt;
      for (int lp = 0, rp = 0; (unsigned) lp < wrt.size(); lp++) {
        if (!wrt[rp]) {
          rp++;
          continue;
        }
        if (spec->args[rp] != NULL) {
          wrt2.set(rp);
        }
      }

      for (std::vector<Specialization*>::const_iterator b =
          spec->children.begin(), e = spec->children.end(); b != e; ++b) {
        collectRefinements(*b, wrt2, scheme, result);
      }
    }
  }

  static inline void
  upSpecScheme(const Specialization* at, SpecializationTable::SpecScheme result)
  {
    const Specialization* up = at->parent;
    int to = up->handle->getArgumentList().size();
    int from = at->handle->getArgumentList().size();

    while (to != from) {
      assert (to >= 0 && from >= 0);
      if (up->args[to] == NULL) {
        result[to] = result[from];
        to--;
        from--;
      } else {
        result[to] = up->args[from];
        to--;
      }
    }
  }
#endif

  void
  SpecializationTable::getSpecializations(Function* f, ConstSpecScheme scheme,
      std::vector<const Specialization*>& result) const
  {
    const Specialization* current = this->getSpecialization(f);
    const int arg_count = f->getArgumentList().size();

    for (std::vector<Specialization*>::const_iterator i =
        current->children.begin(), e = current->children.end(); i != e; ++i) {
      if (Specialization::refines(arg_count, (*i)->args, scheme)) {
        result.push_back(*i);
      }
    }
  }

  bool
  SpecializationTable::addSpecialization(Function* parent,
      ConstSpecScheme scheme, Function* specialization, bool record)
  {
    assert(parent != NULL);
    assert(specialization != NULL);

    SpecTable::iterator cursor = this->specialized.find(specialization);
    //Specialization* spec = this->specialized.lookup(specialization->getName());
    if (cursor != this->specialized.end()) {
      return false;
    }

    Specialization* parentSpec = this->getSpecialization(parent);

    Specialization* spec = new Specialization();
    spec->handle = specialization;
    spec->parent = parentSpec;
    spec->args = scheme;
    this->specialized[specialization] = spec;

    //.GetOrCreateValue(specialization->getName(), spec);
    parentSpec->children.push_back(spec);

#if RECORD_IN_METADATA
    // Add the meta-data
    if (record) {
      NamedMDNode* md = this->module->getOrInsertNamedMetadata(
          "previrt::specializations");

      const unsigned int arg_count = parent->getArgumentList().size();
      Value** vals = new Value*[2 + arg_count];
      vals[0] = MDString::get(parent->getContext(), parent->getName());
      vals[1] = MDString::get(parent->getContext(), specialization->getName());
      for (unsigned int i = 0; i < parent->getArgumentList().size(); ++i) {
        vals[i+2] = scheme[i];
      }

      ArrayRef<Value*> ar_vals(vals, vals+2+arg_count);
      MDNode* nde = MDNode::get(this->module->getContext(), ar_vals);

      md->addOperand(nde);
    }
#endif /* RECORD_IN_METADATA */

    return true;
  }

  Specialization*
  SpecializationTable::getSpecialization(Function* f) const
  {
    SpecTable::const_iterator itr = this->specialized.find(f);
    if (itr == this->specialized.end()) {
      Specialization* spec = new Specialization();
      spec->args = NULL;
      spec->parent = NULL;
      spec->handle = f;
      const_cast<SpecializationTable*> (this)->specialized[f] = spec;
      return this->specialized[f];
    }
    return itr->second;
  }

  const Specialization*
  SpecializationTable::getPrincipalSpecialization(Function* f) const
  {
    const Specialization* spec = this->getSpecialization(f);
    while (spec->parent != NULL) {
      spec = spec->parent;
    }
    return spec;
  }
/*
 std::string
 SpecializationTable::specializationName(const Function*, SpecScheme) const
 {

 }
 */
}
