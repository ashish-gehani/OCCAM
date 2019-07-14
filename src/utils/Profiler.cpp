#include "utils/Profiler.h"

#include "llvm/Pass.h"
#include "llvm/Analysis/Passes.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/MemoryBuiltins.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DebugLoc.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/CommandLine.h"

using namespace llvm;

static llvm::cl::opt<std::string>
OutputFile("profile-outfile",
	llvm::cl::desc("Dump all counters to output filename"),
	llvm::cl::init(""));

static llvm::cl::opt<bool>
ShowCallGraphInfo("profile-callgraph",
        llvm::cl::desc("Show call graph information"),
        llvm::cl::init(false));

static llvm::cl::opt<bool>
PrintDetails("profile-details",
        llvm::cl::desc("Show more detailed statistics"),
        llvm::cl::init(false));

static llvm::cl::opt<bool>
DisplayDeclarations("profile-list-declarations",
        llvm::cl::desc("List all the function declarations"),
	llvm::cl::init(false),
	llvm::cl::Hidden);

static llvm::cl::opt<bool>
ProfileLoops("profile-loops",
        llvm::cl::desc("Show some stats about loops"),
        llvm::cl::init(false));

static llvm::cl::opt<bool>
ProfileSafePointers("profile-safe-pointers",
        llvm::cl::desc("Show whether a pointer access is statically safe or not"),
	llvm::cl::init(false));

static llvm::cl::opt<bool>
ProfileVerbose("profile-verbose",
        llvm::cl::desc("Print some verbose information"),
        llvm::cl::init(false));

namespace previrt {

  void ProfilerPass::formatCounters(std::vector<Counter>& counters, 
				    unsigned& MaxNameLen, unsigned& MaxValLen, bool sort) {
    // Figure out how long the biggest Value and Name fields are.
    for (auto c: counters) {
      MaxValLen  = std::max(MaxValLen,  (unsigned)utostr(c.getValue()).size());
      MaxNameLen = std::max(MaxNameLen, (unsigned)c.getName().size());
    }
    
    if (sort) {
      // Sort the fields by name.
      std::stable_sort(counters.begin(), counters.end());
    }
  }
  
  void ProfilerPass::incrInstCounter(std::string name, unsigned val) {
    auto it = instCounters.find(name);
    if (it != instCounters.end()) {
      it->second += val;
    } else {
      instCounters.insert({name, Counter(name)});
    }
  }
  
  /* Trivial checker for memory safety */
  bool ProfilerPass::isSafeMemAccess(Value *V) {
    ObjectSizeOpts opt;      
    ObjectSizeOffsetVisitor OSOV(*DL, TLI, *Ctx, opt);
    // res.first is size and res.second is offset
    SizeOffsetType res = OSOV.compute(V);
    if (OSOV.bothKnown(res)) {
      // FIXME: need to add getPointerTypeSizeInBits to offset
      return(res.second.isNonNegative() && res.second.ult(res.first));
    }
    return false;
  }
  
  void ProfilerPass::processPtrOperand(Value* V) {
    if (ProfileSafePointers && isSafeMemAccess(V)) {
      ++SafeMemAccess;
    } else {
      ++MemUnknown;
    }
  }
  
  void ProfilerPass::processMemoryIntrinsicsPtrOperand(Value* V, Value*N) {
    if (ProfileSafePointers) {
      if (ConstantInt *CI = dyn_cast<ConstantInt>(N)) {
	int64_t n = CI->getSExtValue();
	uint64_t size;
	ObjectSizeOpts opt;      
	if (getObjectSize(V, size, *DL, TLI, opt)) {
	  if (n >= 0 && ((uint64_t) n < size)) {
	    ++SafeMemAccess;
	    return;
	  }
	}
      }
    }
    ++MemUnknown;              
  }

