#pragma once

#include "llvm/Pass.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/IR/InstVisitor.h"

#include <vector>
#include <string>

#include <boost/unordered_map.hpp>

namespace llvm {
  class DataLayout;
  class TargetLibraryInfo;
  class LLVMContext;
  class BasicBlock;
  class Function;
}

namespace previrt {

  // simple class for representing a counter.
  struct Counter {
    std::string Name;
    std::string Desc;
    unsigned int Value;
    
    Counter(): Name(""), Desc(""), Value(0)  { }
      
    Counter(std::string name): Name(name), Desc(name), Value(0) { }
    
    Counter(std::string name, std::string desc): Name(name), Desc(desc), Value(0) { }
    
    bool operator<(const Counter&o) const 
    { return (getName() < o.getName()); }
    
    bool operator==(const Counter&o) const 
    { return (getName().compare(o.getName()) == 0); }
    
    unsigned int getValue() const { return Value; }
    
    std::string getName() const { return Name; }
    
    std::string getDesc() const { return Desc; }
    
    void operator++() { Value++; }
    
    void operator+=(unsigned val) { Value += val; }
  };
  
  class ProfilerPass : public llvm::ModulePass,
		       public llvm::InstVisitor<ProfilerPass> {
    friend class llvm::InstVisitor<ProfilerPass>;

    const llvm::DataLayout *DL;
    llvm::TargetLibraryInfo *TLI;
    llvm::LLVMContext *Ctx;
    llvm::StringSet<> ExtFuncs;
    // -- to group all instruction counters
    boost::unordered_map<std::string, Counter> instCounters;
    
    // -- individual counters
    Counter TotalFuncs;
    Counter TotalSpecFuncs;
    Counter TotalBounceFuncs;    
    Counter TotalBlocks;
    Counter TotalJoins;
    Counter TotalInsts;
    Counter TotalDirectCalls;
    Counter TotalIndirectCalls;
    Counter TotalAsmCalls;    
    Counter TotalExternalCalls;
    Counter TotalUnkCalls;    
    Counter TotalLoops;
    Counter TotalBoundedLoops;
    ///
    Counter SafeIntDiv;
    Counter SafeFPDiv;
    Counter UnsafeIntDiv;
    Counter UnsafeFPDiv;
    Counter DivIntUnknown;
    Counter DivFPUnknown;
    /// 
    Counter TotalMemInst;
    Counter MemUnknown;
    Counter SafeMemAccess;
    Counter TotalAllocations;
    Counter InBoundGEP;
    Counter MemCpy;
    Counter MemMove;
    Counter MemSet;
    ///
    Counter SafeLeftShift;
    Counter UnsafeLeftShift;
    Counter UnknownLeftShift;

    bool isSafeMemAccess(llvm::Value *V);
    void processPtrOperand(llvm::Value* V);
    void processMemoryIntrinsicsPtrOperand(llvm::Value* V, llvm::Value*N);
    void formatCounters(std::vector<Counter>& counters, 
			unsigned& MaxNameLen, unsigned& MaxValLen, 
			bool sort = true);
    void incrInstCounter(std::string name, unsigned val);
    
    void visitFunction(llvm::Function &F);
    void visitBasicBlock(llvm::BasicBlock &BB);
    void visitCallSite(llvm::CallSite CS);
    void visitBinaryOperator(llvm::BinaryOperator &BI);
    void visitMemTransferInst(llvm::MemTransferInst &I);
    void visitMemSetInst(llvm::MemSetInst &I);
    void visitAllocaInst(llvm::AllocaInst &I);
    void visitLoadInst(llvm::LoadInst &I);
    void visitStoreInst(llvm::StoreInst &I);
    void visitGetElementPtrInst(llvm::GetElementPtrInst &I);
    void visitInstruction(llvm::Instruction &I);
    
  public:

    static char ID; 

    ProfilerPass();
    
    bool runOnFunction(llvm::Function &F);

    bool runOnModule(llvm::Module &M) override;
    
    void getAnalysisUsage(llvm::AnalysisUsage &AU) const override;
        
    llvm::StringRef getPassName() const override {
      return "Count number of functions, instructions, memory accesses, etc";
    }

    // return the number of functions in the module
    unsigned getNumFuncs() const { return TotalFuncs.getValue(); }
    // return the number of specialized functions in the module
    unsigned getNumSpecFuncs() const { return TotalSpecFuncs.getValue(); }
    // return the number of loops in the module
    unsigned getNumLoops() const { return TotalLoops.getValue();}
    // return the number of statically bounded loops in the module
    unsigned getBoundedNumLoops() const { return TotalBoundedLoops.getValue();}    
    // return the number of basic blocks in the module
    unsigned getTotalBlocks() const { return TotalBlocks.getValue(); }
    // return the number of instructions in the module
    unsigned getTotalInst() const { return TotalInsts.getValue();}
    // return the number of direct call instructions in the module
    unsigned getTotalDirectCalls() const { return TotalDirectCalls.getValue();}
    // return the number of indirect call instructions in the module
    unsigned getTotalIndirectCalls() const { return TotalIndirectCalls.getValue();}
    // return the number of memory instructions in the module
    unsigned getTotalMemInst() const { return TotalMemInst.getValue();}
    // return the number of statically safe memory instructions in the module
    unsigned getTotalSafeMemInst() const { return SafeMemAccess.getValue();}

    // print all counters to output stream
    void printCounters(llvm::raw_ostream &O);
  };

} // end namespace 
    



