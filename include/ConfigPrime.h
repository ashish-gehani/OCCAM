#include "llvm/Pass.h"
#include "llvm/ADT/StringRef.h"

namespace llvm {
 class APInt;
 class  ExecutionEngine;
}// namespace llvm;

/**
 * We execute the program with the available manifest. If all input
 * parameters in the manifest are provided then the execution should
 * terminate successfully, assuming all external calls can be called
 * via FFI. Otherwise, the execution terminates at the first branch
 * whose condition depends of an unknown input parameter. Upon
 * termination, either full or partial, the program's state is used to
 * simplify the bitcode.
 **/
namespace previrt {
class ConfigPrime : public llvm::ModulePass {
  
  std::unique_ptr<llvm::ExecutionEngine> m_ee;

  void runInterpreterAsMain(llvm::Module &M, llvm::APInt& Res);
  void stopInterpreter(llvm::Module &M, const llvm::APInt& Res);
  
public:
  static char ID;
  
  ConfigPrime();
  
  virtual ~ConfigPrime();
  
  virtual void getAnalysisUsage (llvm::AnalysisUsage &AU) const override;
  
  virtual llvm::StringRef getPassName() const override {
    return "Configuration Priming";
  }
  
  virtual bool runOnModule(llvm::Module &M) override;
};
} // end namespace previrt

