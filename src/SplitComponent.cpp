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
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Pass.h"
#include "llvm/PassManager.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Bitcode/ReaderWriter.h"

#include "PrevirtualizeInterfaces.h"
#include "Previrtualize.h"

#include <vector>
#include <string>
#include <stdio.h>

using namespace llvm;

namespace previrt
{
  inline
  SlicePolicy::SlicePolicy()
  {
  }
  inline
  SlicePolicy::~SlicePolicy()
  {
  }

  class SplitPolicy : public SlicePolicy
  {
  public:
    enum Level
    {
      LOW, HIGH
    };
  private:
    Level level;
  protected:
    SplitPolicy(Level l) :
      level(l)
    {
    }
  public:
    virtual
    ~SplitPolicy()
    {
    }

    virtual Level
    classifyFunction(const Function& f) const = 0;
    virtual Level
    classifyAsm() const = 0;

    virtual bool
    keepFunction(const Function& f) const
    {
      return this->level == this->classifyFunction(f);
    }
    virtual bool
    keepAsm() const
    {
      return this->level == this->classifyAsm();
    }
  };

  class AssemblyPolicy : public SplitPolicy
  {
  public:
    AssemblyPolicy(SplitPolicy::Level l) :
      SplitPolicy(l)
    {
    }
  public:
    static const AssemblyPolicy LOW;
    static const AssemblyPolicy HIGH;
  public:
    virtual Level
    classifyFunction(const Function& f) const
    {
      for (Function::const_iterator i = f.begin(), e = f.end(); i != e; ++i) {
        for (BasicBlock::const_iterator I = i->begin(), E = i->end(); I != E; ++I) {
          if (const CallInst* ci = dyn_cast<const CallInst>(&*I)) {
            if (ci->isInlineAsm()) {
              return SplitPolicy::LOW;
            }
          }
        }
      }
      return SplitPolicy::HIGH;
    }
    virtual Level
    classifyAsm() const
    {
      return SplitPolicy::LOW;
    }
  };
  const AssemblyPolicy AssemblyPolicy::LOW(SplitPolicy::LOW);
  const AssemblyPolicy AssemblyPolicy::HIGH(SplitPolicy::HIGH);

  /*
   * Split the code in Module M into two pieces based on the policy
   */
  bool
  sliceComponent(Module& M, const SplitPolicy& policy)
  {
    bool modified = false;

    if (M.getModuleInlineAsm() != "" || !policy.keepAsm()) {
      M.setModuleInlineAsm("");
      modified = true;
    }

    for (Module::iterator b = M.begin(), e = M.end(); b != e; ++b) {
      if (b->isDeclaration())
        continue;
      if (policy.keepFunction(*b)) {
        b->deleteBody();
        modified = true;
      }
    }

    // Use LLVM to remove dead definitions, code, etc.
    PassManager mgr;
    mgr.add(createGlobalDCEPass());
    mgr.add(createGlobalOptimizerPass());
    while (mgr.run(M)) {
      modified = true;
    }

    return modified;
  }

  class SplitLowPass : public ModulePass
  {
  public:
    static char ID;
  public:
    SplitLowPass() :
      ModulePass(ID)
    {
    }
    virtual
    ~SplitLowPass()
    {
    }
  public:
    virtual bool
    runOnModule(Module& M)
    {
      return sliceComponent(M, AssemblyPolicy::LOW);
    }
  };
  char SplitLowPass::ID;

  class SplitHighPass : public ModulePass
  {
  public:
    static char ID;
  public:
    SplitHighPass() :
      ModulePass(ID)
    {
    }
    virtual
    ~SplitHighPass()
    {
    }
  public:
    virtual bool
    runOnModule(Module& M)
    {

      errs() << "SplitHighPass::runOnModule: " << M.getModuleIdentifier() << "\n";
      
      return sliceComponent(M, AssemblyPolicy::HIGH);
    }
  };
  char SplitHighPass::ID;

  static RegisterPass<SplitHighPass> Xhigh("Psplit-asm-high",
      "remove all assembly", false, false);
  static RegisterPass<SplitLowPass> Xlow("Psplit-asm-low",
      "keep only assembly", false, false);

}
