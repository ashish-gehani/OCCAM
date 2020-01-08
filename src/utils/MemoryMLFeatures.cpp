#include "utils/MemoryMLFeatures.h"

#include "llvm/Pass.h"
#include "llvm/ADT/Optional.h"
#include "llvm/Analysis/MemoryBuiltins.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/CommandLine.h"

#include "sea_dsa/Global.hh"
#include "sea_dsa/AllocWrapInfo.hh"
#include "sea_dsa/TopDown.hh"

static llvm::cl::opt<bool>
IncludeExpensiveFeatures("Pinclude-expensive-ml-features", 
			 llvm::cl::init(true),
			 llvm::cl::desc("Include expensive ML features"));

namespace previrt {

  using namespace llvm;
  using namespace sea_dsa;

  MLFeaturesCallSite::MLFeaturesCallSite():
    m_cs(nullptr),
    callee_nodes(0),
    callee_collapsed(0),
    callee_accessed(0),
    callee_sequence(0),
    callee_alloca(0),
    callee_heap(0),
    callee_external(0),
    callee_pointers(0),
    callee_alloc_sites(0),
    callee_mem_accesses(0),
    callee_safe_alloc_sites(0),    
    ////
    td_callee_nodes(0),
    td_callee_collapsed(0),
    td_callee_accessed(0),
    td_callee_sequence(0),
    td_callee_alloca(0),
    td_callee_heap(0),
    td_callee_external(0),    
    td_callee_pointers(0),
    td_callee_alloc_sites(0),
    td_callee_mem_accesses(0),
    td_callee_safe_alloc_sites(0) {}


  MLFeaturesCallSite::MLFeaturesCallSite(CallSite &CS):
    m_cs(CS.getInstruction()),
    callee_nodes(0),
    callee_collapsed(0),
    callee_accessed(0),
    callee_sequence(0),
    callee_alloca(0),
    callee_heap(0),
    callee_external(0),
    callee_pointers(0),
    callee_alloc_sites(0),
    callee_mem_accesses(0),
    callee_safe_alloc_sites(0),        
    ////
    td_callee_nodes(0),
    td_callee_collapsed(0),
    td_callee_accessed(0),
    td_callee_sequence(0),
    td_callee_alloca(0),
    td_callee_heap(0),
    td_callee_external(0),    
    td_callee_pointers(0),
    td_callee_alloc_sites(0),
    td_callee_mem_accesses(0),    
    td_callee_safe_alloc_sites(0) {}    
  
  void MLFeaturesCallSite::write(raw_ostream&o) const {
    if (m_cs) {
      o << "## ML features for " << *m_cs << "\n";
      o << "Callee's Summary graph \n";
      o << "  Number of nodes          : " << callee_nodes << "\n";
      o << "  Number of collapsed nodes: " << callee_collapsed << "\n";
      o << "  Number of accessed nodes : " << callee_accessed << "\n";
      o << "  Number of sequence nodes : " << callee_sequence << "\n";
      o << "  Number of alloca nodes   : " << callee_alloca << "\n";
      o << "  Number of heap nodes     : " << callee_heap << "\n";
      o << "  Number of external nodes : " << callee_external << "\n";            
      if (callee_nodes > 0) {
	o << "  Number of pointers per node: "
	  << callee_pointers / callee_nodes << "\n";
      }
      o << "  Number of allocation sites: " << callee_alloc_sites << "\n";
      if (callee_mem_accesses > 0) {
	o << "  Number of memory accesses: " << callee_mem_accesses << "\n";
	o << "  Number of safe allocation sites " << callee_safe_alloc_sites << "\n";
      }
      o << "Callee's graph after top-down unification\n";
      o << "  Number of nodes          : " << td_callee_nodes << "\n";
      o << "  Number of collapsed nodes: " << td_callee_collapsed << "\n";
      o << "  Number of accessed nodes : " << td_callee_accessed << "\n";
      o << "  Number of sequence nodes : " << td_callee_sequence << "\n";
      o << "  Number of alloca nodes   : " << td_callee_alloca << "\n";
      o << "  Number of heap nodes     : " << td_callee_heap << "\n";
      o << "  Number of external nodes : " << td_callee_external << "\n";            
      if (td_callee_nodes > 0) {
	o << "  Number of pointers per node: "
	  << td_callee_pointers / td_callee_nodes << "\n";
      }
      o << "  Number of allocation sites: " << td_callee_alloc_sites << "\n";
      if (td_callee_mem_accesses > 0) {
	o << "  Number of memory accesses: " << td_callee_mem_accesses << "\n";
	o << "  Number of safe allocation sites " << td_callee_safe_alloc_sites << "\n";
      }
    } 
  }
  