  void ProfilerPass::visitFunction(Function &F) {
    if (F.isDeclaration()) {
      return;
    }
    ++TotalFuncs;
    
    if (F.getName().startswith("__occam_spec")) {
      ++TotalSpecFuncs;
    }
      
    if (ProfileVerbose) {
      errs() << "Function " << F.getName() << "\n";
    }
    
    if (ProfileLoops) {
      LoopInfo& LI = getAnalysis<LoopInfoWrapperPass>(F).getLoopInfo();
      ScalarEvolution& SE = getAnalysis<ScalarEvolutionWrapperPass>(F).getSE();      
      for (auto L: LI) {
	++TotalLoops;
	if (SE.getSmallConstantTripCount(L)) {
	  ++TotalBoundedLoops;
	}
      }
    }
  }
  
  void ProfilerPass::visitBasicBlock(BasicBlock &BB) { 
    ++TotalBlocks; 
    if (!BB.getSinglePredecessor()) {
      ++TotalJoins;
    }
  }
  
  void ProfilerPass::visitCallSite(CallSite CS) {
    ++TotalInsts;
    // TODO: incrInstCounter(#OPCODE, 1);         
    Function* callee = CS.getCalledFunction();
    if (callee) {
      ++TotalDirectCalls;
      if (callee->isDeclaration()) {
	++TotalExternalCalls;
	ExtFuncs.insert(callee->getName());
      }
    } else {
      ++TotalIndirectCalls;
      if (ProfileVerbose) {
	llvm::errs() << "Indirect call found: " << *CS.getInstruction() << "\n";
      }
    }
    
    // new, malloc, calloc, realloc, and strdup.
    if (isAllocationFn(CS.getInstruction(), TLI, true)) {
      ++TotalAllocations;
    }
  }
  
  void ProfilerPass::visitBinaryOperator(BinaryOperator &BI) {
    ++TotalInsts;
    // TODO: incrInstCounter(#OPCODE, 1);     
    if (BI.getOpcode() == BinaryOperator::SDiv || 
	BI.getOpcode() == BinaryOperator::UDiv ||
	BI.getOpcode() == BinaryOperator::SRem ||
	BI.getOpcode() == BinaryOperator::URem ||
	BI.getOpcode() == BinaryOperator::FDiv || 
	BI.getOpcode() == BinaryOperator::FRem) {
      const Value* divisor = BI.getOperand(1);
      if (const ConstantInt *CI = dyn_cast<const ConstantInt>(divisor)) {
	if (CI->isZero()) ++UnsafeIntDiv;
	else ++SafeIntDiv;
      } else if (const ConstantFP *CFP = dyn_cast<const ConstantFP>(divisor)) {
	if (CFP->isZero()) {
	  ++UnsafeFPDiv;
	} else {
	  ++SafeFPDiv;
	}
      } else {
	// cannot figure out statically
	if (BI.getOpcode() == BinaryOperator::SDiv ||
	    BI.getOpcode() == BinaryOperator::UDiv ||
	    BI.getOpcode() == BinaryOperator::SRem ||
	    BI.getOpcode() == BinaryOperator::URem) {
	  ++DivIntUnknown;
	} else {
	  ++DivFPUnknown;
	}
      }
    } else if (BI.getOpcode() == BinaryOperator::Shl) {
      // Check for oversized shift amounts
      if (const ConstantInt *CI = dyn_cast<const ConstantInt>(BI.getOperand(1))) {
	APInt shift = CI->getValue();
	if (CI->getType()->isIntegerTy()) {
	  APInt bitwidth(shift.getBitWidth(), CI->getType()->getIntegerBitWidth(), true);
	  if (shift.slt(bitwidth)) {
	    ++SafeLeftShift;
	  } else {
	    ++UnsafeLeftShift;
	  }
	} else {
	  ++UnknownLeftShift;
	}
      } else {
	++UnknownLeftShift;
      }
    }
  }

