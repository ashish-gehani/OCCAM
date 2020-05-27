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

#include "llvm/ADT/SmallSet.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Constants.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Pass.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "Interfaces.h"

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

namespace previrt {

static Value *stripBitCastCE(Constant *C) {
  if (ConstantExpr *CE = dyn_cast<ConstantExpr>(C)) {
    if (CE->getOpcode() == AddrSpaceCastInst::BitCast) {
      return CE->getOperand(0);
    }
  } 
  return C;
}

// static GlobalValue::LinkageTypes
// localizeLinkage(GlobalValue::LinkageTypes l) {
//   switch (l) {
//   case GlobalValue::ExternalLinkage:
//     return GlobalValue::InternalLinkage;
//   case GlobalValue::ExternalWeakLinkage:
//     return GlobalValue::WeakODRLinkage;
//   case GlobalValue::AppendingLinkage:
//     return GlobalValue::AppendingLinkage;
//   case GlobalValue::CommonLinkage:
//     // CommonLinkage is most similar to weak linkage
//     // However, we mark it as internal linkage so that other
//     // optimizations are applicable.
//     //return GlobalValue::WeakODRLinkage;
//     return GlobalValue::InternalLinkage;
//     // XXX: not sure if all external definitions have an
//   // appropriate internal counterpart
//   default:
//     errs() << "Got other linkage! " << l << "\n";
//     return l;
//   }
// }

// Whether the definition of a symbol can be discarded if it is not
// used in *other* compilation units.
static bool isDiscardableIfUnusedExternally(GlobalValue::LinkageTypes Linkage) {
  ////
  // LinkageTypes are defined in IR/GlobalValue.h
  ////
  // If Linkage is one of this {LinkOnceAnyLinkage,
  // LinkOnceODRLinkage, InternalLinkage, PrivateLinkage,
  // AvailableExternallyLinkage} then GlobalDCE will remove the
  // global value if unused in its compilation unit. Thus, we don't
  // need to consider those linkage types here.
  //
  // WeakAnyLinkage, WeakODRLinkage, and CommonLinkage are variants
  // of a weak semantics.
  //
  // AppendingLinkage applies only to global variables of pointer to
  // array type: when two global variables are linked together, the
  // two global arrays are appended together (e.g., @llvm.used)
  //
  return (Linkage == GlobalValue::ExternalLinkage ||
	  // All of these linkage types are variants of the weak
	  // semantics.
	  // 
	  // JORGE: We assume that if the symbol is dead then we can
	  // discard it regardless of its complex weak semantics.
	  Linkage == GlobalValue::ExternalWeakLinkage ||
	  Linkage == GlobalValue::WeakAnyLinkage ||
	  Linkage == GlobalValue::WeakODRLinkage ||
	  Linkage == GlobalValue::CommonLinkage);
}

// The linkage of GV is set to internal but only if its visibility is
// default.
//  
// If GV's visibility is hidden then making GV's linkage internal
// would set automatically its visibility to default. This can be a
// problem for the linker because a symbol that was hidden before it's
// now exposed. This might create duplicate symbols. The other
// visibility type is protected. For now, we also give up if
// visibility is protected.
static bool setInternalLinkage(GlobalValue &GV) {
  if (GV.hasDefaultVisibility()) {
    errs() << "Internalizing '" << GV.getName() << "'\n";  
    GV.setLinkage(GlobalValue::InternalLinkage);
    return true;
  } else {
    return false;
  }
}

/*
 * Remove all code from the given module that is not necessary to
 * implement the given interface.
 */
bool MinimizeComponent(Module& M, const ComponentInterface& I) {
  
  errs() << "InternalizePass::runOnModule: " << M.getModuleIdentifier() << "\n";
  
  bool modified = false;
  // for stats
  int internalized_functions = 0;
  int internalized_globals = 0;
  
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

  // If we cannot internalize an alias we shouldn't either its
  // aliasee.
  SmallSet<Value*, 16> keepAliasees;
  std::vector<GlobalAlias*> unusedAliases;    
  for (auto &alias: M.aliases()) {
    if (alias.hasName() && keep_external.count(alias.getName())) {
      errs() << "Did not internalize " << alias.getName()
	     << " because it is whitelisted.\n";
      // If this alias cannot be remove make sure its aliasee is not
      // removed either.
      keepAliasees.insert(stripBitCastCE(alias.getAliasee()));	
      continue;
    }
    
    if (I.references.find(alias.getName()) == I.references.end() && alias.use_empty()) {
      errs() << "Remove unused alias " << alias.getName() << "\n";
      unusedAliases.push_back(&alias);
    } else {
      // If this alias cannot be remove make sure its aliasee is not
      // removed either.
      // 
      // Important to remove bitcast to calls
      Value* aliaseeV = stripBitCastCE(alias.getAliasee());
      errs() << "Alias " << alias.getName() << " to be kept and so its aliasee "
	     << aliaseeV->getName() << "\n";
      keepAliasees.insert(aliaseeV);
    }
  }
  
  // Set all functions that are not in the interface to internal linkage only    
  for (auto &f: M) {
    if (f.hasName() && keep_external.count(f.getName())) {
      errs() << "Did not internalize " << f.getName()
	     << " because it is whitelisted.\n";
      continue;
    }
    
    if (// f has a body
	!f.isDeclaration() &&
	// f is discardable if unused in other compilation units
	isDiscardableIfUnusedExternally(f.getLinkage()) && 
	// unused in other compilation units
	I.calls.find(f.getName()) == I.calls.end() &&
	I.references.find(f.getName()) == I.references.end() &&
	// there is no an alias to f that we want to keep
	!keepAliasees.count(&f)) {

      if (setInternalLinkage(f)) {
	internalized_functions++;
	modified = true;
      }
    }
  }
  
  // Set all initialized global variables that are not referenced in
  // the interface to "localized linkage" only
  for (auto &gv: M.globals()) {
    if (gv.hasName() && keep_external.count(gv.getName())) {
      errs() << "Did not internalize " << gv.getName()
	     << " because it is whitelisted.\n";
      continue;
    }
    
    // JORGE: This was the original code. Not clear why it needs to
    // call localizeLinkage instead of just making the global
    // internal. Also, only external and common linkage were
    // covered. Not clear why only those two types.
    // 
    // if ((gv.hasExternalLinkage() || gv.hasCommonLinkage()) && 
    // 	  gv.hasInitializer() &&
    //     I.references.find(gv.getName()) == I.references.end()) {
    // 	errs() << "Internalizing '" << gv.getName() << "'\n";	
    //   gv.setLinkage(localizeLinkage(gv.getLinkage()));
    // 	internalized_globals++;
    //   modified = true;
      // }
    
    if (gv.hasInitializer() &&
	// global is unused
	I.references.find(gv.getName()) == I.references.end() && 
	isDiscardableIfUnusedExternally(gv.getLinkage()) &&
	// there is no an alias to f that we want to keep
	!keepAliasees.count(&gv)) {
      
      if (setInternalLinkage(gv)) {
	internalized_globals++;
        modified = true;
      }
    }      
  }
  
  // GlobalDCE does not remove a function if it has an alias.
  // We remove an alias if it is not referenced in other modules and
    // it has no uses within this module
  while (!unusedAliases.empty()) {
    modified = true;
    GlobalAlias *alias = unusedAliases.back();
    unusedAliases.pop_back();
    errs() << "Removing alias " << alias->getName() << " before calling DCE\n";
    alias->eraseFromParent();
  }
  
  if (!modified) {
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
  
  errs() << "Progress:"
	 << " internalized functions = " << internalized_functions
	 << " internalized globals = " << internalized_globals << "\n";
  return true;
}


class InternalizePass : public ModulePass {
public:
  ComponentInterface interface;
  static char ID;
  
public:
  
  InternalizePass(): ModulePass(ID) { 
    errs() << "InternalizePass()\n";
    for (std::string input: InterfaceInput) {
      errs() << "Reading file '" << input << "'...";
      if (interface.readFromFile(input)) {
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

