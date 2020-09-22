/**
 * LLVM transformation pass to construct a 'Dummy' main function
 * which calls a list of specified functions with non-deterministic
 * arguments.
 *
 * This pass builds a main function for bitcodes which do not have one
 * (e.g. library bitcodes). Then via user specified entry-point functions,
 * this pass would identify the types of the arguments for each of the
 * entry points and create non-deterministic versions of them to be passed
 * into the Seahorn model-checker and Devirtualization pass, after which
 * any reachable function, either directly or indirectly would be kept in
 * the module. The result would be a specialized bitcode for the specified
 * entry points.
 **/

#include "llvm/Demangle/Demangle.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Value.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include <string>

#include "seadsa/CompleteCallGraph.hh"
#include "seadsa/InitializePasses.hh"

#include "boost/format.hpp"

static llvm::cl::list<std::string>
    EntryPoints("entry-point",
                llvm::cl::desc("Entry point if main does not exist"),
                llvm::cl::ZeroOrMore);

namespace previrt {
namespace transforms {

using namespace llvm;

class DummyMainFunction : public ModulePass {
  DenseMap<const Type *, Constant *> m_ndfn;

  /*
   * Create a function declaration which corresponds to a non-deterministic call
   * to a function which returns a value of the specified type. Invoked for each
   * argument of the module entry point functions.
   */
  Function &makeNewNondetFn(Module &m, Type &type, unsigned num,
                            std::string prefix) {
    std::string name;
    unsigned c = num;
    do
      name = boost::str(boost::format(prefix + "%d") % (c++));
    while (m.getNamedValue(name));
    Function *res =
        dyn_cast<Function>(m.getOrInsertFunction(name, &type).getCallee());
    assert(res);
    return *res;
  }

  /*
   * No need to create multiple versions of non-deterministic calls
   * for any one type.
   */
  Constant *getNondetFn(Type *type, Module &M) {
    Constant *res = m_ndfn[type];
    if (!res) {
      res = &makeNewNondetFn(M, *type, m_ndfn.size(), "verifier.nondet.");
      m_ndfn[type] = res;
    }
    return res;
  }

  /*
   * Function names may be mangled by the front-end compiler. As entry-points
   * are specified with the source-level names, we need to create a map from
   * demangled source level names, to mangled versions of function(s).
   *
   * This also enables multiple prototypes of the same function name to be
   * specified by their shared source level name.
   *
   */
  std::map<std::string, std::vector<std::string>> getFnMap(Module &m) {
    std::map<std::string, std::vector<std::string>> fn_map;

    for (auto &F : m) {
      std::string demangled = demangle(F.getName());
      demangled = demangled.substr(0, demangled.find_first_of("("));

      fn_map[demangled].push_back(F.getName());
    }

    return fn_map;
  }

  /*
   * Printing the map of demangled function names to a vector of
   * corresponding mangled function names.
   */
  void printFnMapInfo(std::map<std::string, std::vector<std::string>> fn_map) {
    errs() << "|\tPrinting Function Name Map\t|\n";
    errs() << "_______________________________________________\n";
    for (auto iter = fn_map.begin(), e = fn_map.end(); iter != e; iter++) {
      std::string fn = iter->first;
      std::vector<std::string> vec = iter->second;

      errs() << fn << ":\n";
      for (auto nm : vec) {
        errs() << "\t" << nm << "\n";
      }
      errs() << "_______________________________________________\n";
    }
  }

  /*
   * For cases where there isn't a return value and the function is pure,
   * to keep these functions in the module (for the sake of completeness).
   */
  void makeImpure(LLVMContext &ctx, GlobalVariable *GV, Function *F,
                  IRBuilder<> builder) {
    BasicBlock *FBegin = &*(F->begin());
    BasicBlock *IncrementBlock =
        BasicBlock::Create(ctx, "dummy_increment", F, FBegin);

    // Add branch inst
    BranchInst *Br = BranchInst::Create(FBegin, IncrementBlock);

    // Load the global variable
    LoadInst *LoadGlob = new LoadInst(GV->getValueType(), (Value *)GV,
                                      "counter", (Instruction *)Br);

    // Increment by 1
    auto AddInst = BinaryOperator::Create(
        Instruction::Add, ConstantInt::get(GV->getValueType(), 1, false),
        LoadGlob, "add_dummy", (Instruction *)Br);

    StoreInst *StoreGlob = new StoreInst(AddInst, GV, (Instruction *)Br);

    errs() << F->getName() << "\n";
    errs() << *F << "\n";
  }

