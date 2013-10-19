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
 * WeakenFunctions.cpp
 *
 *  Created on: Jun 23, 2011
 *      Author: Gregory Malecha
 */
#include "llvm/Function.h"
#include "llvm/Module.h"
#include "llvm/Pass.h"
#include "llvm/GlobalValue.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "PrevirtualizeInterfaces.h"

using namespace llvm;
using namespace previrt;

//=======================================================================
// DEAD CODE:
// This file has been replaced by "OccamComponent"
//=======================================================================

namespace {
  static cl::list<std::string> WeakenInterfaces("Pinternalize-input",
     cl::Hidden, cl::desc("the interfaces that we link against"));

  static inline GlobalValue::LinkageTypes
  localizeLinkage(GlobalValue::LinkageTypes l)
  {
    switch (l) {
    // TODO I'm not sure if all external definitions have an appropriate internal counterpart
    default:
      errs() << "Got other linkage! " << l << "\n";
      return l;
    case GlobalValue::ExternalLinkage:
      return GlobalValue::InternalLinkage;
    case GlobalValue::ExternalWeakLinkage:
      return GlobalValue::WeakODRLinkage;
    case GlobalValue::AppendingLinkage:
      return GlobalValue::AppendingLinkage;
    }
  }


  class WeakenInterfacesPass : public ModulePass
  {
  public:
    static char ID;
  public:
    WeakenInterfacesPass():ModulePass(ID) {}
    virtual ~WeakenInterfacesPass() {}
  public:
    virtual bool
    runOnModule(Module& M) {
      ComponentInterface spec;

      if (!WeakenInterfaces.empty()) {
        for (cl::list<std::string>::const_iterator i = WeakenInterfaces.begin(), e = WeakenInterfaces.end();
              i != e; ++i) {
          errs() << "Reading interface from '" << *i << "'...";
          if (spec.readFromFile(*i)) {
            errs() << "success\n";
          } else {
            errs() << "failed\n";
          }
        }
      }

      bool modified = false;

      for (Module::iterator i = M.begin(), e = M.end(); i != e; ++i) {
        if (i->hasExternalLinkage() &&
            spec.references.find(i->getName()) == spec.references.end()) {
          i->setLinkage(localizeLinkage(i->getLinkage()));
          modified = true;
        }
      }
      for (Module::global_iterator i = M.global_begin(), e = M.global_end(); i != e; ++i) {
        if (i->hasExternalLinkage() &&
            spec.references.find(i->getName()) == spec.references.end()) {
          i->setLinkage(localizeLinkage(i->getLinkage()));
          modified = true;
        }
      }

      return modified;
    }
  };

  char WeakenInterfacesPass::ID;

  static RegisterPass<WeakenInterfacesPass> X("Pinternalize",
        "internalize all globals not referenced in the interfaces", false,
        false);
}
