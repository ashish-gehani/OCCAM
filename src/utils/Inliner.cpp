#include "utils/Inliner.h"

#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/LinkAllPasses.h" //createAlwaysInlinerLegacyPass
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/Attributes.h"

#include <set>

namespace previrt {
namespace utils {

  using namespace llvm;
  
  bool inlineOnly(Module& M, const SmallPtrSet<Function*, 8>& inline_functions) {
    bool change = false;
    std::set<Function*> modified_functions;
    
    for (auto &F: M) {
      if ((inline_functions.count(&F) > 0) && !F.isDeclaration()) {
	change = true;
	F.setLinkage(GlobalValue::PrivateLinkage);
	F.removeFnAttr(Attribute::NoInline);
	F.removeFnAttr(Attribute::OptimizeNone);
	F.addFnAttr(Attribute::AlwaysInline);
      } else if (F.hasAttribute(AttributeList::FunctionIndex,
				Attribute::AlwaysInline)) {
	// we make sure that F won't be inlined even if it has a
	// always-inline attribute.
	F.removeFnAttr(Attribute::AlwaysInline);
	F.addFnAttr(Attribute::NoInline);
	modified_functions.insert(&F);
      }
    }

    if (change) {
      legacy::PassManager mgr;
      mgr.add(createAlwaysInlinerLegacyPass());
      mgr.run(M);
    }

    // restore attributes for non-inlined functions
    for (Function* F: modified_functions) {
      F->removeFnAttr(Attribute::NoInline);
      F->addFnAttr(Attribute::AlwaysInline);
    }
    
    return change;
  }
}
}
