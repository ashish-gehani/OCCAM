#include "llvm/ADT/SCCIterator.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/raw_ostream.h"

#include "analysis/CostBenefitCallGraph.h"

#include <fstream>
#include <set>
#include <vector>

static llvm::cl::opt<std::string>
    benefits_filename("Pbenefits-filename",
                      llvm::cl::desc("Input file with each function benefit"),
                      llvm::cl::init(""), llvm::cl::Hidden);

static llvm::cl::opt<std::string> cost_benefit_output(
    "Pcost-benefit-output",
    llvm::cl::desc("Output file with cost-benefit information per function"),
    llvm::cl::init(""), llvm::cl::Hidden);

static llvm::cl::list<std::string>
    cg_roots("Pcallgraph-roots",
             llvm::cl::desc("Roots of the Module callgraph"), llvm::cl::Hidden);

static llvm::cl::opt<unsigned> benefit_threshold(
    "Pbenefit-threshold",
    llvm::cl::desc("Consider function if benefit greater than this threshold"),
    llvm::cl::init(50), llvm::cl::Hidden);

/* unused */
static llvm::cl::opt<unsigned> cost_threshold(
    "Pcost-threshold",
    llvm::cl::desc("Ignore function if cost greater than this threshold"),
    llvm::cl::init(3), llvm::cl::Hidden);

//#define CBCG_LOG(...) __VA_ARGS__
#define CBCG_LOG(...)

