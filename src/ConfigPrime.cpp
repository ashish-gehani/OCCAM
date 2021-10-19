#include "llvm/ADT/SCCIterator.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Analysis/LoopPass.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

#include "ConfigPrime.h"
#include "interpreter/Interpreter.h"
#include "transforms/utils/BasicBlockUtils.hh"

#include "seadsa/InitializePasses.hh"
#include "seadsa/support/RemovePtrToInt.hh"

using namespace llvm;

namespace previrt {
unsigned CP_FirstUnknownIndex;
unsigned CP_UnknownArgs;
bool CP_SpecOnlyGlobals;
} //end namespace previrt

static cl::opt<std::string> InputFile("Pconfig-prime-file", cl::Hidden,
                                      cl::desc("Specify input bitcode"));

/* unused */
static cl::list<std::string>
InputArgv("Pconfig-prime-input-arg",
	 cl::Hidden,
	 cl::desc("Specify one known program argument"));

static cl::opt<unsigned, true>
XFirstUnknownIndex("Pconfig-prime-index-first-unknown-arg",
	 cl::Hidden,
	 cl::location(previrt::CP_FirstUnknownIndex),
	 cl::init(0), 
	 cl::desc("Specify the index of the first unknown parameter starting at 1"));

static cl::opt<unsigned, true>
XUnknownArgs("Pconfig-prime-unknown-args",
	 cl::Hidden,
	 cl::location(previrt::CP_UnknownArgs),	     
	 cl::init(0),
	 cl::desc("Specify the number of unknown parameters"));

static cl::list<std::string>
DoNotSpecialize("Pconfig-prime-do-not-specialize",
  cl::Hidden,
  cl::desc("Function calls whose returned values should not be used for specialization"));

static cl::opt<bool, true>
SpecOnlyGlobals("Pconfig-prime-specialize-only-globals",
	 cl::Hidden,
	 cl::location(previrt::CP_SpecOnlyGlobals),
	 cl::init(false), 
	 cl::desc("Specialize if the constant is the value of a global variable"));