  class MemoryMLFeaturesPassImpl {

    // Needed to run sea-dsa
    Graph::SetFactory m_sf;
    const DataLayout &m_dl;
    const TargetLibraryInfo &m_tli;
    LLVMContext &m_ctx;
    const AllocWrapInfo &m_allocInfo;
    CallGraph &m_cg;
    
    // Bottom-up graph of the module
    std::unique_ptr<BottomUpGlobalAnalysis> m_bu_graphs;
    // Map each callsite to some features
    DenseMap<Instruction*, MLFeaturesCallSite> m_cs_features_map;

    // Begin stuff from SimpleMemoryCheck in SeaHorn
    bool isKnownAlloc(Value *Ptr) {
      if (isa<AllocaInst>(Ptr))
	return true;
      
      if (auto *CI = dyn_cast<CallInst>(Ptr))
	return isAllocationFn(CI, &m_tli);
      
      if (auto *GV = dyn_cast<GlobalVariable>(Ptr))
	return GV->hasInitializer();
      
      return false;
    }
    
    // Get the size of the allocation site for Ptr
    Optional<size_t> getAllocSize(Value *Ptr) {
      assert(Ptr);
      if (!isKnownAlloc(Ptr))
	return None;
      
      ObjectSizeOpts Opts;
      Opts.RoundToAlign = true;
      Opts.EvalMode = ObjectSizeOpts::Mode::Max;
      ObjectSizeOffsetVisitor OSOV(m_dl, &m_tli, m_ctx, Opts);
      auto OffsetAlign = OSOV.compute(Ptr);
      if (!OSOV.knownSize(OffsetAlign))
	return llvm::None;
      const int64_t I = OffsetAlign.first.getSExtValue();
      if (I >= 0) {
	return size_t(I);
      } else {
	return llvm::None;
      }
    }

    // An allocation site is interesting if there is an access to it
    // that might be unsafe.
    bool isInterestingAllocSite(Value *Ptr, int64_t LoadEnd, Value *Alloc) {
      assert(Ptr);
      assert(Alloc);

      if (LoadEnd <= 0) {
	// The allocation site has probably zero size.
	// We mark it as interesting
	return true;
      } else {
	Optional<size_t> AllocSize = getAllocSize(Alloc);
	return AllocSize && size_t(LoadEnd) > *AllocSize;
      }
    }

    // Get the allocation sites of a pointer using sea-dsa
    SmallVector<Value *, 8> getAllocSites(Graph &G, Value &V) {
      SmallVector<Value *, 8> Sites;
      if (G.hasCell(V)) {
	const Cell &C = G.getCell(V);
	auto const &AllocSites = C.getNode()->getAllocSites();
	for (const Value *AS: AllocSites) {
	  if (auto *GV = dyn_cast<const GlobalValue>(AS))
	    if (GV->isDeclaration())
	      continue;
	  Sites.push_back(const_cast<Value *>(AS));
	}
      }
      return Sites;
    }
    
    struct PtrOrigin { Value *Ptr; int64_t Offset; };
    
    PtrOrigin trackPtrOrigin(Value *Ptr) {
      assert(Ptr);

      PtrOrigin Res{Ptr, 0};
      unsigned Iter = 0;
      while (true) {
	++Iter;
	
	if (isKnownAlloc(Res.Ptr))
	  return Res;
	
	if (auto *BC = dyn_cast<BitCastInst>(Res.Ptr)) {
	  auto *Arg = BC->getOperand(0);
	  Res.Ptr = Arg;
	  continue;
	}
	
	if (auto *GEP = dyn_cast<GetElementPtrInst>(Res.Ptr)) {
	  auto *Arg = GEP->getPointerOperand();
	  APInt GEPOffset(m_dl.getPointerTypeSizeInBits(GEP->getType()), 0);
	  if (!GEP->accumulateConstantOffset(m_dl, GEPOffset))
	    return Res;
	  
	  Res.Ptr = Arg;
	  Res.Offset += GEPOffset.getSExtValue();
	  continue;
	}
	return Res;
      }
    }

