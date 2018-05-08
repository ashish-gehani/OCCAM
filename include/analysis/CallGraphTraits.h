#pragma once

#include "llvm/Pass.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Support/raw_ostream.h"

/**
 * Wrappers and templates for GraphTraits call graphs.
 **/

namespace llvm {

/// TODO: wrappers without allocating memory.

class CallGraphWrapper;  
class CallGraphNodeWrapper {
private:
  friend class CallGraphWrapper;
  
  CallGraphNode*  _CGN; 
  std::vector<CallGraphNodeWrapper*> _Children;
  std::vector<CallGraphNodeWrapper*> _Preds;  
  CallGraphWrapper* _CGW;

public:

  CallGraphNodeWrapper(CallGraphNode * CGN, CallGraphWrapper* CGW)
    : _CGN(CGN), _CGW(CGW) {}

  typedef std::vector<CallGraphNodeWrapper*>::iterator succ_iterator;
  typedef std::vector<CallGraphNodeWrapper*>::const_iterator const_succ_iterator;  
  typedef succ_iterator pred_iterator;
  typedef const_succ_iterator const_pred_iterator;  

  
  const CallGraphWrapper* getParent() const { return _CGW;}
  CallGraphWrapper* getParent() { return _CGW;}

  succ_iterator succ_begin() { return _Children.begin(); }
  succ_iterator succ_end() { return _Children.end(); }
  const_succ_iterator succ_begin() const { return _Children.begin(); }
  const_succ_iterator succ_end() const { return _Children.end(); }
  
  pred_iterator pred_begin() { return _Preds.begin(); }
  pred_iterator pred_end() { return _Preds.end(); }
  const_pred_iterator pred_begin() const { return _Preds.begin();}
  const_pred_iterator pred_end() const { return _Preds.end(); }

  void printAsOperand(raw_ostream &O, bool PrintType /*unused*/) {
    _CGN->print(O);
  }

  CallGraphNode* get() { return _CGN; }
  const CallGraphNode* get() const { return _CGN; }
  void print(raw_ostream &o) { _CGN->print(o); }
};
  
class CallGraphWrapper {
  
  typedef std::map<CallGraphNode *, CallGraphNodeWrapper> CallGraphNodeMapTy;
  typedef CallGraphNodeMapTy::value_type PairTy;
  
  CallGraph * _CG;
  CallGraphNodeMapTy _CGM;
  CallGraphNodeWrapper* _Entry;

  static CallGraphNodeWrapper* getValue(PairTy& p) { return &(p.second); }
  static const CallGraphNodeWrapper* getConstValue(const PairTy& p) { return &(p.second); }

  CallGraphNodeWrapper& lookup(CallGraphNode * CGN) {
    auto it = _CGM.find(CGN);
    if (it != _CGM.end()) {
      return it->second;
    } else {
      llvm_unreachable("call graph node not found in the map");
    }
  }

  void addLinks(CallGraphNodeWrapper& n1, CallGraphNodeWrapper& n2) {
    if (std::find(n1._Children.begin(), n1._Children.end(), &n2) == n1._Children.end())
      n1._Children.push_back(&n2);
    if (std::find(n2._Preds.begin(), n2._Preds.end(), &n1) == n2._Preds.end())     
      n2._Preds.push_back(&n1);
  }
  
public:
  
  CallGraphWrapper(CallGraph *CG): _CG(CG) {
    // -- create a wrapper per call graph node
    for(CallGraph::iterator it = _CG->begin(), et = _CG->end(); it!=et; ++it) {
      CallGraphNode* CGN = (*it).second.get();
      if (!CGN->getFunction()) continue;
      CallGraphNodeWrapper CGNW(CGN, this);
      _CGM.insert(std::make_pair(CGN, CGNW));
    }

    // -- root of the call graph
    if (Function* main = _CG->getModule().getFunction("main")) {
      CallGraphNode* CGN = (*_CG)[main];
      _Entry = &lookup(CGN);
    } else {
      llvm_unreachable("main function not found");
    }
    
    // -- populate successors and predecessors
    for(CallGraphNodeMapTy::iterator it = _CGM.begin(), et = _CGM.end(); it!=et; ++it) {
      CallGraphNode *N = it->first;
      for (CallGraphNode::iterator n_it = N->begin(), n_et = N->end(); n_it!=n_et; ++n_it) {
	CallGraphNode *Succ = n_it->second;
	if (Succ->getFunction()) {
	  addLinks(it->second, lookup(Succ));
	}
      }
    }
  }

  typedef mapped_iterator<CallGraphNodeMapTy::iterator,
			  decltype(&CallGraphWrapper::getValue)> iterator;
  typedef mapped_iterator<CallGraphNodeMapTy::const_iterator,
			  decltype(&CallGraphWrapper::getConstValue)> const_iterator;

  CallGraphNodeWrapper* getEntryNode() { return _Entry; }
  const CallGraphNodeWrapper* getEntryNode() const { return _Entry; }

  // This is needed to compute dominator trees.
  // 
  // GenericDomTree.h line 423:
  // NodeT *findNearestCommonDominator(NodeT *A, NodeT *B) const {
  // ... 
  //    NodeT &Entry = A->getParent()->front();
  // NodeT = CallGraphNodeWrapper* or const CallGraphNodeWrapper*
  CallGraphNodeWrapper& front() { return *getEntryNode(); }
  const CallGraphNodeWrapper& front() const { return *getEntryNode(); }  

  unsigned size() const { return _CGM.size(); }
  
