//
// OCCAM
//
// Copyright (c) 2011-2020, SRI International
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

/**
 *  Inter-module specialization.
 *  Interfaces are modified but callsites are not. The callsites will
 *  be modified by InterRewriter
 **/

#include "llvm/Pass.h"
#include "llvm/ADT/SmallBitVector.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CallSite.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "PrevirtualizeInterfaces.h"
#include "Specializer.h"
#include "SpecializationPolicy.h"
/* here specialization policies */
#include "AggressiveSpecPolicy.h"
#include "RecursiveGuardSpecPolicy.h"
#include "BoundedSpecPolicy.h"
#include "OnlyOnceSpecPolicy.h"

#include <vector>
#include <string>
#include <fstream>
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

static cl::opt<previrt::SpecializationPolicyType>
SpecPolicy("Pspecialize-policy",
	cl::desc("Inter-module specialization policy"),
	cl::values
       (clEnumValN(previrt::SpecializationPolicyType::NOSPECIALIZE, "nospecialize",
		   "Skip inter-module specialization"),
	clEnumValN(previrt::SpecializationPolicyType::AGGRESSIVE, "aggressive",
		   "Specialize always if some constant argument"),
	clEnumValN(previrt::SpecializationPolicyType::ONLY_ONCE, "onlyonce",
		   "Specialize a function if it is called once"),
	clEnumValN(previrt::SpecializationPolicyType::BOUNDED, "bounded",
		   "Always specialize if number of copies so far <= Ppeval-max-spec-copies"),
	clEnumValN(previrt::SpecializationPolicyType::NONREC, "nonrec-aggressive",
		   "Specialize always if some constant arg and function is non-recursive")),
        cl::init(previrt::SpecializationPolicyType::NONREC));

static cl::opt<unsigned>
MaxSpecCopies("Pspecialize-max-bounded", 
	   cl::init(5),
	   cl::desc("Maximum number of copies for a function if -Pspecialize-policy=bounded"));

static cl::list<std::string>
SpecCompIn("Pspecialize-input",
	   cl::NotHidden,
	   cl::desc("Specify the interface to specialize with respect to"));
  
static cl::opt<std::string>
SpecCompOut("Pspecialize-output",
	    cl::init(""),
	    cl::NotHidden,
	    cl::desc("Specify the output file for the specialized module"));

namespace previrt
{

  static Function* resolveFunction(Module& M, StringRef name) {
    if (Function* f = M.getFunction(name)) {
      return f;
    }
    
    if (GlobalAlias* ga = M.getNamedAlias(name)) {
      const GlobalValue* v = ga->getBaseObject();
      if (Function* f = dyn_cast<Function>(const_cast<GlobalValue*>(v))) {
        return f;
      }
    }
    return nullptr;
  }

  /*
   * Reduce this module with respect to the given interface.
   * - The interface suggests some of the uses of the functions,
   *   so here we can generate special versions of those functions.
   * Generate a ComponentInterfaceTransform for clients to rewrite their
   * code to use the new API
   */
  static bool SpecializeComponent(Module& M, ComponentInterfaceTransform& T,
				  SpecializationPolicy& policy,
				  std::vector<Function*>& to_add) {
    errs() << "SpecializeComponent()\n";

    int rewrite_count = 0;
    const ComponentInterface& I = T.getInterface();
    // TODO: What needs to be done?
    // - Should try to handle strings & arrays
    // Iterate through all functions in the interface of T
    for (ComponentInterface::FunctionIterator ff = I.begin(), fe = I.end(); ff
        != fe; ++ff) {
      StringRef name = ff->first();
      Function* func = resolveFunction(M, name);

      if (!func || func->isDeclaration()) {
        continue;
      }

      // Now iterate through all calls to func in the interface of T
      for (ComponentInterface::CallIterator cc = I.call_begin(name), ce =
          I.call_end(name); cc != ce; ++cc) {
        const CallInfo* const call = *cc;
        const unsigned arg_count = call->args.size();
        if (func->isVarArg()) {
          continue;
        }

        if (arg_count != func->arg_size()) {
          // Not referring to this function?
          // NOTE: I can't assert this equality because of the way that approximations occur
          continue;
        }

	/*
	  should we specialize? if yes then each bit in marks will
	  indicate whether the argument is a specializable constant
	 */
        SmallBitVector marks(arg_count);
        bool shouldSpecialize = policy.interSpecializeOn(*func, call->args, I, marks);
						     

        if (!shouldSpecialize)
          continue;

        std::vector<Value*> args;
        std::vector<unsigned> argPerm;
        args.reserve(arg_count);
        argPerm.reserve(marks.count());
        for (unsigned i = 0; i < arg_count; i++) {
          if (marks.test(i)) {
	      Type * paramType = func->getFunctionType()->getParamType(i);
	      Value *concreteArg = call->args[i].concretize(M, paramType);
	      args.push_back(concreteArg);
	      assert(concreteArg->getType() == paramType
		     && "Specializing function with concrete argument of wrong type!");
          } else {
            args.push_back(nullptr);
            argPerm.push_back(i);
          }
        }
	
	/*
	  args is a list of pointers to values
	   -- if the pointer is nullptr then that argument is not
               specialized.
	   -- if the pointer is not nullptr then the argument will be/has
              been specialized to that value.

	  argsPerm is a list on integers; the indices of the non-special arguments
	  args[i] = nullptr iff i is in argsPerm for i < arg_count.
	*/

        Function* specialized_func = specializeFunction(func, args);
	if (!specialized_func) {
	  continue;
	}
        specialized_func->setLinkage(GlobalValue::ExternalLinkage);
        FunctionHandle rewriteTo = specialized_func->getName();
        T.rewrite(name, call, rewriteTo, argPerm);
        to_add.push_back(specialized_func);
	errs() << "Specialized  " << name << " to " << rewriteTo << "\n";

        #if 0
	for (unsigned i = 0; i < arg_count; i++) {
	  errs() << "i = " << i << ": marks[i] = " << marks[i]
		 << " args[i] = " << args.at(i) << "\n";
	}
	errs() << " argPerm = [";
	for (unsigned i = 0; i < argPerm.size(); i++) {
	  errs() << argPerm.at(i) << " ";
	}
	errs() << "]\n";
        #endif

       rewrite_count++;
      }
    }
    if (rewrite_count > 0) {
      errs() << rewrite_count << " pending rewrites\n";
    }
    return rewrite_count > 0;
  }
}