namespace previrt {

StringRef CONFIG_PRIME_STOP = "occam.config_prime.stop";
StringRef CONFIG_PRIME_UNACCESSIBLE = "occam.config_prime.unaccessible";  
  
// Instrumentation to be added before running configuration priming.
class PreConfigPrimeInst {
  llvm::FunctionCallee m_stopConfigPrime;
  llvm::FunctionCallee m_markAsUnaccessible;
  GlobalVariable *m_optind;
  ConstantInt *m_firstUnknownIdx;
  bool transformGetOptFn(llvm::Function &F);
  bool transformOptArgLoad(Function &F);
public:
  PreConfigPrimeInst();
  ~PreConfigPrimeInst() = default;
  bool runOnModule(llvm::Module &M);
  bool runOnFunction(llvm::Function &F);  
};
  
// Instrumentation to be added/removed after running configuration
// priming.
class PostConfigPrimeInst{
  void undoGetOptFnTransform(llvm::Function &F);
  void undoOptArgLoadTransform(llvm::Function &F);
public:
  PostConfigPrimeInst();
  ~PostConfigPrimeInst() = default;
  bool runOnModule(llvm::Module &M);
  bool runOnFunction(llvm::Function &F);  
};
  
/** Begin helpers **/

// pre: strArg.size() == 1
// pre: strArg[0] contains the program name  
// pre: argc >= 1 where argc-1 are the dynamic (unknown) arguments.
static std::vector<GenericValue>
prepareArgumentsForMain(Function *mainFn,
                        // argc >= len(strArgv)
                        unsigned argc, const std::vector<std::string> &strArgv,
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
      // Turn a vector of strings into a nice argv style array of pointers to null
      // terminated strings.
      void* argv = (void*)CArgv.reset(mainFn->getContext(), &EE, strArgv);
      GVArgs.push_back(PTOGV(argv));

      errs() << "argc=" << argc << "\n";
      errs() << "argv starts at address=" << argv << "\n";
#ifdef TRACK_ONLY_UNACCESSIBLE_MEM
       Interpreter *Interp = static_cast<Interpreter *>(&EE);
       unsigned PtrSize = EE.getDataLayout().getPointerSize();
       intptr_t addr = (intptr_t) argv;
       size_t offset = PtrSize; // skips the program name
       errs() << "-- Begin marking as unaccessible dynamic arguments\n";
       for (unsigned i=1;i<argc;i++) {
	 // iterate argc-1 times (one per dynamic argument)
	 // 
	 // initialize here means mark the addresses of all dynamic
	 // arguments as unaccessible
	 Interp->initializeMainParams((void*)(addr+offset), PtrSize);
       }
       errs() << "-- End marking as unaccessible dynamic arguments\n";       
#endif      
      // assert(!isTargetNullPtr(this, GVTOP(GVArgs[1])) &&
      //        "strArgv[0] was null after CreateArgv");
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

  static bool equal(Type *Ty, GenericValue &Val1, GenericValue &Val2) {
  switch (Ty->getTypeID()) {
  case Type::IntegerTyID:
    return Val1.IntVal == Val2.IntVal;
  case Type::FloatTyID:
    return Val1.FloatVal == Val2.FloatVal;
  case Type::DoubleTyID:
    return Val1.DoubleVal == Val2.DoubleVal; 
  case Type::VectorTyID: {
    auto *VT = cast<VectorType>(Ty);
    Type *ElemT = VT->getElementType();
    unsigned numElems = VT->getNumElements();
    std::vector<Constant *> VElems;
    for (unsigned i = 0; i < numElems; ++i) {
      // -- be careful there is a recursive call
      if (!equal(Ty, Val1.AggregateVal[i], Val2.AggregateVal[i])) {
	return false;
      }
    }
    return true;
  }
  case Type::PointerTyID: 
  case Type::X86_FP80TyID:
  default:
    return false;
  }
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

static Loop *getRootLoop(LoopInfo &LI, const BasicBlock &B) {
  if (Loop *Root = LI.getLoopFor(&B)) {
    while (Root->getLoopDepth() > 1) {
      Root = Root->getParentLoop();
    }
    return Root;
  }
  return nullptr;
}
  
// Return true if a block in BBs dominates I.
// This might be unsound.
static bool mayDominate(const SmallVector<BasicBlock *, 4> &BBs,
                         Instruction *I, Pass &CPPass) {
  assert(!BBs.empty());
  // we know already that all BBs belong to the same parent.

  Function *F = I->getParent()->getParent();
  Function *BBs_F = (*(BBs.begin()))->getParent();
  if (F != BBs_F)
    return false;

  auto &DT = CPPass.getAnalysis<DominatorTreeWrapperPass>(*F).getDomTree();
  auto &LI = CPPass.getAnalysis<LoopInfoWrapperPass>(*F).getLoopInfo();
  // DT.print(errs());

  return std::any_of(BBs.begin(), BBs.end(),
                     [&DT, &LI, &I](const BasicBlock *B) {
                       auto RootLoop_B = getRootLoop(LI, *B);
                       auto RootLoop_I = getRootLoop(LI, *(I->getParent()));
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

  errs() << "STARTED interpreter from main\n";
  
  // Run main
  std::vector<std::string> mainArgV;
  // Add the module's name to the start of the vector of arguments to main().
  mainArgV.push_back(InputFile);
  unsigned i = 1;

  // InputArgv is unused so this loop is not executed
  for (auto a : InputArgv) {
    errs() << "ConfigPrime: reading argv[" << i++ << "] " << a << "\n";
    mainArgV.push_back(a);
  }
  
  unsigned argc = mainArgV.size() + CP_UnknownArgs;
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

  
static void markRecursiveFunctions(CallGraph &cg, DenseSet<Function*> &out) {
  for (auto it = scc_begin(&cg); !it.isAtEnd(); ++it) {
    auto &scc = *it;
    bool recursive = false;
    if (scc.size() == 1 && it.hasLoop()) {
      // direct recursive
      recursive = true;
    } else if (scc.size() > 1) {
      // indirect recursive
      recursive = true;
    }
    if (recursive) {
      for (CallGraphNode *cgn : scc) {
        Function *fn = cgn->getFunction();
        if (!fn || fn->isDeclaration() || fn->empty()) {
          continue;
        }
        out.insert(fn);
      }
    }
  }
}
  
// static bool isSafeToReplace(Instruction &I,
// 			    DenseMap<BasicBlock*, bool> &blocksInLoops,
// 			    const DenseSet<Function*> &recursiveFunctions,
// 			    Pass &CPPass) {
//   BasicBlock &B = *(I.getParent());  
//   if (recursiveFunctions.count(B.getParent()) > 0) {
//     errs() << "\t" << B.getName() << " is marked as recursive\n";
//     return false;
//   }
  
//   auto it = blocksInLoops.find(&B);
//   if (it != blocksInLoops.end()) {
//     if (it->second) {
//       errs() << "\t" << B.getName() << " inside a loop [CACHE]\n";      
//     }
//     return it->second;
//   } else {
//     Function &F = *(B.getParent());
//     LoopInfo &LI = CPPass.getAnalysis<LoopInfoWrapperPass>(F).getLoopInfo();
//     bool isInsideLoop = false;    
//     if (auto Loop = LI.getLoopFor(&B)) {
//       isInsideLoop = true;
//       errs() << "\t" << B.getName() << " inside a loop " << *Loop << "\n";
//     }
//     // cache for later
//     blocksInLoops[&B] = isInsideLoop;
//     return (!isInsideLoop);
//   }
// }
  
static bool simplifyPrefix(Interpreter &Interp, Pass &CPPass,
       const std::vector<std::pair<Instruction*, GenericValue>>& ExecutedMemInsts) {
  // ExecutedMemInsts can contain the same instruction multiple times
  // with possibly different values if the execution went through a
  // loop. replaceMap creates a map where the key is an instruction
  // and its value is a vector of values: one for each possible value
  // of the instruction if the instruction is executed multiple times.

  
  int64_t smallestAddr = (int64_t)Interp.getSmallestAllocatedAddr();   
  errs() << "Hint: smallest address allocated by the interpreter: "
	 << smallestAddr << "\n";
  
  auto integerLooksAddress = [&smallestAddr](const APInt &n) -> bool {
    if (smallestAddr == 0) {
      return false;
    }
    return n.sge(smallestAddr);
  };
  
  DenseMap<Instruction*, std::vector<GenericValue>> replaceMap;
  for(auto &kv: ExecutedMemInsts) {
    auto it = replaceMap.find(kv.first);
    if (it == replaceMap.end()) {
      std::vector<GenericValue> values{kv.second};
      replaceMap[kv.first] = values;
    } else {
      it->second.push_back(kv.second);
    }
  }
    
  // The join operation for constant propagation where constants are
  // GenericValue's
  auto constantJoin =
    [](Type *ty, const std::vector<GenericValue>& values) {
    AbsGenericValue oldAbsVal;
    for (unsigned i=0, sz=values.size(); i<sz;++i) {
      GenericValue val = values[i];
      if (oldAbsVal.hasValue()) {
	//errs() << "Joining ";
	//printAbsGenericValue(ty, oldAbsVal);
	//errs() << " and ";
	//printAbsGenericValue(ty, val);
	//errs() << "\n";
	if (!equal(ty, oldAbsVal.getValue(), val)) {
	  //errs() << "\ttop\n";	    
	  return AbsGenericValue();
	} else {
	  //errs() << "\t"; printAbsGenericValue(ty, val); errs() << "\n";
	}
      }
      oldAbsVal = AbsGenericValue(val);
    }
    return oldAbsVal;
  };
  
  // DenseMap<BasicBlock*, bool> blocksInLoops;
  // DenseSet<Function*> recursiveFunctions;
  // CallGraph &cg = CPPass.getAnalysis<CallGraphWrapperPass>().getCallGraph();
  // markRecursiveFunctions(cg, recursiveFunctions);

  auto shouldBeSpec = [](Value *v) -> bool {
    if (!CP_SpecOnlyGlobals) {
      return true;
    } else {
      return isa<GlobalVariable>(v);
    }
  };
    
  bool Change = false;
  for(auto &kv: replaceMap) {
    Instruction *I = kv.first;
    Value * valueToReplace = nullptr;

    // We only look at memory reads and writes
    if (LoadInst *LI = dyn_cast<LoadInst>(I)) {
      if (shouldBeSpec(LI->getPointerOperand())) {
	valueToReplace = LI;
      }
    } else if (StoreInst *SI = dyn_cast<StoreInst>(I)) {
      if (shouldBeSpec(SI->getPointerOperand())) {
	valueToReplace = SI->getValueOperand();
      }
      if (valueToReplace && isa<Constant>(valueToReplace)) {
	// already a constant so nothing to do
	valueToReplace = nullptr;
      }
    }
    
    if (!valueToReplace) {
      continue;
    }
    
    // if (!isSafeToReplace(*I, blocksInLoops, recursiveFunctions, CPPass)) {
    //   errs() << "[PREFIX] cannot replace " << *valueToReplace
    // 	     << " because it's not safe\n";
    //   continue;
    // }

    errs() << "[PREFIX] checking if we can simplify " << *valueToReplace <<"\n";

    Type *ty = valueToReplace->getType();
    auto &values = kv.second;
    AbsGenericValue val = constantJoin(ty, values);
    if (val.hasValue()) {
      // HACK: avoid replacing LLVM values with integers that can
      // look like addresses      
      if (ty->isIntegerTy() && integerLooksAddress(val.getValue().IntVal)) {
	errs() << "[PREFIX] skipped " << *valueToReplace << " with "
	       << val.getValue().IntVal << " because it might be an address.\n";
	continue;
      }

      if (Constant *C = convertToLLVMConstant(ty,val.getValue())) {
	errs() << "[PREFIX] replaced " << *valueToReplace
	       << " with " << *C << "\n";
	valueToReplace->replaceAllUsesWith(C);
	Change = true;
      }
      
    }
  } // end for
  
  return Change;
}

// Simplify parts of the code that has not been executed by the
// interpreter (we call it suffixes). We do that by identifying
// information from the executed path (we call it prefix) that can be
// used to simplify unseen code.
static bool simplifySpeculativelySuffixes
(Interpreter &Interp, Pass &CPPass,
 BasicBlock &LastBlock,
 DenseMap<Value *, RawAndDerefValue> &GlobalValues,
 DenseMap<Value *, std::vector<RawAndDerefValue>> &StackValues /*unused*/) {
  
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
  Function &F = *(LastBlock.getParent());
  LoopInfo &LI = CPPass.getAnalysis<LoopInfoWrapperPass>(F).getLoopInfo();
  if (Loop *OuterMostL = getRootLoop(LI, LastBlock)) {
    #if 0
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
    #endif 
  } else {
    MemSnapshots.push_back(&LastBlock);
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
		// TODO: mayDominate needs to consider memory SSA.
                if (false /*mayDominate(MemSnapshots, LI, CPPass)*/) {
                  errs() << "[SUFFIX] replaced "
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
  } 
  
  return Change;
  
}
  
bool ConfigPrime::run(Module &M) {
  // TODO: Similar to lli, we can provide other modules, extra objects
  // or archives.

  // llvm::errs() << M << "\n";
  
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

  std::set<std::string> do_not_specialize_fns{
    "socket"
      , "time"
      // it is also possible to call
      // getresuid(uid_t *ruid, uid_t *euid, uid_t *suid);   
      , "getgid"
      , "getegid"
      , "getuid"
      , "geteuid"
  };
  do_not_specialize_fns.insert(DoNotSpecialize.begin(), DoNotSpecialize.end());

  Interpreter *Interp = static_cast<Interpreter *>(&*m_ee);    
  Interp->setDoNotSpecializeFunctions(do_not_specialize_fns);
  
  runInterpreterAsMain(M, Res);

  /// -- Extract values from the execution
  if (Interp->exitNonZero()) {
    errs() << "****************************************************************\n"; 
    errs() << "************************* WARNING ******************************\n";
    errs() << "****************************************************************\n";
    errs() << "The exit() function has been called during Configuration Prime ";
    errs() << "with a non-zero value\n";
    errs() << "This might be because the program environment is not the\n"
           << "expected one (e.g., some file does not exist, no file permissions,etc).\n"
	   << "For this reason, configuration prime is disabled.\n";
    errs() << "****************************************************************\n";
    return false;
  }
  
  DenseMap<Value *, RawAndDerefValue> GlobalValues;
  DenseMap<Value *, std::vector<RawAndDerefValue>> StackValues;  
  BasicBlock *LastExecBlock =
    Interp->inspectStackAndGlobalState(GlobalValues, StackValues);

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

  bool Change = simplifyPrefix(*Interp, *this, Interp->getExecutedMemInsts());
  #if 0
  Change |= simplifySpeculativelySuffixes(*Interp, *this, *LastExecBlock, 
					  GlobalValues, StackValues);
  #endif 
  return Change;
}

bool ConfigPrime::runOnModule(Module &M) {
  PreConfigPrimeInst beforeInst;
  PostConfigPrimeInst afterInst;

  #if 1
  // We cannot schedule this pass via getAnalysisUsage because it will
  // miss the initialization.
  llvm::PassRegistry &Registry = *llvm::PassRegistry::getPassRegistry();
  llvm::initializeRemovePtrToIntPass(Registry);
  llvm::legacy::PassManager pm;
  pm.add(seadsa::createRemovePtrToIntPass());
  pm.run(M);
  #endif

  beforeInst.runOnModule(M);
  /*bool Change=*/ run(M);
  afterInst.runOnModule(M);
  // afterInst is supposed to be the inverse of beforeInst so we
  // should return true only if run(M) returns true. However,
  // afterInst is not exactly the inverse because it keeps some dead
  // code. Thus, we return true conservatively.
  return true;
}
  
void ConfigPrime::getAnalysisUsage(AnalysisUsage &AU) const {
  // TODOX: update on the fly
  // AU.setPreservesAll();
  AU.addRequiredID(LoopSimplifyID);
  //AU.addRequired<CallGraphWrapperPass>();  
  AU.addRequired<LoopInfoWrapperPass>();
  AU.addRequired<DominatorTreeWrapperPass>();
}

PreConfigPrimeInst::PreConfigPrimeInst()
  : m_stopConfigPrime(nullptr), m_markAsUnaccessible(nullptr),
    m_optind(nullptr), m_firstUnknownIdx(nullptr) {
}

bool PreConfigPrimeInst::runOnModule(Module &M) {
  LLVMContext &ctx = M.getContext();

  // find optind 
  m_optind = M.getGlobalVariable("optind");
  if (!m_optind) {
    m_optind = dyn_cast<GlobalVariable>(M.getOrInsertGlobal("optind", Type::getInt32Ty(ctx)));
    if (!m_optind) {
      return false;
    }
    m_optind->setDSOLocal(true);
    m_optind->setLinkage(GlobalValue::LinkageTypes::ExternalLinkage);
  }

  
  // m_optind should be i32*
  if (IntegerType *iTy =
      dyn_cast<IntegerType>(cast<PointerType>(m_optind->getType())->getElementType())) {
    m_firstUnknownIdx = ConstantInt::getSigned(iTy, CP_FirstUnknownIndex);
  } else {
    return false;
  }
  
  Type *voidTy = Type::getVoidTy(ctx);
  m_stopConfigPrime = M.getOrInsertFunction(CONFIG_PRIME_STOP, voidTy);

  Type *i8Ptr= Type::getInt8PtrTy(ctx);
  m_markAsUnaccessible = M.getOrInsertFunction(CONFIG_PRIME_UNACCESSIBLE, i8Ptr);  
  
  bool change = false;
  for (auto &F: M) {
    change |= runOnFunction(F);
  }
  return change;
}

/* BEFORE
   call get_opt(...);
  AFTER
   if (optind >= CP_FirstUnknownIndex) {
     config_prime.stop();
   }
   call get_opt(...);
*/ 
bool PreConfigPrimeInst::transformGetOptFn(Function &F) {
  SmallVector<CallBase*, 4> worklist;
  for (auto &B: F) {
    for (auto &I: B) {
      if (CallBase *CB = dyn_cast<CallBase>(&I)) {
	if (Function *calleeF = CB->getCalledFunction()) {
	  if (calleeF->getName() == "getopt" ||
	      calleeF->getName() == "getopt_long" ||
	      calleeF->getName() == "getopt_long_only") {
	    worklist.push_back(CB);
	  }
	}
      }
    }
  }

  bool change = !worklist.empty();
  LLVMContext &ctx = F.getParent()->getContext();
  IRBuilder<> Builder(ctx);
  while (!worklist.empty()) {
    CallBase *CB = worklist.back();
    worklist.pop_back();
    Builder.SetInsertPoint(CB);
    Value *optInvDeref = Builder.CreateLoad(m_firstUnknownIdx->getType(), m_optind);
    Value *Cond = Builder.CreateICmpSGE(optInvDeref, m_firstUnknownIdx);	    
    Instruction *ThenTerm = SplitBlockAndInsertIfThen(Cond, CB, false);
    ThenTerm->getParent()->setName("ConfigPrime");
    Builder.SetInsertPoint(ThenTerm);
    Builder.CreateCall(m_stopConfigPrime.getFunctionType(),
		       m_stopConfigPrime.getCallee(), {});
  }
  return change;
}

/* BEFORE
  bb:
   Head
   %s = load i8*, i8** @optarg
   Tail
  AFTER
  bb:
   Head
   if (optind >= CP_FirstUnknownIndex) 
     ThenBlock
   else
     ElseBlock
   %s = load i8 ... <- remove
   Tail' 

  ThenBlock:
    %s1 = config_prime.mark_as_unaccessible();;
    goto ...
  ElseBlock:
    %s2 = load i8*, i8** @optarg
    goto ... 
  Tail':
    %s = phi (s1, ThenBlock) (s2 ElseBlock)
*/ 
bool PreConfigPrimeInst::transformOptArgLoad(Function &F) {
  SmallVector<LoadInst*, 4> worklist;
  for (auto &B: F) {
    for (auto &I: B) {
      if (LoadInst *LI = dyn_cast<LoadInst>(&I)) {
	if (GlobalVariable *GV = dyn_cast<GlobalVariable>(LI->getPointerOperand())) {
	  if (GV->getName() == "optarg") {
	    worklist.push_back(LI);
	  }
	}
      }
    }
  }

  bool change = !worklist.empty();
  LLVMContext &ctx = F.getParent()->getContext();
  IRBuilder<> Builder(ctx);
  while (!worklist.empty()) {
    LoadInst *LI = worklist.back();
    worklist.pop_back();
    Builder.SetInsertPoint(LI);
    Value *optInvDeref = Builder.CreateLoad(m_firstUnknownIdx->getType(), m_optind);
    Value *Cond = Builder.CreateICmpSGE(optInvDeref, m_firstUnknownIdx);
    Instruction *ThenTerm = nullptr;
    Instruction *ElseTerm = nullptr;
    SplitBlockAndInsertIfThenElse(Cond, LI, &ThenTerm, &ElseTerm);
    BasicBlock *ThenBlock = ThenTerm->getParent();
    BasicBlock *ElseBlock = ElseTerm->getParent();
    BasicBlock *MergeBlock = LI->getParent();

    Builder.SetInsertPoint(ThenTerm);
    Instruction *ThenNewLI =  cast<Instruction>(Builder.CreateBitCast(
				 Builder.CreateCall(m_markAsUnaccessible.getFunctionType(),
						    m_markAsUnaccessible.getCallee(), {}),
				 LI->getType()));

    // clone the load instruction and insert it before ElseTerm
    Instruction *ElseNewLI = LI->clone();
    ElseBlock->getInstList().insert(ElseTerm->getIterator(), ElseNewLI);

    // Replace LI with a PHI node 
    Builder.SetInsertPoint(LI);
    PHINode *NewLI = Builder.CreatePHI(LI->getType(), 2, LI->getName());
    NewLI->setDebugLoc(LI->getDebugLoc());
    NewLI->addIncoming(ThenNewLI, ThenBlock);
    NewLI->addIncoming(ElseNewLI, ElseBlock);
    LI->replaceAllUsesWith(NewLI);
    LI->eraseFromParent();
  }
  return change;
}
  
bool PreConfigPrimeInst::runOnFunction(Function &F) {
  if (F.empty()) {
    return false;
  }
  return transformGetOptFn(F) && transformOptArgLoad(F);
}
  
PostConfigPrimeInst::PostConfigPrimeInst() {}

bool PostConfigPrimeInst::runOnModule(Module &M) {
  for (auto &F: M) {
    runOnFunction(F);
  }
  return false;
}

void PostConfigPrimeInst::undoGetOptFnTransform(Function &F) {
  SmallVector<CallBase*,4> toRemove;
  for (auto &B: F) {
    for (auto &I: B) {
      if (CallBase *CB = dyn_cast<CallBase>(&I)) {
	if (Function *calleeF = CB->getCalledFunction()) {
	  if (calleeF->getName() == CONFIG_PRIME_STOP) {
	    toRemove.push_back(CB);
	  }
	}
      }
    }
  }
  LLVMContext &ctx = F.getParent()->getContext();
  
  // Remove the whole basic block 
  while (!toRemove.empty()) {
    CallBase *CB = toRemove.back();
    toRemove.pop_back();
    BasicBlock *B = CB->getParent();
    BasicBlock *Pred = B->getUniquePredecessor();
    BasicBlock *Succ = B->getUniqueSuccessor();
    if (Pred && Succ) {
      // remove all instructions in B and add "unreachable" as terminator
      previrt::transforms::removeBlock(B, ctx);
      Pred->getInstList().pop_back(); 
      Pred->getInstList().push_back(BranchInst::Create(Succ));     
      B->eraseFromParent();
    }
  }
}

void PostConfigPrimeInst::undoOptArgLoadTransform(Function &F) {
  SmallVector<CallBase*,4> toRemove;
  for (auto &B: F) {
    for (auto &I: B) {
      if (CallBase *CB = dyn_cast<CallBase>(&I)) {
	if (Function *calleeF = CB->getCalledFunction()) {
	  if (calleeF->getName() == CONFIG_PRIME_UNACCESSIBLE) {
	    toRemove.push_back(CB);
	  }
	}
      }
    }
  }
  LLVMContext &ctx = F.getParent()->getContext();
  /*BEFORE
    54:                                               ; preds = %52
     %55 = load i32, i32* @optind, !dbg !10672
     %56 = icmp sge i32 %55, 2, !dbg !10672
     br i1 %56, label %57, label %59, !dbg !10672
    57:                                               ; preds = %54
     %58 = call i8* @occam.config_prime.unaccessible(), !dbg !10672
     br label %61, !dbg !10672
    59:                                               ; preds = %54
     %60 = load i8*, i8** @optarg, align 8, !dbg !10672, !tbaa !2038
     br label %61, !dbg !10672
    61:                                               ; preds = %59, %57
     %62 = phi i8* [ %58, %57 ], [ %60, %59 ], !dbg !10672

   AFTER
    54:                                               ; preds = %52
     %55 = load i32, i32* @optind, !dbg !10672   // to be removed by DCE
     %56 = icmp sge i32 %55, 2, !dbg !10672      // to be removed by DCE
     br label %59, !dbg !10672
    59:                                               ; preds = %54
     %60 = load i8*, i8** @optarg, align 8, !dbg !10672, !tbaa !2038
     br label %61, !dbg !10672
    61:                                               ; preds = %59
     // replaced all uses of %62 with %60
  */

  
  // Remove the whole basic block 
  while (!toRemove.empty()) {
    CallBase *CB = toRemove.back();
    toRemove.pop_back();
    BasicBlock *B = CB->getParent();
    BasicBlock *Pred = B->getUniquePredecessor();
    BasicBlock *Succ = B->getUniqueSuccessor();
    if (Pred && Succ) {
      if (BranchInst *BI = dyn_cast<BranchInst>(Pred->getTerminator())) {
	// Assume the branch is conditional because we put it there
	BranchInst *NewBI = BranchInst::Create((BI->getSuccessor(0) == B) ?
					       BI->getSuccessor(1):
					       BI->getSuccessor(0), BI);
	BI->replaceAllUsesWith(NewBI);
	BI->eraseFromParent();
      }

      // Assume we added this PHI node
      if (PHINode *PHI = dyn_cast<PHINode>(&(Succ->getInstList().front()))) {
	Value *NewV = (PHI->getIncomingBlock(0) == B ?
		       PHI->getIncomingValue(1) :
		       PHI->getIncomingValue(0));
	// It shouldn't fail
	LoadInst *OrigLI = cast<LoadInst>(NewV);
	OrigLI->setName(PHI->getName());
	OrigLI->setDebugLoc(PHI->getDebugLoc());
	PHI->replaceAllUsesWith(OrigLI);
	PHI->eraseFromParent();
      } else {
	// this shouldn't reachable
      }
      
      // remove all instructions in B and add "unreachable" as terminator
      previrt::transforms::removeBlock(B, ctx);
      // unlink B and free B
      //B->eraseFromParent();
    } else {
      // this shouldn't be reachable
    }
  }
}

bool PostConfigPrimeInst::runOnFunction(Function &F) {
  if (F.empty()) {
    return false;
  }
  undoGetOptFnTransform(F);
  undoOptArgLoadTransform(F);

  // return true only if there is a change wrt the code *before*
  // PreConfigPrimeInst was run.
  return false;
}
} // end namespace previrt

char previrt::ConfigPrime::ID = 0;

static RegisterPass<previrt::ConfigPrime> X("Pconfig-prime",
                                            "Configuration priming");