  iterator begin() {
    return iterator(_CGM.begin(), &CallGraphWrapper::getValue);
  }
  iterator end() {
    return iterator(_CGM.end(), &CallGraphWrapper::getValue);
  }  
  const_iterator begin() const {
    return const_iterator(_CGM.begin(), &CallGraphWrapper::getConstValue);
  }
  const_iterator end() const {
    return const_iterator(_CGM.end(), &CallGraphWrapper::getConstValue);
  }

  CallGraphNodeWrapper* operator[](const Function* F) {
    if (CallGraphNode* CGN = (*_CG)[F]) {
      CallGraphNodeMapTy::iterator it = _CGM.find(CGN);
      if (it != _CGM.end()) {
	return &it->second;
      }
    }
    return nullptr;
  }
  
  const CallGraphNodeWrapper* operator[](const Function* F) const {
    if (CallGraphNode* CGN = (*_CG)[F]) {
      CallGraphNodeMapTy::const_iterator it = _CGM.find(CGN);
      if (it != _CGM.end()) {
	return &it->second;
      }
    }
    return nullptr;
  }

  /* DFS of the call graph */   
  void print(raw_ostream&o) {
    o << "==== Call Graph ====\n";
    CallGraphNodeWrapper* Root = getEntryNode();
    std::set<CallGraphNodeWrapper*> visited;
    visited.insert(Root);
    std::vector<CallGraphNodeWrapper*> worklist = {Root};    
    while(!worklist.empty()) {
      CallGraphNodeWrapper* Cur = worklist.back();
      worklist.pop_back();
      Cur->print(o);
      o << "\n";
      for (CallGraphNodeWrapper::succ_iterator it = Cur->succ_begin(), et = Cur->succ_end();
	   it != et; ++it) {
	CallGraphNodeWrapper* Succ = *it;
	if (visited.insert(Succ).second)
	  worklist.push_back(Succ);
      }
    }
  }    
};

//===----------------------------------------------------------------------===//
// GraphTraits specializations for call graphs so that they can be treated as
// graphs by the generic graph algorithms.
//===----------------------------------------------------------------------===//
  
template <>
struct GraphTraits<CallGraphNodeWrapper *> {
  using NodeRef = CallGraphNodeWrapper *;
  using ChildIteratorType = CallGraphNodeWrapper::succ_iterator ;

  static NodeRef getEntryNode(CallGraphNodeWrapper *CGN) { return CGN; }
  static ChildIteratorType child_begin(NodeRef N) { return N->succ_begin(); }
  static ChildIteratorType child_end(NodeRef N) { return N->succ_end(); }
};

template <>
struct GraphTraits<const CallGraphNodeWrapper *> {
  using NodeRef = const CallGraphNodeWrapper *;
  using ChildIteratorType = CallGraphNodeWrapper::const_succ_iterator ;
  
  static NodeRef getEntryNode(const CallGraphNodeWrapper *CGN) { return CGN; }
  static ChildIteratorType child_begin(NodeRef N) { return N->succ_begin(); }
  static ChildIteratorType child_end(NodeRef N) { return N->succ_end(); }
};

template <>
  struct GraphTraits<Inverse<CallGraphNodeWrapper*>> {
  using NodeRef = CallGraphNodeWrapper *;
  using ChildIteratorType = CallGraphNodeWrapper::pred_iterator;
  
  static NodeRef getEntryNode(Inverse<CallGraphNodeWrapper *> G) { return G.Graph; }
  static ChildIteratorType child_begin(NodeRef N) { return N->pred_begin(); }
  static ChildIteratorType child_end(NodeRef N) { return N->pred_end(); }
};

template <>
  struct GraphTraits<Inverse<const CallGraphNodeWrapper*>> {
  using NodeRef = const CallGraphNodeWrapper *;
  using ChildIteratorType = CallGraphNodeWrapper::const_pred_iterator;
  
  static NodeRef getEntryNode(Inverse<const CallGraphNodeWrapper *> G) { return G.Graph; }
  static ChildIteratorType child_begin(NodeRef N) { return N->pred_begin(); }
  static ChildIteratorType child_end(NodeRef N) { return N->pred_end(); }
};
  
template <>
struct GraphTraits<CallGraphWrapper *> {
  using nodes_iterator = CallGraphWrapper::iterator;
  using NodeRef = CallGraphNodeWrapper *;
  using ChildIteratorType = CallGraphNodeWrapper::succ_iterator;
  
  static NodeRef getEntryNode(CallGraphWrapper *CG) { return CG->getEntryNode(); }
  static unsigned size(CallGraphWrapper *CG) { return CG->size(); }
  static nodes_iterator nodes_begin(CallGraphWrapper *CG) { return CG->begin(); }
  static nodes_iterator nodes_end(CallGraphWrapper *CG) { return CG->end(); }
  static ChildIteratorType child_begin(NodeRef N) { return N->succ_begin(); }
  static ChildIteratorType child_end(NodeRef N) { return N->succ_end(); }
  
};

template <>
struct GraphTraits<const CallGraphWrapper *> {
  using nodes_iterator = CallGraphWrapper::const_iterator;
  using NodeRef = const CallGraphNodeWrapper *;
  using ChildIteratorType = CallGraphNodeWrapper::const_succ_iterator;
  
  static NodeRef getEntryNode(const CallGraphWrapper *CG) { return CG->getEntryNode(); }
  static unsigned size(const CallGraphWrapper *CG) { return CG->size(); }
  static nodes_iterator nodes_begin(const CallGraphWrapper *CG) { return CG->begin(); }
  static nodes_iterator nodes_end(const CallGraphWrapper *CG) { return CG->end(); }
  static ChildIteratorType child_begin(NodeRef N) { return N->succ_begin(); }
  static ChildIteratorType child_end(NodeRef N) { return N->succ_end(); }
};
//===----------------------------------------------------------------------===//
 
} // end namespace llvm
 
