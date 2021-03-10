#include "llvm/Analysis/LoopPass.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils.h"

#include "ConfigPrime.h"
#include "interpreter/Interpreter.h"
#include "transforms/utils/BasicBlockUtils.hh"

using namespace llvm;

static cl::opt<std::string> InputFile("Pconfig-prime-file", cl::Hidden,
                                      cl::desc("Specify input bitcode"));

static cl::list<std::string>
    InputArgv("Pconfig-prime-input-arg", cl::Hidden,
              cl::desc("Specify one known program argument"));

static cl::opt<unsigned>
    UnknownArgs("Pconfig-prime-unknown-args", cl::Hidden, cl::init(0),
                cl::desc("Specify the number of unknown parameters"));

namespace previrt {

/** Begin helpers **/

static Loop *getRootLoop(LoopInfo &LI, const BasicBlock *B) {
  if (Loop *Root = LI.getLoopFor(B)) {
    while (Root->getLoopDepth() > 1) {
      Root = Root->getParentLoop();
    }
    return Root;
  }
  return nullptr;
}

static std::vector<GenericValue>
prepareArgumentsForMain(Function *mainFn,
                        // argc >= len(argv)
                        unsigned argc, const std::vector<std::string> &argv,
                        const std::vector<std::string> &envp,
                        ExecutionEngine &EE, ArgvArray &CArgv,
                        ArgvArray &CEnv) {
  std::vector<GenericValue> GVArgs;
  GenericValue GVArgc;
  GVArgc.IntVal = APInt(32, argc);

  // Check main() type
  unsigned NumArgs = mainFn->getFunctionType()->getNumParams();
  FunctionType *FTy = mainFn->getFunctionType();
  Type *PPInt8Ty = Type::getInt8PtrTy(mainFn->getContext())->getPointerTo();

  // Check the argument types.
  if (NumArgs > 3)
    report_fatal_error("Invalid number of arguments of main() supplied");
  if (NumArgs >= 3 && FTy->getParamType(2) != PPInt8Ty)
    report_fatal_error("Invalid type for third argument of main() supplied");
  if (NumArgs >= 2 && FTy->getParamType(1) != PPInt8Ty)
    report_fatal_error("Invalid type for second argument of main() supplied");
  if (NumArgs >= 1 && !FTy->getParamType(0)->isIntegerTy(32))
    report_fatal_error("Invalid type for first argument of main() supplied");
  if (!FTy->getReturnType()->isIntegerTy() && !FTy->getReturnType()->isVoidTy())
    report_fatal_error("Invalid return type of main() supplied");

  if (NumArgs) {
    // Arg #0 = argc.
    GVArgs.push_back(GVArgc);
    if (NumArgs > 1) {
      // Arg #1 = argv.
      GVArgs.push_back(PTOGV(CArgv.reset(mainFn->getContext(), &EE, argv)));

      // assert(!isTargetNullPtr(this, GVTOP(GVArgs[1])) &&
      //        "argv[0] was null after CreateArgv");
      /// XXX: ignore for now envp
      // if (NumArgs > 2) {
      //   std::vector<std::string> EnvVars;
      //   for (unsigned i = 0; envp[i]; ++i)
      //     EnvVars.emplace_back(envp[i]);
      //   // Arg #2 = envp.
      // GVArgs.push_back(PTOGV(CEnv.reset(mainFn->getContext(), &EE,
      // EnvVars)));
      //}
    }
  }
  return GVArgs;
}

static void
extractValuesFromRun(Interpreter &Interp, Pass *CPPass,
                     DenseMap<Value *, RawAndDerefValue> &GlobalValues,
                     DenseMap<Value *, RawAndDerefValue> &StackValues,
                     SmallVector<BasicBlock *, 4> &Continuations) {

  BasicBlock *LastExecBlock =
      Interp.inspectStackAndGlobalState(GlobalValues, StackValues);

#if 0
  if (LastExecBlock) {
    // This is typically a bad choice because if LastExecBlock is in
    // the middle of a loop won't dominate "relevant" uses.
    Continuations.push_back(LastExecBlock);
  } else {
    errs() << "The interpreter finished completely!\n";
  }
#else
  // If the last executed block BB is not inside any loop then the
  // continuation should be BB.  Otherwise, we identify the outermost
  // loop where BB is defined and return the exit block or blocks of
  // that loop.
  //
  // My intuition is that the execution will be typically stopped in
  // the middle of the get-opt loop that reads input parameters. We
  // pretend that the rest of the loop won't modify either globalVals
  // or stackVals.
  if (LastExecBlock) {
    // errs() << "Last executed block: " << LastExecBlock->getName() << "\n";
    Function &F = *(LastExecBlock->getParent());
    LoopInfo &LI = CPPass->getAnalysis<LoopInfoWrapperPass>(F).getLoopInfo();
    if (Loop *OuterMostL = getRootLoop(LI, LastExecBlock)) {
      // XXX: only for LLVM debug builds:
      // OuterMostL->dump();
      //// Consider the outermost loop's header as continuation.
      // Continuations.push_back(OuterMostL->getHeader());
      // errs() << "Candidate for continuation block: "
      //       << OuterMostL->getHeader()->getName() << "\n";

      //// Consider the outermost loop's exits as continuations.
      OuterMostL->getExitingBlocks(Continuations);

      errs() << "Candidates for continuation block:\n";
      for (BasicBlock *Exit : Continuations) {
        if (Exit->hasName()) {
          errs() << "\t" << Exit->getName() << "\n";
        } else {
          errs() << "\t"
                 << "Unnamed block\n";
        }
      }
    } else {
      // errs() << "Candidate for continuation block: "
      // 	     << LastExecBlock->getName() << "\n";
      Continuations.push_back(LastExecBlock);
    }
  } else {
    errs() << "The interpreter finished completely!\n";
  }
#endif
}

static Constant *convertToLLVMConstant(Type *Ty, GenericValue &Val) {
  switch (Ty->getTypeID()) {
  case Type::IntegerTyID:
    return ConstantInt::get(Ty, Val.IntVal);
  case Type::FloatTyID:
    return ConstantFP::get(Ty, Val.FloatVal);
  case Type::DoubleTyID:
    return ConstantFP::get(Ty, Val.DoubleVal);
  case Type::VectorTyID: {
    auto *VT = cast<VectorType>(Ty);
    Type *ElemT = VT->getElementType();
    unsigned numElems = VT->getNumElements();
    std::vector<Constant *> VElems;
    for (unsigned i = 0; i < numElems; ++i) {
      if (Constant *C = convertToLLVMConstant(ElemT, Val.AggregateVal[i])) {
        VElems.push_back(C);
      } else {
        return nullptr;
      }
    }
    return ConstantVector::get(VElems);
  }
  case Type::PointerTyID: // (void*) Val.PointerVal
  case Type::X86_FP80TyID:
  default:
    return nullptr;
  }
}

// Return true if a block in BBs dominates I.
// This might be unsound.
static bool may_dominate(const SmallVector<BasicBlock *, 4> &BBs,
                         Instruction *I, Pass *CPPass) {
  assert(!BBs.empty());
  // we know already that all BBs belong to the same parent.

  Function *F = I->getParent()->getParent();
  Function *BBs_F = (*(BBs.begin()))->getParent();
  if (F != BBs_F)
    return false;

  auto &DT = CPPass->getAnalysis<DominatorTreeWrapperPass>(*F).getDomTree();
  auto &LI = CPPass->getAnalysis<LoopInfoWrapperPass>(*F).getLoopInfo();
  // DT.print(errs());

  return std::any_of(BBs.begin(), BBs.end(),
                     [&DT, &LI, &I](const BasicBlock *B) {
                       auto RootLoop_B = getRootLoop(LI, B);
                       auto RootLoop_I = getRootLoop(LI, I->getParent());
                       if (RootLoop_B && (RootLoop_B == RootLoop_I)) {
                         // Heuristic to increase soundness if B is a loop
                         // header.
                         return false;
                       } else {
                         return DT.dominates(B, I->getParent());
                       }
                     });
}

/** End helpers **/

ConfigPrime::ConfigPrime() : ModulePass(ID), m_ee(nullptr) {}

ConfigPrime::~ConfigPrime() {}

void ConfigPrime::runInterpreterAsMain(Module &M, APInt &Res) {

  Function *main = m_ee->FindFunctionNamed("main");
  if (!main) {
    errs() << "ConfigPrimer error: the interpreter only runs on main\n";
    return;
  }

  // Run static constructors.
  m_ee->runStaticConstructorsDestructors(false);

  // Run main
  std::vector<std::string> mainArgV;
  // Add the module's name to the start of the vector of arguments to main().
  mainArgV.push_back(InputFile);
  unsigned i = 1;
  for (auto a : InputArgv) {
    errs() << "ConfigPrime: reading argv[" << i++ << "] " << a << "\n";
    mainArgV.push_back(a);
  }
  unsigned argc = mainArgV.size() + UnknownArgs;
  std::vector<std::string> envp; /* unused */
  ArgvArray CArgv, CEnv; // they need to be alive while m_ee may use them
  std::vector<GenericValue> mainArgVGV =
      prepareArgumentsForMain(main, argc, mainArgV, envp, *m_ee, CArgv, CEnv);

  GenericValue GVResult =
      m_ee->runFunction(main, ArrayRef<GenericValue>(mainArgVGV));
  Res = GVResult.IntVal;
  errs() << "ConfigPrime: execution of main returned with status " << Res
         << "\n";
}

void ConfigPrime::stopInterpreter(Module &M, const APInt &Res) {
  // Run static destructors.
  m_ee->runStaticConstructorsDestructors(true);

#if 0
  // If the program didn't call exit explicitly, we should call it now.
  // This ensures that any atexit handlers get called correctly.
  auto &Context = M.getContext();
  Constant *Exit = M.getOrInsertFunction("exit", Type::getVoidTy(Context),
  					 Type::getInt32Ty(Context));
  if (Function *ExitF = dyn_cast<Function>(Exit)) {
    std::vector<GenericValue> Args;
    GenericValue GVRes;
    GVRes.IntVal = Res;
    Args.push_back(GVRes);
    m_ee->runFunction(ExitF, Args);
    errs() << "ConfigPrime: exit(" << GVRes.IntVal << ") returned!\n";
  } else {
    errs() << "ConfigPrime: exit defined with wrong prototype!\n";
  }
#endif
}

static bool simplifyPrefix
(Interpreter &Interp, Pass *CPPass,
 DenseMap<Value *, RawAndDerefValue> &StackValues,
 const std::vector<Instruction*> & VisitedInstructions) {
  
  bool Change = false;
  return Change;
}

// Simplify parts of the code that has not been executed by the
// interpreter (we call it suffixes). We do that by identifying
// information from the executed path (we call it prefix) that can be
// used to simplify unseen code.
static bool simplifySpeculativelySuffixes
(Interpreter &Interp, Pass *CPPass,
 BasicBlock *LastBlock,
 DenseMap<Value *, RawAndDerefValue> &GlobalValues,
 DenseMap<Value *, RawAndDerefValue> &StackValues) {
  
  if (!LastBlock) {
    return false;
  }
  
  // 1. Identify the basic block(s) on which we are going to take the
  // memory snapshot.
  // 
  // If the last executed block BB is not inside any loop then the
  // continuation should be BB.  Otherwise, we identify the outermost
  // loop where BB is defined and return the exit block or blocks of
  // that loop.  My intuition is that the execution will be typically
  // stopped in the middle of the get-opt loop that reads input
  // parameters. We pretend that the rest of the loop won't modify
  // either globalVals or stackVals.
  bool Change = false;
  SmallVector<BasicBlock *, 4> MemSnapshots;
  Function &F = *(LastBlock->getParent());
  LoopInfo &LI = CPPass->getAnalysis<LoopInfoWrapperPass>(F).getLoopInfo();
  if (Loop *OuterMostL = getRootLoop(LI, LastBlock)) {
    //// Consider the outermost loop's exits as continuations.
    OuterMostL->getExitingBlocks(MemSnapshots);
    errs() << "Candidates for continuation block:\n";
    for (BasicBlock *Exit : MemSnapshots) {
      if (Exit->hasName()) {
	errs() << "\t" << Exit->getName() << "\n";
      } else {
	errs() << "\t"
	       << "Unnamed block\n";
      }
    }
  } else {
    MemSnapshots.push_back(LastBlock);
  }

  // 2. Replace left-hand side of LoadInst instructions with values
  // obtained from the memory snapshot. The difficult part is to
  // ensure that the memory location that is being accessed has not
  // been modified since the snapshot was taken. 
  if (!MemSnapshots.empty()) {
    // Sanity check
    BasicBlock *ContBB = *(MemSnapshots.begin());
    auto it = MemSnapshots.begin();
    (void)ContBB; // avoid warning in non-debug builds
    (void)it;     // avoid warning in non-debug builds
    assert(
        std::all_of(++it, MemSnapshots.end(), [&ContBB](const BasicBlock *B) {
          return ContBB->getParent() == B->getParent();
        }));

    auto replaceValues = [&MemSnapshots, &CPPass](
        DenseMap<Value *, RawAndDerefValue> &m, bool &change) {
      for (auto &kv : m) {
        if (kv.second.hasDerefValue()) {
          Type *ElementType = kv.first->getType()->getPointerElementType();
          GenericValue ElementVal = kv.second.getDerefValue();
          if (Constant *C = convertToLLVMConstant(ElementType, ElementVal)) {
            for (auto &U : kv.first->uses()) {
              if (LoadInst *LI = dyn_cast<LoadInst>(U.getUser())) {
                if (may_dominate(MemSnapshots, LI, CPPass)) {
                  errs() << "Replaced "
                         << "lhs of " << *LI << " with " << *C << "\n";
                  errs() << *(LI->getParent()) << "\n";
                  LI->replaceAllUsesWith(C);
                  change = true;
                }
              }
            }
          }
        }
      }
    };

    // TOIMPROVE: this is very limited.
    // We only replace loads from global variables with the
    // constant values from the interpreter's execution. More
    // importantly, we only perform the replacement if the memory load
    // and the last executed block belong to the same function.
    replaceValues(GlobalValues, Change);
    //replaceValues(StackValues, Change);
  } 
  
  return Change;
  
}
  
bool ConfigPrime::runOnModule(Module &M) {
  // TODO: Similar to lli, we can provide other modules, extra objects
  // or archives.

  APInt Res; // The exit status of running main
  std::string ErrorMsg;
  std::unique_ptr<Module> M_ptr(&M);
  EngineBuilder builder(std::move(M_ptr));
  builder.setErrorStr(&ErrorMsg);
  builder.setEngineKind(EngineKind::Interpreter); // LLVM Interpreter

  // m_ee = llvm::make_unique<ExecutionEngine>(builder.create());
  std::unique_ptr<ExecutionEngine> EE(builder.create());
  m_ee = std::move(EE);

  if (!m_ee) {
    if (!ErrorMsg.empty())
      errs() << "Error creating EE: " << ErrorMsg << "\n";
    else
      errs() << "Unknown error creating EE!\n";
    return false;
  }

  runInterpreterAsMain(M, Res);

  /// -- Extract values from the execution
  Interpreter *Interp = static_cast<Interpreter *>(&*m_ee);
  if (Interp->exitExecuted()) {
    errs() << "****************************************************************\n"; 
    errs() << "************************* WARNING ******************************\n";
    errs() << "****************************************************************\n";
    errs() << "The exit() function has been called during Configuration Prime.\n";
    errs() << "This might be because the program environment is not the\n"
           << "expected one (e.g., some file does not exist, no file permissions,etc).\n";
    errs() << "****************************************************************\n";	      
  }
  
  DenseMap<Value *, RawAndDerefValue> GlobalValues, StackValues;
  BasicBlock *LastExecBlock =
    Interp->inspectStackAndGlobalState(GlobalValues, StackValues);

  #if 0 /* PRETTY-PRINTER */
  auto printValueMap = [](DenseMap<Value*,RawAndDerefValue> &m, raw_ostream &o) {
    for (auto &kv: m) {
      if (kv.second.hasDerefValue()) {
	o << "*(" << kv.first->getName() << ")=";
	printAbsGenericValue(kv.first->getType()->getPointerElementType(),
			     kv.second.getDerefValue());
      } else {
	o << kv.first->getName() << "=";	  
	printAbsGenericValue(kv.first->getType(), kv.second.getRawValue());
      }
      o << "\n";
    }
  };
  errs() << "Global values:\n";
  printValueMap(GlobalValues, errs());
  errs() << "Local values:\n";
  printValueMap(StackValues, errs());
  #endif
  
  if (!LastExecBlock) {
    errs() << "****************************************************************\n";
    errs() << "           The interpreter finished completely!\n";
    errs() << "****************************************************************\n";    

    // Best case scenario: The interpreter finishes so the program can
    // be reduced to one single execution.
    std::vector<BasicBlock *> toRemove;
    for (auto &F : M) {
      for (auto &BB : F) {
        if (!Interp->isExecuted(BB)) {
	  errs() << "ConfigPrime: removing unreachable block "
		 << BB.getName() << "\n";
          toRemove.push_back(&BB);
        }
      }
    }
    while (!toRemove.empty()) {
      BasicBlock *BB = toRemove.back();
      toRemove.pop_back();
      previrt::transforms::removeBlock(BB, M.getContext());
    }

    // I think it makes sense to call the destructors and
    // finalization routines if the execution finished.
    stopInterpreter(M, Res);
    return true;
  }

  bool Change = simplifyPrefix(*Interp, this, StackValues,
			       Interp->getVisitedInstructions());
  Change |= simplifySpeculativelySuffixes(*Interp, this, LastExecBlock, 
					  GlobalValues, StackValues);
  return Change;
}

void ConfigPrime::getAnalysisUsage(AnalysisUsage &AU) const {
  // TODOX: update on the fly
  // AU.setPreservesAll();
  AU.addRequiredID(LoopSimplifyID);
  AU.addRequired<LoopInfoWrapperPass>();
  AU.addRequired<DominatorTreeWrapperPass>();
}

} // end namespace previrt

char previrt::ConfigPrime::ID = 0;

static RegisterPass<previrt::ConfigPrime> X("Pconfig-prime",
                                            "Configuration priming");