  /*
   * The non-deterministic function calls created don't have their return values
   * being used and hence would be discarded by the specialization passes.
   * Creating temporary printf calls would prevent these passes from discarding
   * these calls.
   *
   */
  void makePrintf(Module &m, CallInst *ci, IRBuilder<> builder) {

    Type *charType = Type::getInt8PtrTy(m.getContext());
    FunctionType *printf_type = FunctionType::get(charType, true);
    auto *res = cast<Function>(
        m.getOrInsertFunction("printf", printf_type).getCallee());

    assert(res && "printf not found in module");

    Type *type = res->getReturnType();

    // Testing with fixed type
    std::string type_fmt = "%d";

    SmallVector<Value *, 16> Args;

    std::string fmt = "Creating print call for " + type_fmt;
    Value *global_fmt = builder.CreateGlobalStringPtr(fmt.c_str());

    Args.push_back(global_fmt);
    Args.push_back((Value *)ci);

    CallInst *printFunc = builder.CreateCall(res, Args);

    errs() << "DummyMainFunction: created print call " << *printFunc << "\n";
  }

public:
  static char ID;

  DummyMainFunction() : ModulePass(ID) {}

  bool runOnModule(Module &M) {

    if (M.getFunction("main")) {
      errs() << "DummyMainFunction: Main already exists.\n";
      return false;
    }

    auto fn_map = getFnMap(M);
    printFnMapInfo(fn_map);

    // Functions corresponding to the user specified entry points
    SmallVector<Function *, 16> EntryFunctions;

    errs() << "Invoked Dummy main on:\n";

    for (unsigned i = 0; i < EntryPoints.size(); i++) {
      errs() << i << "\t" << EntryPoints[i] << "\n";

      if (EntryPoints[i] != "" &&
          EntryPoints[i] != "none") { // If entry points specified
        if (fn_map.find(EntryPoints[i]) != fn_map.end()) {
          std::vector<std::string> mangled_names =
              fn_map.find(EntryPoints[i])->second;

          for (auto fn_nm : mangled_names) {
            Function *fptr = M.getFunction(fn_nm);
            if (fptr && !(fptr->isIntrinsic())) {
              EntryFunctions.push_back(fptr);
            } else {
              errs() << "DummyMainFunction: This shouldn't have happend\n";
              assert(false);
            }
          }

        } else {
          errs() << "DummyMainFunction: " << EntryPoints[i]
                 << " is not present in current module...\n";
        }
      }
    }

    if (!EntryFunctions.size()) {
      errs() << "DummyMainFunction: None of the specified functions exist in "
                "this module, aborting pass...\n";
      return false;
    }

    // --- Create main
    LLVMContext &ctx = M.getContext();
    Type *intTy = Type::getInt32Ty(ctx);

    ArrayRef<Type *> params;
    Function *main = Function::Create(
        FunctionType::get(intTy, params, false),
        GlobalValue::LinkageTypes::ExternalLinkage, "main", &M);

    // Create Global Variable
    GlobalVariable *Counter = new GlobalVariable(
        M, intTy, false, GlobalValue::LinkageTypes::ExternalLinkage, nullptr,
        "DummyCounter");

    // Adding a metadata node with string dummy. Allows differentiating
    // between 'Dummy' main functions and actual main functions across modules.
    LLVMContext &C = main->getContext();
    MDNode *N = MDNode::get(C, MDString::get(C, "dummy"));
    main->setMetadata("dummy.metadata", N);

    IRBuilder<> B(ctx);
    BasicBlock *BB = BasicBlock::Create(ctx, "", main);
    B.SetInsertPoint(BB, BB->begin());

    for (auto F : EntryFunctions) {

      // -- create a call with non-deterministic actual parameters
      SmallVector<Value *, 16> Args;
      for (auto &A : F->args()) {
        Constant *ndf = getNondetFn(A.getType(), M);
        Args.push_back(B.CreateCall(ndf));
      }

      CallInst *CI = B.CreateCall(F, Args);

      errs() << "DummyMainFunction: created a call " << *CI << "\n";
      // For each non-deterministic call, add a printf which uses it's return
      // value.
      if (!F->getReturnType()->isVoidTy()) {
        makePrintf(M, CI, B);
      } else {
        // makeImpure(ctx,Counter,F,B);
      }
    }

    // -- return of main
    // our favourite exit code
    B.CreateRet(ConstantInt::get(intTy, 42));

    return true;
  }

  void getAnalysisUsage(AnalysisUsage &AU) {}

  virtual StringRef getPassName() const { return "Add dummy main function"; }
};

char DummyMainFunction::ID = 0;

Pass *createDummyMainFunctionPass() { return new DummyMainFunction(); }

} // namespace transforms
} // namespace previrt

static llvm::RegisterPass<previrt::transforms::DummyMainFunction>
    X("PaddMain",
      "Convert a library bitcode into a standalone module with a main function "
      "which has non-deterministic calls to certain functions",
      false, false);
