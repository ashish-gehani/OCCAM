//
// OCCAM
//
// Copyright (c) 2011-2018, SRI International
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
 *  Initial implementation created on: Jun 22, 2011
 *  Author: malecha
 */

#include "SpecializationTable.h"

#include "llvm/IR/Value.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Constants.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace previrt
{
  
  typedef SpecializationTable::Specialization Specialization;

  /* Return true if l refines r */
  bool Specialization::refines(SpecScheme l, SpecScheme r) {
    assert(l.size() == r.size());
    for (unsigned i = 0, e = l.size(); i < e; i++) {
      if (!r[i])
        continue;
      if (r[i] == l[i])
        continue;
      return false;
    }
    return true;
  }

  SpecializationTable::SpecializationTable()
    : module(NULL) {}

  SpecializationTable::SpecializationTable(Module* m)
    : module(NULL) {
    this->initialize(m);
  }

  void SpecializationTable::initialize(Module* m) {
    // XXX: RECORD_IN_METADATA seems an old option.
    //      TODO: figure out if we can remove this code.
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
      
      SpecScheme scheme;
      scheme.reserve(arg_count);
      for (unsigned int i = 0; i < arg_count; i++) {
        Value* opr = funNode->getOperand(2 + i);
        if (opr == NULL) {
          scheme.push_back(nullptr);
        } else {
          assert (dyn_cast<Constant>(opr) != NULL);
          scheme.push_pack(opr);
        }
      }

      this->addSpecialization(prin, scheme, spec, false);
      errs() << "recording specialization of '" << prin->getName() << "' to '" << spec->getName() << "'\n";
    }
#endif /* RECORD_IN_METADATA */
  }

  SpecializationTable::~SpecializationTable() {
    for (SpecTable::iterator i = this->specialized.begin(), e =
	   this->specialized.end(); i != e; ++i) {
      delete i->second;
    }
  }


  void SpecializationTable::getSpecializations(Function* f, SpecScheme scheme,
					       std::vector<const Specialization*>& result) const
  {
    const Specialization* current = this->getSpecialization(f);
    for (std::vector<Specialization*>::const_iterator i =
        current->children.begin(), e = current->children.end(); i != e; ++i) {
      if (Specialization::refines((*i)->args, scheme)) {
        result.push_back(*i);
      }
    }
  }

  bool SpecializationTable::addSpecialization(Function* parent, SpecScheme scheme,
					      Function* specialization, bool record) {
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
    std::copy(scheme.begin(), scheme.end(), std::back_inserter(spec->args));
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

  Specialization* SpecializationTable::getSpecialization(Function* f) const {
    SpecTable::const_iterator itr = this->specialized.find(f);
    if (itr == this->specialized.end()) {
      Specialization* spec = new Specialization();
      spec->parent = NULL;
      spec->handle = f;
      const_cast<SpecializationTable*> (this)->specialized[f] = spec;
      return this->specialized[f];
    }
    return itr->second;
  }

  const Specialization* SpecializationTable::getPrincipalSpecialization(Function* f) const {
    const Specialization* spec = this->getSpecialization(f);
    while (spec->parent != NULL) {
      spec = spec->parent;
    }
    return spec;
  }
}
