#include "llvm/Pass.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Constants.h"
#include "llvm/Support/raw_ostream.h"

#include "interpreter/Interpreter.h"
#include "ConfigPrime.h"

using namespace llvm;

static cl::list<std::string>
XMainArgV("Pconfig-prime-main-argv",
	  cl::Hidden,
	  cl::desc("Specified the list of parameters for main"));

namespace {
class ArgvArray {
  std::unique_ptr<char[]> Array;
  std::vector<std::unique_ptr<char[]>> Values;
public:
  /// Turn a vector of strings into a nice argv style array of pointers to null
  /// terminated strings.
  void *reset(LLVMContext &C, ExecutionEngine *EE,
              const std::vector<std::string> &InputArgv);
};
}  // anonymous namespace

void *ArgvArray::reset(LLVMContext &C, ExecutionEngine *EE,
                       const std::vector<std::string> &InputArgv) {
  Values.clear();  // Free the old contents.
  Values.reserve(InputArgv.size());
  unsigned PtrSize = EE->getDataLayout().getPointerSize();
  Array = make_unique<char[]>((InputArgv.size()+1)*PtrSize);

  errs() << "ConfigPrime: ARGV = " << (void*)Array.get() << "\n";
  Type *SBytePtr = Type::getInt8PtrTy(C);

  for (unsigned i = 0; i != InputArgv.size(); ++i) {
    unsigned Size = InputArgv[i].size()+1;
    auto Dest = make_unique<char[]>(Size);
    errs() << "ConfigPrime: ARGV[" << i << "] = " << (void*)Dest.get() << "\n";

    std::copy(InputArgv[i].begin(), InputArgv[i].end(), Dest.get());
    Dest[Size-1] = 0;

    // Endian safe: Array[i] = (PointerTy)Dest;
    EE->StoreValueToMemory(PTOGV(Dest.get()),
                           (GenericValue*)(&Array[i*PtrSize]), SBytePtr);
    Values.push_back(std::move(Dest));
  }

  // Null terminate it
  EE->StoreValueToMemory(PTOGV(nullptr),
                         (GenericValue*)(&Array[InputArgv.size()*PtrSize]),
                         SBytePtr);
  return Array.get();
}

namespace previrt {

std::vector<GenericValue> prepareArgumentsForMain(Function *mainFn,
						  const std::vector<std::string>& argv,
						  ExecutionEngine &EE
						  //, const char * const * envp
						  ) {
  std::vector<GenericValue> GVArgs;
  GenericValue GVArgc;
  GVArgc.IntVal = APInt(32, argv.size());

  // Check main() type
  unsigned NumArgs = mainFn->getFunctionType()->getNumParams();
  FunctionType *FTy = mainFn->getFunctionType();
  Type* PPInt8Ty = Type::getInt8PtrTy(mainFn->getContext())->getPointerTo();

  // Check the argument types.
  if (NumArgs > 3)
    report_fatal_error("Invalid number of arguments of main() supplied");
  if (NumArgs >= 3 && FTy->getParamType(2) != PPInt8Ty)
    report_fatal_error("Invalid type for third argument of main() supplied");
  if (NumArgs >= 2 && FTy->getParamType(1) != PPInt8Ty)
    report_fatal_error("Invalid type for second argument of main() supplied");
  if (NumArgs >= 1 && !FTy->getParamType(0)->isIntegerTy(32))
    report_fatal_error("Invalid type for first argument of main() supplied");
  if (!FTy->getReturnType()->isIntegerTy() &&
      !FTy->getReturnType()->isVoidTy())
    report_fatal_error("Invalid return type of main() supplied");

  ArgvArray CArgv;
  ArgvArray CEnv;
  if (NumArgs) {
    GVArgs.push_back(GVArgc); // Arg #0 = argc.
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
      //   GVArgs.push_back(PTOGV(CEnv.reset(mainFn->getContext(), this, EnvVars)));
      // }
    }
  }
  return GVArgs;
}

ConfigPrime::ConfigPrime(): ModulePass(ID) {}

ConfigPrime::~ConfigPrime() {}

bool ConfigPrime::runOnModule(Module& M) {
  std::string ErrorMsg;
  
  std::unique_ptr<Module> M_ptr(&M);
  EngineBuilder builder(std::move(M_ptr));
  builder.setErrorStr(&ErrorMsg);
  builder.setEngineKind(EngineKind::Interpreter); // LLVM Interpreter
  
  std::unique_ptr<ExecutionEngine> EE(builder.create());
  if (!EE) {
    if (!ErrorMsg.empty())
      errs() << "Error creating EE: " << ErrorMsg << "\n";
    else
      errs() << "Unknown error creating EE!\n";
    return false;
  }
  
  Function* main=EE->FindFunctionNamed("main");
  
  if (main) {
    EE->runStaticConstructorsDestructors(false);

    std::vector<std::string> mainArgV;
    unsigned i=0;
    for(auto a: XMainArgV) {
      errs() << "ConfigPrime: reading argv[" << i++ << "] " << a << "\n";
      mainArgV.push_back(a);
    }
    
    std::vector<GenericValue> mainArgVGV = prepareArgumentsForMain(main, mainArgV, *EE);
    GenericValue Result = EE->runFunction(main,ArrayRef<GenericValue>(mainArgVGV));
    errs() << "Execution of main returned: " << Result.IntVal << "\n";
    EE->runStaticConstructorsDestructors(true);
    
    // XXX: Not sure if we should call exit
    //EE->finalizeObject();
    //EE.reset();

    // TODO: Cast EE to Interpreter and ask for all the branches taken
    //       and remove those which were not taken.
  } 
  return false;
}

void ConfigPrime::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();    
}

} // end namespace


char previrt::ConfigPrime::ID = 0;

static RegisterPass<previrt::ConfigPrime>
X("Pconfig-prime", "Configuration priming ", false, false);
  

