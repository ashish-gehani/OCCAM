/**
 *
 * LLVM pass to extract the external function declarations
 * within a module. After collecting the results, the names
 * are written to a json file, so that the OCCAM pipeline
 * can leverage this information in different passes.
 *
 **/

#include <fstream>
#include <iostream>

#include "llvm/Pass.h"
#include "llvm/IR/MDBuilder.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include "seadsa/CompleteCallGraph.hh"
#include "seadsa/InitializePasses.hh"

namespace previrt {
namespace utils {

using namespace llvm;

class GetExternalFunctions : public ModulePass {
public:
  static char ID;

  /*
   * Extracting the Module name to create a unique filename
   * for each module this pass is run on.
   */
  StringRef getModuleName(StringRef path) {
    return path.substr(path.find_last_of("/") + 1);
  }

  GetExternalFunctions() : ModulePass(ID) {}

  virtual bool runOnModule(Module &M) override {

    StringRef ModuleName = getModuleName(M.getName());
    errs() << "Module Name:\t" << ModuleName << "\n";
    Function *Main = M.getFunction("main");

    // Only run for bitcode with a main function
    if (!Main) {
      return false;
    }

    // If the main exists but is a 'Dummy' main function, then return
    if (Main && Main->hasMetadata() && (Main->getMetadata("dummy.metadata"))) {
      errs() << "GetExternalFunctions:\tModule is not a true program, "
                "exiting...\n";
      return false;
    }

    std::ofstream write_file;
    write_file.open("external.functions." + ModuleName.str());
    write_file << "{ \"functions\": [";
    std::vector<std::string> functions;

    for (Function &F : M) {
      if (F.isDeclaration()) {
        errs() << F.getName() << ":\tDeclaration"
               << "\n";
        functions.push_back(F.getName());
      }
    }

    for (int i; i < functions.size(); ++i) {
      write_file << "\"" << (functions[i]) << "\"";

      if (i != (functions.size() - 1)) {
        write_file << ", ";
      }
    }

    write_file << "] }";

    write_file.close();

    return false;
  }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesAll();
  }

  virtual StringRef getPassName() const override {
    return "Dump the external functions of the module into a json file";
  }
};

char GetExternalFunctions::ID = 0;

} // namespace utils
} // namespace previrt

static llvm::RegisterPass<previrt::utils::GetExternalFunctions>
    X("PdumpExternFuncs", "Get the name of all external functions within a module",
      false, false);