    // For each memory access P we look at all its potential
    // allocation sites and count how many of them are safe to be
    // accessed.
    // 
    // A memory access cannot be considered access unless all its
    // allocation sites are safe to access.
    void getMemoryAccessesFeatures(Graph &G, Function &F,
				   unsigned &memory_accesses,
				   unsigned &safe_allocation_sites) {            
      for (auto &BB: F) {
	for (auto &I: BB) {
	  auto *LI = dyn_cast<LoadInst>(&I);
	  auto *SI = dyn_cast<StoreInst>(&I);
	  if (!LI && !SI) continue;
	  
	  Value *arg = LI ? LI->getPointerOperand() : SI->getPointerOperand();
	  PtrOrigin origin = trackPtrOrigin(arg);
	  if (!origin.Ptr) continue;
	  Type *Ty = LI ? LI->getType()
	    : SI->getPointerOperand()->getType()->getPointerElementType();
	  if (!Ty) continue;
	  const auto bits = m_dl.getTypeSizeInBits(Ty);
	  const uint32_t sz = bits < 8 ? 1 : bits / 8;
	  const int64_t lastRead = origin.Offset + sz;
	  ++memory_accesses;
	  for (Value *as : getAllocSites(G, *(origin.Ptr))) {
	    if (!isInterestingAllocSite(origin.Ptr, lastRead, as)) {
	      ++safe_allocation_sites;
	    }
	  }
	}
      }
    }
    // End stuff from SimpleMemoryCheck in SeaHorn
    
  public:
    
    MemoryMLFeaturesPassImpl(const DataLayout &dl,
			     const TargetLibraryInfo &tli,
			     LLVMContext &ctx,			     
			     const AllocWrapInfo &allocInfo,
			     CallGraph &cg)
      : m_dl(dl), m_tli(tli), m_ctx(ctx), m_allocInfo(allocInfo), m_cg(cg),
	m_bu_graphs(nullptr) {}

    /* Compute summary graphs for each function */
    void computeSummaryGraphs(Module &M) {
      m_bu_graphs.reset(new BottomUpGlobalAnalysis(m_dl, m_tli, m_allocInfo,
						   m_cg, m_sf));
      m_bu_graphs->runOnModule(M);
    }

    /** 
     * Return the callee graph after performing top-down unification.
     **/
    std::unique_ptr<Graph> getTopDownGraph(DsaCallSite &CS) {
      std::unique_ptr<Graph> g = nullptr;
      const Function *callee = CS.getCallee();
      const Function *caller = CS.getCaller();
      
      if (callee && caller &&
	  m_bu_graphs->hasGraph(*callee) && m_bu_graphs->hasGraph(*caller)) {

	Graph& calleeG = m_bu_graphs->getGraph(*callee);
	Graph& callerG = m_bu_graphs->getGraph(*caller);
	
	// make a copy of the callee's graph
	g.reset(new sea_dsa::Graph(m_dl, m_sf));
	g->import(calleeG, true /*with formals*/);

	// top-down unification 
	TopDownAnalysis::cloneAndResolveArguments(CS, callerG, *g);
	// remove foreign nodes
	g->removeNodes([](const Node *n) { return n->isForeign(); });	
      }
      return g;
    }

    /**
     * Return the summary graph of a function 
     **/
    Graph& getSummaryGraph(const Function &F) {
      return m_bu_graphs->getGraph(F);
    }

