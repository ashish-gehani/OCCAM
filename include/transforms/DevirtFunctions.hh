#pragma once

/**  Program transformation to replace indirect calls with direct calls **/

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/InstVisitor.h"

#include <memory>
#include <map> // for multimap

namespace llvm {
class Module;
class Function;
class CallSite;
class PointerType;
class CallGraph;
} // namespace llvm

namespace seadsa {
class CompleteCallGraph;
} // namespace seadsa

namespace previrt {

namespace analysis {
  class ClassHierarchyAnalysis;
}

//#define USE_BOUNCE_FUNCTIONS
  
namespace transforms {

namespace devirt_impl {
using AliasSetId = const llvm::PointerType *;

/// returns an id of an alias set to which this function belongs
/// requires that CS is an indirect call through a function pointer
AliasSetId typeAliasId(const llvm::Function &F);

/// returns an id of an alias set of the called value
AliasSetId typeAliasId(llvm::CallSite &CS);
} // end namespace devirt_impl

enum CallSiteResolverKind {
   RESOLVER_TYPES
 , RESOLVER_SEADSA
 , RESOLVER_CHA   
};

/*
 * Generic class API for resolving indirect calls
 */
class CallSiteResolver {
protected:
  CallSiteResolverKind m_kind;
  CallSiteResolver(CallSiteResolverKind kind) : m_kind(kind) {}

public:
  using AliasSetId = devirt_impl::AliasSetId;  
  using AliasSet = llvm::SmallVector<const llvm::Function *, 16>;

  virtual ~CallSiteResolver() {}

  CallSiteResolverKind get_kind() const { return m_kind; }

  /* return all possible targets for CS */
  virtual const AliasSet* getTargets(llvm::CallSite &CS) = 0;

  #ifdef USE_BOUNCE_FUNCTIONS
  /* for reusing bounce functions */
  virtual llvm::Function* getBounceFunction(llvm::CallSite &CS) = 0;
  virtual void cacheBounceFunction(llvm::CallSite &CS, llvm::Function* bounce) = 0;
  #endif 
};

/*
 * Resolve an indirect call by selecting all functions defined in the
 * same module whose type signature matches with the callsite.
 */
class CallSiteResolverByTypes: public CallSiteResolver {
public:
  using AliasSetId = CallSiteResolver::AliasSetId;  
  using AliasSet = CallSiteResolver::AliasSet;
  
  CallSiteResolverByTypes(llvm::Module &M);

  virtual ~CallSiteResolverByTypes();

  const AliasSet* getTargets(llvm::CallSite& CS);

  #ifdef USE_BOUNCE_FUNCTIONS
  llvm::Function* getBounceFunction(llvm::CallSite& CS);
  void cacheBounceFunction(llvm::CallSite& CS, llvm::Function* bounce);
  #endif 
  
private:
  /* invariant: the value in TargetsMap's entries is sorted */
  using TargetsMap = llvm::DenseMap<AliasSetId, AliasSet>;
  #ifdef USE_BOUNCE_FUNCTIONS  
  using BounceMap = llvm::DenseMap<AliasSetId, llvm::Function *>;
  #endif
  
  // -- the module
  llvm::Module &m_M;
  // -- map from alias-id to the corresponding targets
  TargetsMap m_targets_map;
  #ifdef USE_BOUNCE_FUNCTIONS
  // -- map alias set id to an existing bounce function
  BounceMap m_bounce_map;
  #endif 
  
  void populateTypeAliasSets(void);
};

/*
 * Resolve indirect call by using seadsa
 */
class CallSiteResolverBySeaDsa final: public CallSiteResolverByTypes {
  /*
    Assume that seadsa::CompleteCallGraph provides these methods:
    - bool isComplete(CallSite&)
    - iterator begin(CallSite&)
    - iterator end(CallSite&) 
    where each element of iterator is of type Function*
  */
  
public:
  using AliasSetId = CallSiteResolverByTypes::AliasSetId;  
  using AliasSet = CallSiteResolverByTypes::AliasSet;
  
  CallSiteResolverBySeaDsa(llvm::Module& M,
			   seadsa::CompleteCallGraph& seadsa_cg,
			   bool allow_incomplete, unsigned max_num_targets);
    
  ~CallSiteResolverBySeaDsa() = default;
  