  void ProfilerPass::visitMemTransferInst(MemTransferInst &I) {
    ++TotalInsts;                                          
    ++TotalMemInst;                                            
    ++TotalMemInst;                                            
    if (isa<MemCpyInst>(&I)) ++MemCpy;                       
    else if (isa<MemMoveInst>(&I)) ++MemMove;                
    processMemoryIntrinsicsPtrOperand(I.getSource(), I.getLength()); 
    processMemoryIntrinsicsPtrOperand(I.getDest(), I.getLength()); 
  }

  void ProfilerPass::visitMemSetInst(MemSetInst &I) {
    ++TotalInsts;
    ++TotalMemInst;                                            
    ++MemSet;
    processMemoryIntrinsicsPtrOperand(I.getDest(), I.getLength()); 
  }

  void ProfilerPass::visitAllocaInst(AllocaInst &I) {
    ++TotalInsts;
    incrInstCounter("Alloca", 1);            
  }
    
  void ProfilerPass::visitLoadInst(LoadInst &I) {
    ++TotalInsts;    
    ++TotalMemInst;
    incrInstCounter("Load", 1);        
    processPtrOperand(I.getPointerOperand());		    
  }

  void ProfilerPass::visitStoreInst(StoreInst &I) {
    ++TotalInsts;    
    ++TotalMemInst;
    incrInstCounter("Store", 1);    
    processPtrOperand(I.getPointerOperand());		    
  }

  void ProfilerPass::visitGetElementPtrInst(GetElementPtrInst &I) {
    ++TotalInsts;
    incrInstCounter("GetElementPtr", 1);
    if (I.isInBounds()) {
      ++InBoundGEP;
    }
  }
  
  void ProfilerPass::visitInstruction(Instruction &I) {			    
    // TODO: incrInstCounter(#OPCODE, 1);                          
    ++TotalInsts;
  }

  ProfilerPass::ProfilerPass()
    : ModulePass(ID)
    , DL(nullptr)
    , TLI(nullptr)
    , TotalFuncs("TotalFuncs", "Number of functions")
    , TotalSpecFuncs("TotalSpecFuncs", "Number of specialized functions") 	
    , TotalBlocks("TotalBlocks", "Number of basic blocks")
    , TotalJoins("TotalJoins","Number of basic blocks with more than one predecessor")
    , TotalInsts("TotalInsts","Number of instructions")
    , TotalDirectCalls("TotalDirectCalls","Number of direct calls")
    , TotalIndirectCalls("TotalIndirectCalls","Number of indirect calls")
    , TotalExternalCalls("TotalExternalCalls","Number of external calls")
    , TotalLoops("TotalLoops", "Number of loops")
    , TotalBoundedLoops("TotalBoundedLoops", "Number of bounded loops")
    ////////
    , SafeIntDiv("SafeIntDiv","Number of safe integer div/rem")
    , SafeFPDiv("SafeFPDiv","Number of safe FP div/rem")
    , UnsafeIntDiv("UnsafeIntDiv","Number of definite unsafe integer div/rem")
    , UnsafeFPDiv("UnsafeFPDiv","Number of definite unsafe FP div/rem")
    , DivIntUnknown("DivIntUnknown","Number of unknown integer div/rem")
    , DivFPUnknown("DivFPUnknown","Number of unknown FP div/rem")
    /////////
    , TotalMemInst("TotalMemInst","Number of memory instructions")
    , MemUnknown("MemUnknown","Statically unknown memory accesses")
    , SafeMemAccess("SafeMemAccess","Statically safe memory accesses")
    , TotalAllocations("TotalAllocations","Malloc-like allocations")
    , InBoundGEP("InBoundGEP","Inbound GetElementPtr")
    , MemCpy("MemCpy")
    , MemMove("MemMove")
    , MemSet("MemSet")
    /////////
    , SafeLeftShift("SafeLeftShift","Number of safe left shifts")
    , UnsafeLeftShift("UnsafeLeftShift", "Number of definite unsafe left shifts")
    , UnknownLeftShift("UnknownLeftShift", "Number of unknown left shifts") {
  }
  
