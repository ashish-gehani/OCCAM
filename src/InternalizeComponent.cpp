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

#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Pass.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "PrevirtualizeInterfaces.h"

#include <vector>
#include <string>
#include <fstream>

using namespace llvm;

static cl::list<std::string>
InterfaceInput("Pinternalize-input",
	       cl::NotHidden,
	       cl::desc("specifies the interface to internalize with respect to"));

static cl::opt<std::string>
KeepExternalFile("Pkeep-external",
		 cl::desc("<file> : list of function names to be whitelisted"),
		 cl::init(""));

static cl::opt<unsigned>
FixpointTreshold("Pinternalize-fixpoint-threshold",
		 cl::desc("Limit of fixpoint iterations during global dead code elimination refinement"),
		 cl::init(5));

namespace previrt
{
  static inline GlobalValue::LinkageTypes
  localizeLinkage(GlobalValue::LinkageTypes l) {
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
      // XXX: not sure if all external definitions have an
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
  bool MinimizeComponent(Module& M, const ComponentInterface& I) {

    errs() << "InternalizePass::runOnModule: " << M.getModuleIdentifier() << "\n";
    
    bool modified = false;
    int hidden = 0;
    int internalized = 0;

    std::set<std::string> keep_external;
    if (KeepExternalFile != "") {
      std::ifstream infile(KeepExternalFile);
      if (infile.is_open()) {
	std::string line;
	while (std::getline(infile, line)) {
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

    if (!modified) {
      // We don't run DCE if we didn't modify any linkage
      return false;
    }
    
    // Perform global dead code elimination until fixpoint or
    // threshold is reached.
    legacy::PassManager dceMgr, mcMgr;
    ModulePass* modulePassDCE = createGlobalDCEPass();
    ModulePass* constantMergePass = createConstantMergePass();
    dceMgr.add(modulePassDCE);    
    mcMgr.add(constantMergePass);
    
    bool moreToDo = true;
    bool change_dce = false;
    bool change_mc = false;
    unsigned int iters = 0;
    
    while (moreToDo && iters < FixpointTreshold) {
      change_dce = dceMgr.run(M);
      change_mc = mcMgr.run(M);
      moreToDo = (change_dce || change_mc);
      ++iters;
    }

    if (change_dce) {
      errs() << "GlobalDCE still had more to do\n";
    }
    if (change_mc) {
      errs() << "MergeConstants still had more to do\n";
    }
    
    errs() << "Progress: hidden = " << hidden << " internalized " << internalized << "\n";
    return true;
  }

  
  class InternalizePass : public ModulePass {
  public:
    ComponentInterface interface;
    static char ID;
    
  public:
    
    InternalizePass(): ModulePass(ID) { 
      errs() << "InternalizePass()\n";
      for (cl::list<std::string>::const_iterator b =
	     InterfaceInput.begin(), e = InterfaceInput.end();
	   b != e; ++b) {
        errs() << "Reading file '" << *b << "'...";
        if (interface.readFromFile(*b)) {
          errs() << "success\n";
        } else {
          errs() << "failed\n";
        }
      }
      errs() << "Done reading.\n";
    }
    
    virtual ~InternalizePass() {}
    
    virtual bool runOnModule(Module& M) {
      return MinimizeComponent(M, interface);
    }
  };
  
  char InternalizePass::ID;
} // end namespace previrt


static RegisterPass<previrt::InternalizePass>
X("Pinternalize",
  "hide/eliminate all non-external dependencies",
  false, false);