  const AliasSet* getTargets(llvm::CallSite &CS);

  #ifdef USE_BOUNCE_FUNCTIONS
  llvm::Function* getBounceFunction(llvm::CallSite& CS);  
  void cacheBounceFunction(llvm::CallSite&CS, llvm::Function* bounceFunction);
  #endif 
			   
private:
  /* invariant: the value in TargetsMap's entries is sorted */  
  using TargetsMap = llvm::DenseMap<llvm::Instruction*, AliasSet>;
  #ifdef USE_BOUNCE_FUNCTIONS
  using BounceMap = std::multimap<AliasSetId, std::pair<const AliasSet*, llvm::Function *>>;
  #endif 
  // -- the module
  llvm::Module& m_M;
  // -- call graph produced by seadsa
  seadsa::CompleteCallGraph& m_seadsa_cg;
  // -- Resolve incomplete nodes (unsound, in general)
  bool m_allow_incomplete;
  // -- Maximum number of targets . If equal to 0 then unlimited.
  unsigned m_max_num_targets;
  // -- map from callsite to the corresponding alias set
  TargetsMap m_targets_map;
  #ifdef USE_BOUNCE_FUNCTIONS
  // -- map from alias set id + dsa targets to an existing bounce function
  BounceMap m_bounce_map;
  #endif 
};


/*
 * Resolve indirect call by using Class Hierarchy Analysis for C++
 */
class CallSiteResolverByCHA final: public CallSiteResolverByTypes {
public:
  using AliasSetId = CallSiteResolverByTypes::AliasSetId;  
  using AliasSet = CallSiteResolverByTypes::AliasSet;
  
  CallSiteResolverByCHA(llvm::Module& M);
    
  ~CallSiteResolverByCHA();
  
  const AliasSet* getTargets(llvm::CallSite &CS);

  #ifdef USE_BOUNCE_FUNCTIONS
  llvm::Function* getBounceFunction(llvm::CallSite& CS);  
  void cacheBounceFunction(llvm::CallSite&CS, llvm::Function* bounceFunction);  
  #endif
  
private:
  /* invariant: the value in TargetsMap's entries is sorted */  
  using TargetsMap = llvm::DenseMap<llvm::Instruction*, AliasSet>;
  #ifdef USE_BOUNCE_FUNCTIONS  
  using BounceMap = std::multimap<AliasSetId, std::pair<const AliasSet*, llvm::Function *>>;
  #endif
  
  // -- the CHA 
  std::unique_ptr<analysis::ClassHierarchyAnalysis> m_cha;
  // -- map from callsite to the corresponding alias set
  TargetsMap m_targets_map;
  #ifdef USE_BOUNCE_FUNCTIONS
  // -- map from alias set id + cha targets to an existing bounce function
  BounceMap m_bounce_map;
  #endif 
};
  
//
// Class: DevirtualizeFunctions
//
//  This transform pass will look for indirect function calls and
//  transform them into a switch statement that selects one of
//  several direct function calls to execute. This transformation
//  pass is parametric on the method used to resolve the call.
//
class DevirtualizeFunctions : public llvm::InstVisitor<DevirtualizeFunctions> {

private:
  using AliasSet = CallSiteResolver::AliasSet;
  using AliasSetId = devirt_impl::AliasSetId;

  // Call graph of the program
  //llvm::CallGraph *m_cg;
  
  // Worklist of call sites to transform
  llvm::SmallVector<llvm::Instruction *, 32> m_worklist;

  /// turn the indirect call-site into multiple direct one
  void mkDirectCall(llvm::CallSite CS, CallSiteResolver *CSR);

  #ifdef USE_BOUNCE_FUNCTIONS
  /// create a bounce function that calls functions directly
  llvm::Function *mkBounceFn(llvm::CallSite &CS, CallSiteResolver *CSR);
  #endif 

public:
  DevirtualizeFunctions(llvm::CallGraph *cg);

  // Resolve all indirect calls in the Module using a particular
  // callsite resolver.
  bool resolveCallSites(llvm::Module &M, CallSiteResolver *CSR);

  // -- VISITOR IMPLEMENTATION --

  void visitCallSite(llvm::CallSite CS);
  void visitCallInst(llvm::CallInst &CI);
  void visitInvokeInst(llvm::InvokeInst &II);
};

} // namespace transform
} // namespace previrt

