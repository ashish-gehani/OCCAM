#include "llvm/Pass.h"
#include "llvm/ADT/StringRef.h"

/**
 * We use a modified version of the LLVM interpreter to execute the
 * program using all the available configuration information. From the
 * execution, we collect all the branches taken by the interpreter,
 * and remove all the non-taken branches. In general, some
 * configuration parameters are unknown so the interpreter must stop
 * whenever some value is not defined.
 **/
namespace previrt {
class ConfigPrime : public llvm::ModulePass {
public:
  static char ID;
  
  ConfigPrime();
  
  virtual ~ConfigPrime();
  
  virtual void getAnalysisUsage (llvm::AnalysisUsage &AU) const;
  
  virtual llvm::StringRef getPassName() const {
    return "Configuration Priming";
  }
  
  virtual bool runOnModule(llvm::Module &M);
};
} // end namespace previrt

