//
// OCCAM
//
// Copyright (c) 2011-2012, SRI International
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
#include "llvm/IR/Function.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Constants.h"
#include "llvm/PassManager.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/IR/CallSite.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include "SpecializationTable.h"
#include "SpecializationPolicy.h"
#include "StrategySpecializer.h"
#include "Specializer.h"

#include <list>
#include <set>
#include <vector>

using namespace llvm;
using namespace previrt;

#define DUMP 1


static bool
trySpecializeFunction(Function* f, SpecializationTable& table,
    SpecializationPolicy* policy, std::list<Function*>& to_add)
{
  bool modified = false;
  for (Function::iterator bb = f->begin(), bbe = f->end(); bb != bbe; ++bb) {
    for (BasicBlock::iterator I = bb->begin(), E = bb->end(); I != E; ++I) {
      CallSite call;
      if (CallInst* ci = dyn_cast<CallInst>(&(*I))) {
        call = CallSite(ci);
      } else if (InvokeInst* ii = dyn_cast<InvokeInst>(&(*I))) {
        call = CallSite(ii);
      } else {
        continue;
      }

      Function* callee = call.getCalledFunction();
      if (callee == NULL) { // dynamic call, can't resolve
        continue;
      }
      const unsigned int callee_arg_count = callee->getArgumentList().size();
      if (callee == NULL || !canSpecialize(callee) || callee->isVarArg())
        continue;
      if (callee->hasFnAttribute(Attribute::NoInline)) {
        //errs() << "Function '" << callee->getName() << "' has noinline, skipping.\n";
        continue;
      }
      
      //iam: the old version is when this is true
      //iam: the current 3/2/2016 version has this false.
      bool break_the_nostrip_version = false;

      if(break_the_nostrip_version){
	// This is too much traceing
	if (callee->getName().equals("")) {
	  //errs() << "Skipping function with no name.\n";
	  continue;
	}
	
      } else {
	// This is too much traceing
	if (callee->hasInternalLinkage()) {
	  //errs() << "Skipping function with internal linkage: " << callee->getName() << "\n";
	  continue;
	}

      }


      Value* const * specScheme = policy->specializeOn(callee,
          call.arg_begin(), call.arg_end());

      if (specScheme == NULL)
        continue;
      

      // == BEGIN DEBUGGING =============================================
#if DUMP
      errs() << "Specializing call to '" << callee->getName()
          << "' in function '" << f->getName() << "' on arguments [";
      for (unsigned int i = 0, cnt = 0; i < callee->getArgumentList().size(); ++i) {
        if (specScheme[i] != NULL) {
          if (cnt++ != 0)
            errs() << ",";
          Value* v = call.getInstruction()->getOperand(i);
          if (GlobalValue* gv = dyn_cast<GlobalValue>(v)) {
            errs() << i << "=(@" << gv->getName() << ")";
          } else {
            errs() << i << "=(" << *call.getInstruction()->getOperand(i) << ")";
          }
        }
      }
      errs() << "]\n";
#endif
      // == END DEBUGGING ===============================================

      std::vector<const SpecializationTable::Specialization*> versions;
      table.getSpecializations(callee, specScheme, versions);

      Function* specializedVersion = NULL;
      for (std::vector<const SpecializationTable::Specialization*>::iterator i =
          versions.begin(), e = versions.end(); i != e; ++i) {
        if (SpecializationTable::Specialization::refines(callee_arg_count,
            specScheme, (*i)->args)) {
          specializedVersion = (*i)->handle;
          break;
        }
      }

      if (NULL == specializedVersion) {
        // need to build a specialized version
        specializedVersion = specializeFunction(callee, specScheme);

        table.addSpecialization(callee, specScheme, specializedVersion);

        to_add.push_back(specializedVersion);
      }

      assert(specializedVersion != NULL);
      const unsigned int specialized_arg_count =
          specializedVersion->getArgumentList().size();

      std::vector<unsigned> argPerm;
      argPerm.reserve(specialized_arg_count);
      for (unsigned from = 0; from < callee_arg_count; from++) {
        if (specScheme[from] == NULL)
          argPerm.push_back(from);
      }
      assert(specialized_arg_count == argPerm.size());

      Instruction* newInst = specializeCallSite(I, specializedVersion, argPerm);
      llvm::ReplaceInstWithInst(bb->getInstList(), I, newInst);

      modified = true;
    }
  }

  return modified;
}

bool
SpecializerPass::runOnModule(Module &M)
{
  CallGraphWrapperPass& CG = this->getAnalysis<CallGraphWrapperPass> ();

  // Perform SCC analysis
  // (I can't seem to do this with the SCC pass because I'm not going to preserve it)
  // TODO: I don't like hard-coding this
  SpecializationPolicy* policy = SpecializationPolicy::recursiveGuard(
      SpecializationPolicy::aggressivePolicy(), CG);

  std::set<Function*> empty_set;
  std::list<Function*> to_add;
  SpecializationTable table(&M);

  FunctionPassManager* optimizer = NULL;

  if (this->optimize) {
    optimizer = new FunctionPassManager(&M);
    PassManagerBuilder builder;
    builder.OptLevel = 3;
    builder.populateFunctionPassManager(*optimizer);
  }

  bool modified = false;

  for (Module::iterator f = M.begin(), fe = M.end(); f != fe; ++f) {
    modified = trySpecializeFunction(&*f, table, policy, to_add) || modified;
  }

  while (!to_add.empty()) {
    Function* f = to_add.front();
    to_add.pop_front();

    if (f->getParent() == &M) {
      // The function was already in the module or
      // has already been added in this round of
      // specialization, no need to add it twice
      continue;
    }

    if (optimizer) {
      optimizer->run(*f);
    }

    trySpecializeFunction(f, table, policy, to_add);

    M.getFunctionList().push_back(f);
  }

  if (modified){
    errs() << "progress...\n";
  } else {
    errs() << "NO progress...\n";
  }

  policy->release();
  if (optimizer)
    delete optimizer;

  return modified;
}

void
SpecializerPass::getAnalysisUsage(AnalysisUsage &AU) const
{
  AU.addRequired<CallGraphWrapperPass> ();
}

namespace previrt
{
  char SpecializerPass::ID;

  SpecializerPass::SpecializerPass(bool _opt) :
    ModulePass(SpecializerPass::ID), optimize(_opt)
  {
    errs() << "SpecializerPass(" << _opt << ")\n";
  }

  SpecializerPass::~SpecializerPass()
  {
  }

  SpecializationPolicy::SpecializationPolicy()
  {
  }

  SpecializationPolicy::~SpecializationPolicy()
  {
  }
}

namespace
{
  using namespace previrt;

  static cl::opt<bool> OptSpecialized("Ppeval-opt", cl::Hidden,
      cl::init(false), cl::desc("optimize specialized function instances?"));

  class ParEvalOptPass : public SpecializerPass
  {
  public:
    ParEvalOptPass() :
      SpecializerPass(OptSpecialized.getValue())
    {
    }
    ~ParEvalOptPass()
    {
    }
  };

  static RegisterPass<ParEvalOptPass> X("Ppeval",
      "partial evaluation (inlining)", false, false);
}

