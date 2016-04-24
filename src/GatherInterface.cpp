//
// OCCAM
//
// Copyright (c) 2011-2016, SRI International
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

#include "llvm/ADT/StringMap.h"
#include "llvm/IR/User.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CallSite.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Analysis/AliasAnalysis.h"

#include "PrevirtualizeInterfaces.h"
#include "ArgIterator.h"

#include <vector>
#include <set>
#include <queue>
#include <string>
#include <stdio.h>
#include <fstream>

#include "proto/Previrt.pb.h"

using namespace llvm;

namespace previrt
{
  class GatherReferences : public InstVisitor<GatherReferences, void>
  {
  public:
    ComponentInterface* const interface;
    std::queue<Function*>* used;
    bool anyUnknown;
    AliasAnalysis* aa;
  public:
    GatherReferences(ComponentInterface* i, AliasAnalysis* _aa, std::queue<Function*>* _used = NULL) :
      interface(i), used(_used), anyUnknown(false), aa(_aa)
    {
    }

  private:
    bool
    isInternal(Function* target) const
    {
      assert(target != NULL);
      // TODO: Assume that if the function has a body then
      //       this component owns it
      if (target->isDeclaration() && !target->isIntrinsic())
        return false;
      return true;
    }

  public:
    void
    visitInstruction(Instruction &I)
    {
      // TODO: We need to find all references, including ones stored in variables
      //       we'll be conservative and say that if it is stored in a variable then
      //       we can't optimize it at all
      if (BinaryOperator* bo = dyn_cast<BinaryOperator>(&I)) {
        visitBinaryOperator(*bo);
      } else if (IntToPtrInst* bo = dyn_cast<IntToPtrInst>(&I)) {
        visitIntToPtrInst(*bo);
      } else if (BitCastInst* bo = dyn_cast<BitCastInst>(&I)) {
        visitBitCastInst(*bo);
      }
    }
    void
    visitBinaryOperator(BinaryOperator& I)
    {
      if (isa<FunctionType>(I.getOperand(0)->getType()) || isa<FunctionType>(I.getOperand(0)->getType())) {
        anyUnknown = true;
      }
    }
    void
    visitIntToPtrInst(IntToPtrInst& I)
    {
      if (isa<FunctionType>(I.getDestTy()))
        anyUnknown = true;
    }
    void
    visitBitCastInst(BitCastInst& I)
    {
      if (isa<FunctionType>(I.getDestTy()))
        anyUnknown = true;
    }
    void
    visitCallInst(CallInst &I)
    {
      if (I.isInlineAsm())
        return;
      Function* target = I.getCalledFunction();
      if (target == NULL) {
        anyUnknown = true;
        return;
      }

      if (isInternal(target)) {
        if (used != NULL) used->push(target);
      } else {
        interface->call(target->getName(), arg_begin(I), arg_end(I), StatisticsUtility::GetInstructionsCount(target));
      }
      this->visitInstruction(I);
    }
    void
    visitInvokeInst(InvokeInst &I)
    {
      Function* target = I.getCalledFunction();
      if (target == NULL) {
        anyUnknown = true;
        return;
      }
      if (isInternal(target)) {
        if (used != NULL) used->push(target);
      } else {
        interface->call(target->getName(), arg_begin(I), arg_end(I), StatisticsUtility::GetInstructionsCount(target));
      }
      this->visitInstruction(I);
    }
  };

  /*
   * Compute the minimal interface that the given module depends on
   */
  void
  GatherInterface(Module& M, ComponentInterface& C, AliasAnalysis* aa)
  {
    GatherReferences algo(&C, aa);
    algo.visit(M);
  }

  bool
  operator<(const Function& lhs, const Function& rhs)
  {
    return lhs.getName().compare(rhs.getName()) < 0;
  }