    MLFeaturesCallSite extractMLFeatures(CallSite &CS) {
      auto it = m_cs_features_map.find(CS.getInstruction());
      if (it != m_cs_features_map.end()) {
	return it->second;
      }
      
      DsaCallSite DsaCS(*CS.getInstruction());
      const Function *callee = DsaCS.getCallee();
      if (!callee)
	return MLFeaturesCallSite();
      
      std::unique_ptr<Graph> td_callee_graph = getTopDownGraph(DsaCS);
      if (!td_callee_graph)
	return MLFeaturesCallSite();
      
      Graph &callee_graph = getSummaryGraph(*callee);

      /// Extract features here
      MLFeaturesCallSite res(CS);
      /// -- before td-unification
      for (const Node& n: llvm::make_range(callee_graph.begin(), callee_graph.end())) {
	++res.callee_nodes;
	if (n.isOffsetCollapsed()) {
	  ++res.callee_collapsed;
	}
	if (n.isRead() || n.isModified()) {
	  ++res.callee_accessed;
	}
	if (n.isArray()) {
	  ++res.callee_sequence;
	}
	if (n.isAlloca()) {
	  ++res.callee_alloca;
	}
	if (n.isHeap()) {
	  ++res.callee_heap;
	}
	if (n.isExternal()) {
	  ++res.callee_external;
	}
      }
      res.callee_pointers =
	std::distance(callee_graph.scalar_begin(), callee_graph.scalar_end()) +
	std::distance(callee_graph.formal_begin(), callee_graph.formal_end()) +
	std::distance(callee_graph.return_begin(), callee_graph.return_end());
      res.callee_alloc_sites =
	std::distance(callee_graph.alloc_sites().begin(), callee_graph.alloc_sites().end());

      if (IncludeExpensiveFeatures) {
	getMemoryAccessesFeatures(callee_graph, *(const_cast<Function*>(callee)),
				  res.callee_mem_accesses,
				  res.callee_safe_alloc_sites);
      }
	
      /// -- after td-unification
      for (const Node& n: llvm::make_range(td_callee_graph->begin(),
					   td_callee_graph->end())) {
	++res.td_callee_nodes;
	if (n.isOffsetCollapsed()) {
	  ++res.td_callee_collapsed;
	}
	if (n.isRead() || n.isModified()) {
	  ++res.td_callee_accessed;
	}
	if (n.isArray()) {
	  ++res.td_callee_sequence;
	}
	if (n.isAlloca()) {
	  ++res.td_callee_alloca;
	}
	if (n.isHeap()) {
	  ++res.td_callee_heap;
	}
	if (n.isExternal()) {
	  ++res.td_callee_external;
	}	
      }
      res.td_callee_pointers =
	std::distance(td_callee_graph->scalar_begin(), td_callee_graph->scalar_end()) +
	std::distance(td_callee_graph->formal_begin(), td_callee_graph->formal_end()) +
	std::distance(td_callee_graph->return_begin(), td_callee_graph->return_end());
      res.td_callee_alloc_sites =
	std::distance(td_callee_graph->alloc_sites().begin(),
		      td_callee_graph->alloc_sites().end());

      if (IncludeExpensiveFeatures) {
	getMemoryAccessesFeatures(*td_callee_graph, *(const_cast<Function*>(callee)),
				  res.td_callee_mem_accesses,
				  res.td_callee_safe_alloc_sites);
      }
	
      m_cs_features_map.insert({CS.getInstruction(), res});
      return res;
    }
  
    
  };
  
  MemoryMLFeaturesPass::MemoryMLFeaturesPass()
    : ModulePass(ID), m_impl(nullptr) {}
  
  bool MemoryMLFeaturesPass::runOnModule(Module &M) {
    auto &dl = M.getDataLayout();
    auto &tli = getAnalysis<TargetLibraryInfoWrapperPass>().getTLI();
    auto &allocInfo = getAnalysis<AllocWrapInfo>();
    CallGraph *cg = nullptr;
    //if (UseDsaCallGraph) {  
    //cg = &getAnalysis<CompleteCallGraph>().getCompleteCallGraph();
    //} else {
    cg = &getAnalysis<CallGraphWrapperPass>().getCallGraph();
    //}

    m_impl.reset(new MemoryMLFeaturesPassImpl(dl, tli, M.getContext(), allocInfo, *cg));
    m_impl->computeSummaryGraphs(M);

    #if 1
    // For debugging
    for (auto &F : M) {
      for (auto &B: F) {
	for (auto &I: B) {
	  if (isa<CallInst>(I) || isa<InvokeInst>(I)) {
	    CallSite CS(&I);
	    auto features = extractMLFeatures(CS);
	    features.write(errs());
	  }
	}
      }
    }
    #endif 
    return false;
  }

  MLFeaturesCallSite MemoryMLFeaturesPass::extractMLFeatures(CallSite &CS) {
    return m_impl->extractMLFeatures(CS);
  }
  
  void MemoryMLFeaturesPass::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
    AU.addRequired<TargetLibraryInfoWrapperPass>();
    //if (UseDsaCallGraph) {
    //AU.addRequired<CompleteCallGraph>();
    //} else {
    AU.addRequired<CallGraphWrapperPass>();
    //}
    AU.addRequired<AllocWrapInfo>();
  }

  char MemoryMLFeaturesPass::ID;
} // end namespace 

static llvm::RegisterPass<previrt::MemoryMLFeaturesPass>
X("Pmem-ml-features", "Extract memory-related ML features", false, false);