namespace previrt {
namespace transforms {

using namespace llvm;

template <typename Map>
static void convert_file_to_benefit_map(std::string filename,
                                        const llvm::Module &M, Map &out) {
  std::ifstream file(filename);
  std::string line;
  while (std::getline(file, line)) {
    size_t pos = line.find_first_of(' ');
    if (pos == std::string::npos) { // whitespace not found
      break;
    }
    std::string first = line.substr(0, pos);
    pos = line.find_last_of(' ');
    std::string second = line.substr(pos + 1);
    // stoi can throw an exception
    out.insert({M.getFunction(first), std::stoi(second)});
  }
}

const Function *CostBenefitInfo::get_function() const { return m_func; }

unsigned CostBenefitInfo::get_benefit() const { return m_benefit; }

unsigned CostBenefitInfo::get_cost() const { return m_loops.size(); }

void CostBenefitInfo::write(llvm::raw_ostream &o) const {
  o << get_function()->getName() << " " << get_benefit() << " " << get_cost();
}

CostBenefitCG::CostBenefitCG(Module &M, CallGraph &CG) : m_M(M), m_CG(CG) {}

/* Helpers */
template <typename Map> static unsigned get(const Map &m, const Function *fn) {
  auto it = m.find(fn);
  if (it != m.end()) {
    return it->second;
  } else {
    return 0;
  }
}

template <typename A, typename B>
std::pair<B, A> flip_pair(const std::pair<A, B> &p) {
  return std::pair<B, A>(p.second, p.first);
}

template <typename A, typename B>
void flip_map(const DenseMap<A, B> &src, std::multimap<B, A> &out) {
  std::transform(src.begin(), src.end(), std::inserter(out, out.begin()),
                 flip_pair<A, B>);
}

static void check_loop_info_consistency(LoopInfo &li, const Function *fun,
                                        unsigned line) {
  if (!li.empty()) {
    Loop *L = *li.begin();
    if (BasicBlock *LH = L->getHeader()) {
      if (LH->getParent() != fun) {
        errs() << "Error at " << __FILE__ << "::" << line << ":  "
               << "loop info from " << LH->getParent()->getName()
               << " does not belong to current function " << fun->getName()
               << "\n";
      }
      assert(LH->getParent() == fun);
    }
  }
}

// Dynamic inlining of the whole callgraph while computing a
// conservative upper bound of all the loops that might have been
// executed BEFORE a function is called.
//
// FIXME: this might be very expensive.
// TODO : use cache to avoid revisiting same function
static void find_loops( // current basic block
    const BasicBlock &cur,
    // loop info for Cur's function
    LoopInfo &li,
    // loop info map
    ModulePass *pass,
    // current stack with executed loops
    std::vector<const Loop *> stack,
    // to break cycles
    std::set<const BasicBlock *> &visited,
    // merge the stacks at all function's callsites.
    DenseMap<const Function *, CostBenefitInfo::LoopSet> &cache,
    // sanity check
    unsigned &num_loops) {

  typedef GraphTraits<const Function *> GT;
  typedef typename GT::NodeRef NodeRef;

  // already visited
  if (!visited.insert(&cur).second) {
    return;
  }

  CBCG_LOG(errs() << "VISITING " << cur.getParent()->getName() << "::";
           cur.printAsOperand(errs(), false); errs() << "\n";);

  if (li.isLoopHeader(&cur)) {
    CBCG_LOG(errs() << "\tFOUND loop " << cur.getParent()->getName() << "::";
             cur.printAsOperand(errs(), false); errs() << "\n";);

    stack.push_back(li[&cur]);
    num_loops++;
  }

  // -- Traverse recursively any callsite inside the block
  for (auto &I : cur) {
    if (isa<CallInst>(&I) || isa<InvokeInst>(&I)) {
      ImmutableCallSite CS(&I);
      if (const Function *callee = CS.getCalledFunction()) {
        if (callee->isDeclaration() || callee->empty()) {
          continue;
        }

        // update cache
        if (!stack.empty()) {
          auto it = cache.find(callee);
          if (it != cache.end()) {
            it->second.insert(stack.begin(), stack.end());
          } else {
            cache.insert(
                {callee, CostBenefitInfo::LoopSet(stack.begin(), stack.end())});
          }
        }

        // recursive call
        LoopInfo &li_callee = pass->getAnalysis<LoopInfoWrapperPass>(
                                      *(const_cast<Function *>(callee)))
                                  .getLoopInfo();

        CBCG_LOG(errs() << "LOOP INFO FOR " << callee->getName() << ":\n";
                 if (li_callee.empty()) errs() << "NO LOOPS\n";
                 else li_callee.print(errs()););

        check_loop_info_consistency(li_callee, callee, __LINE__);
        find_loops(callee->getEntryBlock(), li_callee, pass, stack, visited,
                   cache, num_loops);
      }
    }
  }

  // -- Continue recursively with the successors
  for (auto it = GT::child_begin(&cur), et = GT::child_end(&cur); it != et;
       ++it) {
    NodeRef succ = *it;
    // recursive call

    // XXX: we cannot pass li. Don't know why ...
    LoopInfo &li_succ = pass->getAnalysis<LoopInfoWrapperPass>(
                                *(const_cast<Function *>(succ->getParent())))
                            .getLoopInfo();

    check_loop_info_consistency(li_succ, succ->getParent(), __LINE__);
    find_loops(*succ, li_succ, pass, stack, visited, cache, num_loops);
  }

  // if (li.isLoopHeader(&cur)) {
  //   stack.pop_back();
  // }
}

void CostBenefitCG::run(std::string benefit_filename, ModulePass *pass,
                        unsigned benefit_threshold, unsigned cost_threshold,
                        const std::vector<Function *> &roots) {

  // abort if we don't have benefits for callgraph nodes
  if (benefit_filename == "") {
    errs() << "No file given with benefits. Aborting ...\n";
    return;
  }

  // abort if we don't have a root for the callgraph
  if (roots.empty()) {
    errs() << "No callgraph root given. Aborting ...\n";
    return;
  }

  DenseMap<const Function *, unsigned> func_to_benefit_map;
  DenseMap<const Function *, unsigned> func_to_acc_benefit_map;

  CBCG_LOG(errs() << "Reading file with benefits ...");
  convert_file_to_benefit_map(benefit_filename, m_M, func_to_benefit_map);
  CBCG_LOG(errs() << "done!\n");

  CBCG_LOG(errs() << "Starting bottom-up phase computing benefits ...\n");
  // 1. Bottom-up traversal that computes accumulative benefits for
  //    each call graph node.
  for (auto it = scc_begin(&m_CG); !it.isAtEnd(); ++it) {
    auto &scc = *it;
    unsigned acc_benefit = 0;
    for (CallGraphNode *cgn : scc) {
      Function *fn = cgn->getFunction();
      if (!fn || fn->isDeclaration() || fn->empty()) {
        continue;
      }
      // add accumulative benefit of the scc members' children
      for (unsigned i = 0, e = cgn->size(); i < e; ++i) {
        CallGraphNode *kid = cgn->operator[](i);
        acc_benefit += get(func_to_acc_benefit_map, kid->getFunction());
      }
      // add benefit of the scc members
      acc_benefit += get(func_to_benefit_map, fn);
    }

    for (CallGraphNode *cgn : scc) {
      Function *fn = cgn->getFunction();
      if (!fn || fn->isDeclaration() || fn->empty()) {
        continue;
      }
      func_to_acc_benefit_map[fn] = acc_benefit;
    }
  }
  CBCG_LOG(errs() << "Finished bottom-up phase computing benefits.\n");

  // 2. Top-down traversal that computes the cost for each function
  DenseMap<const Function *, LoopSet> func_to_loop_map;
  std::set<const BasicBlock *> visited;
  std::vector<const Loop *> stack;

  CBCG_LOG(errs() << "Starting top-down phase computing costs...\n");

  for (auto root : roots) {
    LoopInfo &li_root =
        pass->getAnalysis<LoopInfoWrapperPass>(*(const_cast<Function *>(root)))
            .getLoopInfo();

    CBCG_LOG(errs() << "LOOP INFO FOR " << root->getName() << ":\n";
             if (li_root.empty()) errs() << "NO LOOPS\n";
             else li_root.print(errs()););

    unsigned num_visited_loops = 0;
    find_loops(root->getEntryBlock(), li_root, pass, stack, visited,
               func_to_loop_map, num_visited_loops);
  }

  CBCG_LOG( // sanity check
      unsigned total_bb = 0; unsigned total_loops = 0; for (auto &F
                                                            : m_M) {
        if (F.isDeclaration() || F.empty())
          continue;
        total_bb += F.size();

        LoopInfo &LI = pass->getAnalysis<LoopInfoWrapperPass>(
                               *(const_cast<Function *>(&F)))
                           .getLoopInfo();
        total_loops += std::distance(LI.begin(), LI.end());
      } errs() << "Visited "
               << visited.size() << " blocks over " << total_bb << ".\n";
      errs() << "Visited " << num_visited_loops << " loops over " << total_loops
             << ".\n";
      errs() << "Finished top-down phase computing costs. ";);

  // 3. populate m_cost_benefit
  std::multimap<unsigned, const Function *> ss;
  flip_map(func_to_acc_benefit_map, ss);
  // start from the max benefit
  for (auto it = ss.rbegin(), et = ss.rend(); it != et; ++it) {
    const Function *fun = it->second;
    unsigned benefit = it->first;
    LoopSet &loops = func_to_loop_map[fun];
    if (benefit > benefit_threshold) {
      CostBenefitInfo CBI(fun, benefit, loops);
      m_cost_benefit.push_back(CBI);
    }
  }
}

CostBenefitCG::iterator CostBenefitCG::begin() {
  return m_cost_benefit.begin();
}

CostBenefitCG::iterator CostBenefitCG::end() { return m_cost_benefit.end(); }

CostBenefitCG::const_iterator CostBenefitCG::begin() const {
  return m_cost_benefit.begin();
}

CostBenefitCG::const_iterator CostBenefitCG::end() const {
  return m_cost_benefit.end();
}

void CostBenefitCG::write(raw_ostream &o) const {
  for (const_iterator it = begin(), et = end(); it != et; ++it) {
    it->write(o);
    o << "\n";
  }
}

void CostBenefitCGPass::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<CallGraphWrapperPass>();
  AU.addRequired<LoopInfoWrapperPass>();
  AU.setPreservesAll();
}

bool CostBenefitCGPass::runOnModule(Module &M) {
  // -- the call graph
  auto &cg = getAnalysis<CallGraphWrapperPass>().getCallGraph();

  std::vector<Function *> roots;
  roots.reserve(std::distance(cg_roots.begin(), cg_roots.end()));
  for (auto s : cg_roots) {
    Function *f = M.getFunction(s);
    if (!f) {
      errs() << "No function found for name " << s << "\n";
    } else {
      roots.push_back(f);
    }
  }

  m_cbcg = new CostBenefitCG(M, cg);
  m_cbcg->run(benefits_filename, this, benefit_threshold, cost_threshold,
              roots);

  std::error_code error_code;
  raw_fd_ostream fd(cost_benefit_output, error_code, llvm::sys::fs::F_None);
  if (error_code) {
    errs() << "Could not open " << cost_benefit_output << ". Aborting...\n";
  }
  m_cbcg->write(fd);
  fd.close();

  return false;
}

char CostBenefitCGPass::ID = 0;

} // end namespace transforms
} // end namespace previrt

static llvm::RegisterPass<previrt::transforms::CostBenefitCGPass>
    X("Pcost-benefit-cg",
      "Pass that computes cost and benefit for each call graph node");