  bool
  GatherInterface(Function& F, ComponentInterface& C, AliasAnalysis* aa)
  {
    if (F.isDeclaration()) {
      errs() << "Gather interface of undefined function '" << F.getName() << "'\n";
      return true;
    }

    std::set<Function*> visited;
    std::queue<Function*> worklist;

    GatherReferences algo(&C, aa, &worklist);

    worklist.push(&F);
    while (!worklist.empty()) {
      Function* f = worklist.front();
      worklist.pop();

      if (visited.find(f) != visited.end())
        continue;

      algo.visit(f);

      if (algo.anyUnknown) {
        // TODO: This is a safety precaution, we should be able to
        //       take advantage of a global alias analysis to get
        //       a better set
        GatherInterface(*F.getParent(), C, aa);
        return false;
      }
      visited.insert(f);
    }
    return true;
  }

  static cl::opt<std::string> GatherInterfaceOutput("Pinterface-output",
      cl::init(""), cl::Hidden, cl::desc(
          "specifies the output file for the interface description"));
  static cl::list<std::string> GatherInterfaceMain("Pinterface-function",
      cl::Hidden, cl::desc(
          "specifies the function that is called"));
  static cl::list<std::string> GatherInterfaceEntry("Pinterface-entry",
        cl::Hidden, cl::desc(
            "specifies the interface that is used (only function names)"));
  class GatherInterfacePass : public ModulePass
  {
  public:
    ComponentInterface interface;
    static char ID;

  public:
    GatherInterfacePass() :
      ModulePass(ID)
    {
    }
    virtual
    ~GatherInterfacePass()
    {
    }
  public:
    virtual void
    getAnalysisUsage(AnalysisUsage &Info) const
    {
      Info.addRequiredTransitive<AliasAnalysis>();
    }
    virtual bool
    runOnModule(Module& M)
    {
      AliasAnalysis& aa = this->getAnalysis<AliasAnalysis>();
      bool checked = false;

      errs() <<  "GatherInterfacePass::runOnModule: " << M.getModuleIdentifier() << "\n";
      
      if (!GatherInterfaceMain.empty()) {
        checked = true;
        for (cl::list<std::string>::const_iterator i = GatherInterfaceMain.begin(), e = GatherInterfaceMain.end();
            i != e; ++i) {
          Function* f = M.getFunction(*i);
          if (f == NULL) {
            errs() << "Function '" << *i << "' not found, skipping\n";
            continue;
          }
          if (f->isDeclaration()) {
            errs() << "Function '" << *i << "' is declaration, skipping\n";
            continue;
          }
          errs() << "Gathering from: " << *f << "\n";
          GatherInterface(*f, this->interface, &aa);
        }
      }
      if (!GatherInterfaceEntry.empty()) {
        checked = true;
        ComponentInterface ci;
        for (cl::list<std::string>::const_iterator i = GatherInterfaceEntry.begin(), e = GatherInterfaceEntry.end();
              i != e; ++i) {
          errs() << "Reading interface from '" << *i << "'...";
          if (ci.readFromFile(*i)) {
            errs() << "success\n";
          } else {
            errs() << "failed\n";
            continue;
          }
        }
        for (ComponentInterface::FunctionIterator i = ci.begin(), e = ci.end(); i != e; ++i) {
          Function* f = M.getFunction(i->first());
          if (f == NULL) continue;
          if (!GatherInterface(*f, this->interface, &aa)) break;
        }
      }
      if (!checked) {
        GatherInterface(M, this->interface, &aa);
      }

      if (GatherInterfaceOutput != "") {
        proto::ComponentInterface ci;
        codeInto<ComponentInterface, proto::ComponentInterface> (
            this->interface, ci);
        std::ofstream output(GatherInterfaceOutput.c_str(), std::ios::binary);
        assert(ci.SerializeToOstream(&output));
        output.close();
      }
      return false;
    }
  };
  char GatherInterfacePass::ID;

  static RegisterPass<GatherInterfacePass> X("Pinterface",
      "compute the external dependencies of the module.", false, false);
}
