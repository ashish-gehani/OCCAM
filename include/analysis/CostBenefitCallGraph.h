#pragma once

#include "llvm/ADT/DenseMap.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"

#include <vector>
#include <set>

namespace llvm {
  class CallGraph;
  class Function;
  class ModulePass;
  class Loop;
}


namespace previrt {
namespace transforms {
  
/*
  This class computes the cost and the benefit for each call graph
  node. It produces an iterator over the call graph nodes sorted by
  cost/benefit ratio.

  The benefits are given in a file and it's the reward for considering
  f.  The cost is fixed and it's defined as:

      cost(f) = the sum of the number of loops that might be executed
                starting from a particular call graph node up to all
                callsites to f.
              
  The notion of cost can be refined and can consider for instance, the
  fact a loop is statically bounded or not, whether it's user-input
  dependent etc.
 */

class CostBenefitInfo {
 public:
  typedef std::set<const llvm::Loop*> LoopSet;
  
   CostBenefitInfo(const llvm::Function* func, unsigned benefit, LoopSet loops):
      m_func(func)
    , m_benefit(benefit)
    , m_loops(loops) { }

  // Return function
  const llvm::Function* get_function() const;

  // Return user-defined benefit
  unsigned get_benefit() const;
  
  // Return an upper-bound of the number of loops executed before the
  // function is executed.
  unsigned get_cost() const;
  
  void write(llvm::raw_ostream& o) const;
  
  friend llvm::raw_ostream& operator<<(llvm::raw_ostream& o, const CostBenefitInfo& i) {
    i.write(o);
    return o;
  }
  
 private:
  const llvm::Function* m_func;
  unsigned m_benefit;
  LoopSet m_loops;
};

 
class CostBenefitCG {

  typedef typename CostBenefitInfo::LoopSet LoopSet;
  typedef std::vector<CostBenefitInfo> cost_benefit_vector_t;

 public:

  typedef cost_benefit_vector_t::iterator iterator;
  typedef cost_benefit_vector_t::const_iterator const_iterator;

private:
  
  llvm::Module& m_M;
  llvm::CallGraph& m_CG;
  // -- the solution: a vector with benefit-cost per function sorted
  //    by benefit
  cost_benefit_vector_t m_cost_benefit;
  
 public:

  CostBenefitCG(llvm::Module& M, llvm::CallGraph& CG);

  void run(//filename that contains the benefits for each function
	   std::string benefit_filename,
	   // Module Pass to access to LoopInfoWrapperPass
	   llvm::ModulePass* pass,
	   // threshold to consider a function benefitial
	   unsigned benefit_threshold,
	   // threshold to consider a function too costly
	   unsigned cost_threshold,
	   // call graph roots
	   const std::vector<llvm::Function*>& roots);
  
  iterator begin();
  iterator end();
  const_iterator begin() const;
  const_iterator end() const;
  void write(llvm::raw_ostream& o) const;
};

class CostBenefitCGPass: public llvm::ModulePass {
  CostBenefitCG* m_cbcg;
  
public:
  static char ID;       
  
  CostBenefitCGPass (): ModulePass (ID), m_cbcg(nullptr) {}
  ~CostBenefitCGPass() { if (m_cbcg) { delete m_cbcg; } }
  const CostBenefitCG* get_cbcg() const { return m_cbcg; }
  
  void getAnalysisUsage (llvm::AnalysisUsage &AU) const override;
  bool runOnModule (llvm::Module &M) override;
  llvm::StringRef getPassName() const override 
  { return "CostBenefitCGPass"; }
};
  
}
}
 