  // Collect statistics
  bool ProfilerPass::runOnFunction(Function &F)  {
    visit(F);
    return false;
  }
  
  bool ProfilerPass::runOnModule(Module &M) {
    
    DL = &M.getDataLayout();
    TLI = &getAnalysis<TargetLibraryInfoWrapperPass>().getTLI();
    Ctx = &M.getContext();
    
    if (ShowCallGraphInfo) {
      /// Look at the callgraph 
      // CallGraphWrapperPass *cgwp = &getAnalysis<CallGraphWrapperPass>();
      // if (cgwp) {
      //   cgwp->print(errs(), &M);
      // }
      CallGraph &CG = getAnalysis<CallGraphWrapperPass>().getCallGraph();
      typedef std::pair <Function*, std::pair <unsigned, unsigned> > func_ty;
      std::vector<func_ty> funcs;
      errs() << "[Call graph information]\n";
      errs() << "Total number of functions="
	     << std::distance(M.begin(), M.end()) << "\n";
      for (auto it = scc_begin(&CG); !it.isAtEnd(); ++it) {
	auto &scc = *it;
	for (CallGraphNode *cgn : scc) {
	  if (cgn->getFunction() && !cgn->getFunction()->isDeclaration()) {
	    funcs.push_back(
	      {cgn->getFunction(),
	        {cgn->getNumReferences(), std::distance(cgn->begin(), cgn->end())}}); 
	  }
	}
      }
        
      bool has_rec_func = false;
      for (auto it = scc_begin(&CG); !it.isAtEnd(); ++it) {
	auto &scc = *it;
	if (std::distance(scc.begin(), scc.end()) > 1) {
	  has_rec_func = true;
	  errs() << "Found recursive SCC={";
	  for (CallGraphNode *cgn : scc) {
	    if (cgn->getFunction())
                errs () << cgn->getFunction()->getName() << ";";
	  }
	}
      }
      
      if (!has_rec_func) {
	errs() << "No recursive functions found\n";
      }
        
      std::sort(funcs.begin(), funcs.end(), 
		[](func_ty p1, func_ty p2) { 
		  return  (p1.second.first + p1.second.second) > 
		    (p2.second.first + p2.second.second);
		});
      
      for(auto&p: funcs){
	Function* F = p.first;
	unsigned numInsts = std::distance(inst_begin(F), inst_end(F));
	errs() << F->getName() << ":" 
	       << " num of instructions=" << numInsts
	       << " num of callers=" << p.second.first 
	       << " num of callees=" << p.second.second << "\n";
      }           
    }
    
    for (auto &F: M) { runOnFunction(F); }
    
    if (OutputFile != "") {
      std::error_code ec;
      llvm::tool_output_file out(OutputFile.c_str(), ec, sys::fs::F_Text);
      if (ec) {
	errs() << "ERROR: Cannot open file: " << ec.message() << "\n";
      } else {
	printCounters(out.os());
	out.keep();
      }
    } else {
      printCounters(errs());
    }
    
    // if (DisplayDeclarations) {
    //   errs() << "[Non-analyzed (external) functions]\n";
    //   for(auto &p: ExtFuncs) 
    //     errs() << p.getKey() << "\n";
    // }
    
    return false;
  }

  void ProfilerPass::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
    AU.addRequired<llvm::TargetLibraryInfoWrapperPass>();
    
    if (ShowCallGraphInfo) {
      AU.addRequired<llvm::CallGraphWrapperPass>();
    }
    
