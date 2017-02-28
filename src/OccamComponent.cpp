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

#include "llvm/ADT/StringMap.h"
#include "llvm/IR/User.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Pass.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "PrevirtualizeInterfaces.h"

#include <vector>
#include <string>
#include <stdio.h>

using namespace llvm;

namespace previrt
{
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

  /*
   * Remove all code from the given module that is not necessary to
   * implement the given interface.
   */
  bool
  MinimizeComponent(Module& M, ComponentInterface& I)
  {
    bool modified = false;
    int hidden = 0;
    int internalized = 0;

    /*
    errs() << "<interface>\n";
    I.dump();
    errs() << "</interface>\n";
    */

    // Set all functions that are not in the interface to internal linkage only
    const StringMap<std::vector<CallInfo*> >::const_iterator end =
        I.calls.end();
    for (Module::iterator f = M.begin(), e = M.end(); f != e; ++f) {
      if (!f->isDeclaration() && f->hasExternalLinkage() &&
          I.calls.find(f->getName()) == end &&
          I.references.find(f->getName()) == I.references.end()) {
        errs() << "Hiding '" << f->getName() << "'\n";
        f->setLinkage(GlobalValue::InternalLinkage);
	hidden++;
        modified = true;
      }
    }

    // Set all initialized global variables that are not referenced in the interface to "localized linkage" only
    for (Module::global_iterator i = M.global_begin(), e = M.global_end(); i != e; ++i) {
      if (i->hasExternalLinkage() && i->hasInitializer() &&
          I.references.find(i->getName()) == I.references.end()) {
        errs() << "internalizing '" << i->getName() << "'\n";
        i->setLinkage(localizeLinkage(i->getLinkage()));
	internalized++;
        modified = true;
      }
    }
    /* TODO: We want to do this, but libc has some problems...
    for (Module::alias_iterator i = M.alias_begin(), e = M.alias_end(); i != e; ++i) {
      if (i->hasExternalLinkage() &&
          I.references.find(i->getName()) == I.references.end() &&
          I.calls.find(i->getName()) == end) {
        errs() << "internalizing '" << i->getName() << "'\n";
        i->setLinkage(localizeLinkage(i->getLinkage()));
        modified = true;
      }
    }
    */



    // Perform global dead code elimination
    // TODO: To what extent should we do this here, versus
    //       doing it elsewhere?
    PassManager<Module> cdeMgr;
    PassManager<Module>  mcMgr;
    cdeMgr.addPass(createGlobalDCEPass());
    //mfMgr.add(createMergeFunctionsPass());
    mcMgr.addPass(createConstantMergePass());
    bool moreToDo = true;
    unsigned int iters = 0;
    while (moreToDo && iters < 10000) {
      moreToDo = false;
      PreservedAnalyses cdePA = cdeMgr.run(M);
      if (cdePA<GlobalDCEPass>.preserve()) 
	moreToDo =true;
      //if (cdeMgr.run(M)) moreToDo = true;
      // (originally commented) if (mfMgr.run(M)) moreToDo = true;
      PreserveAnalyses mcPA = mcMgr.run(M);
      if (mcPA<ConstantMergePass>.preserve())
	moreTodo = true;
      //if (mcMgr.run(M)) moreToDo = true;
      modified = modified || moreToDo;
      ++iters;
    }

    if (moreToDo) {
      PreservedAnalyses cdePA = cdeMgr.run(M);
      if (cdePA<GlobalDCEPass>.preserve()) 
	errs() << "GlobalDCE still had more to do\n";

      //if (mfMgr.run(M)) errs() << "MergeFunctions still had more to do\n";

      PreserveAnalyses mcPA = mcMgr.run(M);
      if (mcPA<ConstantMergePass>.preserve())
	errs() << "MergeConstants still had more to do\n";
    }

    if (modified) {
      errs() << "Progress: hidden = " << hidden << " internalized " << internalized << "\n";
    }

    return modified;
  }

  static cl::list<std::string> OccamComponentInput(
      "Poccam-input", cl::NotHidden, cl::desc(
          "specifies the interface to prune with respect to"));
  class OccamPass : public ModulePass
  {
  public:
    ComponentInterface interface;
    static char ID;
  public:
    OccamPass() :
      ModulePass(ID)
    {

      errs() << "OccamPass()\n";

      for (cl::list<std::string>::const_iterator b =
          OccamComponentInput.begin(), e = OccamComponentInput.end(); b
          != e; ++b) {
        errs() << "Reading file '" << *b << "'...";
        if (interface.readFromFile(*b)) {
          errs() << "success\n";
        } else {
          errs() << "failed\n";
        }
      }
      errs() << "Done reading.\n";
    }
    virtual
    ~OccamPass()
    {
    }
  public:
    virtual bool
    runOnModule(Module& M)
    {
      errs() << "OccamPass::runOnModule: " << M.getModuleIdentifier() << "\n";
      return MinimizeComponent(M, this->interface);
    }
  };
  char OccamPass::ID;

  static RegisterPass<OccamPass> X("Poccam",
      "hide/eliminate all non-external dependencies", false, false);

}
