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
//#include "llvm/IR/PassManager.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "PrevirtualizeInterfaces.h"

#include <vector>
#include <string>
#include <fstream>

using namespace llvm;

static cl::opt<std::string>
KeepExternalFile("Pkeep-external",
		 cl::desc("<file> : list of function names to be whitelisted"),
		 cl::init(""));

namespace previrt
{
  static inline GlobalValue::LinkageTypes
  localizeLinkage(GlobalValue::LinkageTypes l)
  {
    switch (l) {
    case GlobalValue::ExternalLinkage:
      return GlobalValue::InternalLinkage;
    case GlobalValue::ExternalWeakLinkage:
      return GlobalValue::WeakODRLinkage;
    case GlobalValue::AppendingLinkage:
      return GlobalValue::AppendingLinkage;
    case GlobalValue::CommonLinkage:
      // CommonLinkage is most similar to weak linkage
      // However, we mark it as internal linkage so that other
      // optimizations are applicable.
      //return GlobalValue::WeakODRLinkage;
      return GlobalValue::InternalLinkage;
    // TODO I'm not sure if all external definitions have an
    // appropriate internal counterpart
    default:
      errs() << "Got other linkage! " << l << "\n";
      return l;
    }
  }

  /*
   * Remove all code from the given module that is not necessary to
   * implement the given interface.
   */
  bool
  MinimizeComponent(Module& M, const ComponentInterface& I)
  {
    bool modified = false;
    int hidden = 0;
    int internalized = 0;

    /*
    errs() << "<interface>\n";
    I.dump();
    errs() << "</interface>\n";
    */

    std::set<std::string> keep_external;
    if (KeepExternalFile != "") {
      std::ifstream infile(KeepExternalFile);
      if (infile.is_open()) {
	std::string line;
	while (std::getline(infile, line)) {
      //errs() << "Adding " << line << " to the white list.\n";
	  keep_external.insert(line);
	}
	infile.close();
      } else {
	errs() << "Warning: ignored whitelist because something failed.\n";
      }
    }
    // Set all functions that are not in the interface to internal linkage only    
    for (auto &f: M) {
      if (keep_external.count(f.getName())) {
	errs() << "Did not internalize " << f.getName() << " because it is whitelisted.\n";
	continue;
      }
      if (!f.isDeclaration() && f.hasExternalLinkage() &&
          I.calls.find(f.getName()) == I.calls.end() &&
          I.references.find(f.getName()) == I.references.end()) {
	errs() << "Hiding '" << f.getName() << "'\n";
	f.setLinkage(GlobalValue::InternalLinkage);
	hidden++;
	modified = true;
      }
    }

    // Set all initialized global variables that are not referenced in
    // the interface to "localized linkage" only
    for (auto &gv: M.globals()) {
      if (gv.hasName() && keep_external.count(gv.getName())) {
	errs() << "Did not internalize " << gv.getName() << " because it is whitelisted.\n";
	continue;
      }
      if ((gv.hasExternalLinkage() || gv.hasCommonLinkage()) && 
	  gv.hasInitializer() &&
          I.references.find(gv.getName()) == I.references.end()) {
	errs() << "internalizing '" << gv.getName() << "'\n";	
        gv.setLinkage(localizeLinkage(gv.getLinkage()));
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
    legacy::PassManager cdeMgr;
    legacy::PassManager mcMgr;
    ModulePass* modulePassDCE = createGlobalDCEPass();
    cdeMgr.add(modulePassDCE);
    //mfMgr.add(createMergeFunctionsPass());

    ModulePass* constantMergePass = createConstantMergePass();

    mcMgr.add(constantMergePass);
    bool moreToDo = true;
    unsigned int iters = 0;
    while (moreToDo && iters < 10000) {
      moreToDo = false;
      if (cdeMgr.run(M)) moreToDo = true;
      // (originally commented) if (mfMgr.run(M)) moreToDo = true;
      if (mcMgr.run(M)) moreToDo = true;
      modified = modified || moreToDo;
      ++iters;
    }

    if (moreToDo) {
      if (cdeMgr.run(M))
	errs() << "GlobalDCE still had more to do\n";
      //if (mfMgr.run(M)) errs() << "MergeFunctions still had more to do\n";

      if (mcMgr.run(M))
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