    if (ProfileLoops) {
      AU.addRequired<LoopInfoWrapperPass>();
      AU.addRequired<ScalarEvolutionWrapperPass>();
    }
  }
  
  void ProfilerPass::printCounters(raw_ostream &O) {
    unsigned MaxNameLen = 0, MaxValLen = 0;
    
    O << "[CFG analysis]\n";
    
    std::vector<Counter> cfg_counters 
    {TotalFuncs, TotalSpecFuncs,
     TotalBlocks, TotalInsts,
     TotalDirectCalls, TotalExternalCalls, TotalIndirectCalls};
    
    if (ProfileLoops) {
      cfg_counters.push_back(TotalLoops);
      cfg_counters.push_back(TotalBoundedLoops);
    }
    
    formatCounters(cfg_counters, MaxNameLen, MaxValLen, false);
    std::string tsf_str("TotalSpecFuncs");
    for (auto c: cfg_counters) {
      if (c == tsf_str && c.getValue() == 0) {
	continue;
      }
      O << format("%*u %-*s\n",
		  MaxValLen, c.getValue(), 
		  MaxNameLen, c.getDesc().c_str());
    }
    
    if (PrintDetails) {
      // instruction counters
      MaxNameLen = MaxValLen = 0;
      std::vector<Counter> inst_counters;
      inst_counters.reserve(instCounters.size());
      for(auto &p: instCounters) { inst_counters.push_back(p.second); }
      formatCounters(inst_counters, MaxNameLen, MaxValLen);
      if (inst_counters.empty()) {
	O << "No information about each kind of instruction\n";
      } else {
	O << "Number of each kind of instructions:\n";
	for (auto c: inst_counters) {
	  O << format("%*u %-*s\n",
		      MaxValLen, c.getValue(),
		      MaxNameLen, c.getDesc().c_str());
	}
      }
    }
    
    // Memory counters
    MaxNameLen = MaxValLen = 0;
    std::vector<Counter> mem_counters;
    if (PrintDetails) {
      mem_counters = 
	{TotalMemInst,instCounters["Store"],instCounters["Load"],
	 MemCpy,MemMove,MemSet,
	 instCounters["GetElementPtr"],InBoundGEP,
	 instCounters["Alloca"], TotalAllocations,
	 SafeMemAccess,MemUnknown};
    } else {
      mem_counters= {TotalMemInst, SafeMemAccess, MemUnknown};
    }
    
    formatCounters(mem_counters, MaxNameLen, MaxValLen, false);
    O << "[Memory analysis]\n";
    for (auto c: mem_counters) {
      O << format("%*u %-*s\n",
		  MaxValLen, c.getValue(),
		  MaxNameLen, c.getDesc().c_str());
    }
    
    // { // Division counters
    //   MaxNameLen = MaxValLen = 0;
    //   std::vector<Counter> div_counters 
    //   {SafeIntDiv,UnsafeIntDiv,SafeFPDiv,UnsafeFPDiv,DivIntUnknown,DivFPUnknown};
    //   formatCounters(div_counters, MaxNameLen, MaxValLen,false);
    //   O << "[Division by zero analysis]\n";
    //   for (auto c: div_counters) {
    //     O << format("%*u %-*s\n",
    //                 MaxValLen, 
    //                 c.getValue(),
    //                 MaxNameLen,
    //                 c.getDesc().c_str());
    //   }
    // }
    
    // { // left shift
    //   MaxNameLen = MaxValLen = 0;
    //   std::vector<Counter> lsh_counters {SafeLeftShift,UnsafeLeftShift,UnknownLeftShift};
    //   formatCounters(lsh_counters, MaxNameLen, MaxValLen,false);
    //   O << "[Oversized left shifts analysis]\n";
    //   for (auto c: lsh_counters) {
    //     O << format("%*u %-*s\n",
    //                 MaxValLen, 
    //                 c.getValue(),
    //                 MaxNameLen,
    //                 c.getDesc().c_str());
    //   }
    // }
  }

  char ProfilerPass::ID = 0;
    
} // end namespace previrt

static llvm::RegisterPass<previrt::ProfilerPass>
X("Pprofiler",
  "Count number of functions, instructions, memory accesses, etc.",
  false,
  false);

    