namespace previrt {
  
  class InterSpecializerPass : public ModulePass {
  public:
    
    ComponentInterfaceTransform transform;
    static char ID;

  public:
    
    InterSpecializerPass()
      : ModulePass(ID) {
      
      errs() << "InterSpecializerPass():\n";
      for (cl::list<std::string>::const_iterator b = SpecCompIn.begin(),
	     e = SpecCompIn.end(); b != e; ++b) {
        errs() << "Reading file '" << *b << "'...";
        if (transform.readInterfaceFromFile(*b)) {
          errs() << "success\n";
        } else {
          errs() << "failed\n";
        }
      }
      
      errs() << "Done reading.\n";
      if (transform.interface != nullptr) {
        errs() << transform.interface->calls.size() << " calls\n";
      } else {
        errs() << "No interfaces read.\n";
      }
    }
    
    virtual ~InterSpecializerPass() {}
          
    virtual bool runOnModule(Module& M) {    
      if (!transform.interface) {
	return false;
      }

      // -- Create the specialization policy. Bail out if no policy.
      std::unique_ptr<SpecializationPolicy> policy;
      switch (SpecPolicy) {
      case SpecializationPolicyType::NOSPECIALIZE:
	return false;
      case SpecializationPolicyType::AGGRESSIVE:
	policy.reset(new AggressiveSpecPolicy());
	break;
      case SpecializationPolicyType::BOUNDED: {
	std::unique_ptr<SpecializationPolicy> subpolicy =
	  llvm::make_unique<AggressiveSpecPolicy>();
	policy.reset(new BoundedSpecPolicy(M, std::move(subpolicy), MaxSpecCopies));
	break;
      }
      case SpecializationPolicyType::ONLY_ONCE:
	policy.reset(new OnlyOnceSpecPolicy());
	break;
      case SpecializationPolicyType::NONREC: {
	std::unique_ptr<SpecializationPolicy> subpolicy =
	  llvm::make_unique<AggressiveSpecPolicy>();
	CallGraph& cg = getAnalysis<CallGraphWrapperPass>().getCallGraph();      
	policy.reset(new RecursiveGuardSpecPolicy(std::move(subpolicy), cg));
      break;
      }
      default:;;
      }
      
      if (!policy) {
	return false;
      }
      
      errs() << "InterSpecializerPass::runOnModule(): " << M.getModuleIdentifier() << "\n";
      std::vector<Function*> to_add;
      bool modified = SpecializeComponent(M, transform, *policy, to_add);
      
      /*
	 adding the "new" specialized definitions (in to_add) to M;
	 opt will write out M to the -o argument to the "python call"
      */
      Module::FunctionListType &functionList = M.getFunctionList();
      while (!to_add.empty()) {
	Function *add = to_add.back();
	to_add.pop_back();
	if (add->getParent() == &M) {
	  // Already in module
	  continue;
	} else {
	  errs() << "Adding \"" << add->getName() << "\" to the module.\n";
	  functionList.push_back(add);
	}
      }

      /* writing the output ("rw" rewrite file) to the -Pspecialize-output argument */
      if (SpecCompOut != "") {
        proto::ComponentInterfaceTransform buf;
        codeInto(this->transform, buf);
        std::ofstream output(SpecCompOut.c_str(),
			     std::ios::binary | std::ios::trunc);
	bool success = buf.SerializeToOstream(&output);
	if (!success) {
	  assert (false && "failed to write out interface");
	}
        output.close();
      }
      
      return modified;
    }
    
    virtual void getAnalysisUsage(AnalysisUsage &AU) const {
      AU.addRequired<CallGraphWrapperPass> ();
    }
    
  };
  char InterSpecializerPass::ID;
} // end namespace previrt

static RegisterPass<previrt::InterSpecializerPass>
X("Pspecialize",
  "Specialize the inter-module interface",
  false, false);
