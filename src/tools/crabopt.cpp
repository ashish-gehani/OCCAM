//#include "clam/config.h"
#include "llvm/Bitcode/BitcodeWriter.h"
#include "llvm/Bitcode/BitcodeWriterPass.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/InitializePasses.h"
#include "llvm/LinkAllPasses.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/Signals.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/Utils/UnifyFunctionExitNodes.h"

#include "seadsa/support/RemovePtrToInt.hh"
#include "seadsa/AllocWrapInfo.hh"
#include "seadsa/CompleteCallGraph.hh"
#include "seadsa/DsaLibFuncInfo.hh"
#include "seadsa/InitializePasses.hh"

#include "crab/support/debug.hpp"
#include "crab/support/stats.hpp"

#include "transforms/Crab.h"

static llvm::cl::opt<std::string>
    InputFilename(llvm::cl::Positional,
                  llvm::cl::desc("<input LLVM bitcode file>"),
                  llvm::cl::Required, llvm::cl::value_desc("filename"));

static llvm::cl::opt<std::string>
    OutputFilename("o", llvm::cl::desc("Override output filename"),
                   llvm::cl::init(""), llvm::cl::value_desc("filename"));

static llvm::cl::opt<bool>
    OutputAssembly("S", llvm::cl::desc("Write output as LLVM assembly"));

static llvm::cl::opt<std::string>
    AsmOutputFilename("oll", llvm::cl::desc("Output analyzed bitcode"),
                      llvm::cl::init(""), llvm::cl::value_desc("filename"));

static llvm::cl::opt<std::string> DefaultDataLayout(
    "default-data-layout",
    llvm::cl::desc("data layout string to use if not specified by module"),
    llvm::cl::init(""), llvm::cl::value_desc("layout-string"));

/* begin options to logging, debugging, etc */
struct StatsOpt {
  void operator=(bool val) const 
  { crab::CrabEnableStats(val); } 
};
StatsOpt Pstats;
static llvm::cl::opt<StatsOpt, true, llvm::cl::parser<bool>>
CrabStats("Pcrab-stats", 
           llvm::cl::desc("Show some Crab statistics"),
	   llvm::cl::location(Pstats),
	   llvm::cl::value_desc("bool"));

struct VerboseOpt {
  void operator=(unsigned level) const 
  { crab::CrabEnableVerbosity(level); } 
};
VerboseOpt Pverbose;
static llvm::cl::opt<VerboseOpt, true, llvm::cl::parser<unsigned>> 
CrabVerbose("Pcrab-verbose",
	    llvm::cl::desc("Enable verbose messages"),
	    llvm::cl::location(Pverbose),
	    llvm::cl::value_desc("uint"));

struct WarningOpt {
  void operator=(bool val) const 
  { crab::CrabEnableWarningMsg(val); }
};
WarningOpt Pwarning;
static llvm::cl::opt<WarningOpt, true, llvm::cl::parser<bool>> 
CrabEnableWarning("Pcrab-enable-warnings",
	    llvm::cl::desc("Enable warning messages"),
	    llvm::cl::location(Pwarning),
	    llvm::cl::value_desc("bool"));


struct LogOpt {
  void operator=(const std::string &tag) const
  { crab::CrabEnableLog(tag); }
};
LogOpt PlogLoc;
static llvm::cl::opt<LogOpt, true, llvm::cl::parser<std::string>> 
LogClOption("Pcrab-log",
             llvm::cl::desc("Enable specified log level"),
             llvm::cl::location(PlogLoc),
             llvm::cl::value_desc("string"),
             llvm::cl::ValueRequired, llvm::cl::ZeroOrMore);
/* end options to logging, debugging, etc */

using namespace llvm;

// removes extension from filename if there is one
std::string getFileName(const std::string &str) {
  std::string filename = str;
  size_t lastdot = str.find_last_of(".");
  if (lastdot != std::string::npos)
    filename = str.substr(0, lastdot);
  return filename;
}

int main(int argc, char **argv) {
  llvm::llvm_shutdown_obj shutdown; // calls llvm_shutdown() on exit
  llvm::cl::ParseCommandLineOptions(
      argc, argv,
      "CrabOpt -- A LLVM bitcode optimized based on Abstract Interpretation-based Analyzer\n");

  llvm::sys::PrintStackTraceOnErrorSignal(argv[0]);
  llvm::PrettyStackTraceProgram PSTP(argc, argv);
  llvm::EnableDebugBuffering = true;

  std::error_code error_code;
  llvm::SMDiagnostic err;
  static llvm::LLVMContext context;
  std::unique_ptr<llvm::Module> module;
  std::unique_ptr<llvm::ToolOutputFile> output;
  std::unique_ptr<llvm::ToolOutputFile> asmOutput;

  module = llvm::parseIRFile(InputFilename, err, context);
  if (!module) {
    if (llvm::errs().has_colors())
      llvm::errs().changeColor(llvm::raw_ostream::RED);
    llvm::errs() << "error: "
                 << "Bitcode was not properly read; " << err.getMessage()
                 << "\n";
    if (llvm::errs().has_colors())
      llvm::errs().resetColor();
    return 3;
  }

  if (!AsmOutputFilename.empty())
    asmOutput = std::make_unique<llvm::ToolOutputFile>(
        AsmOutputFilename.c_str(), error_code, llvm::sys::fs::F_Text);
  if (error_code) {
    if (llvm::errs().has_colors())
      llvm::errs().changeColor(llvm::raw_ostream::RED);
    llvm::errs() << "error: Could not open " << AsmOutputFilename << ": "
                 << error_code.message() << "\n";
    if (llvm::errs().has_colors())
      llvm::errs().resetColor();
    return 3;
  }

  if (!OutputFilename.empty())
    output = std::make_unique<llvm::ToolOutputFile>(
        OutputFilename.c_str(), error_code, llvm::sys::fs::F_None);

  if (error_code) {
    if (llvm::errs().has_colors())
      llvm::errs().changeColor(llvm::raw_ostream::RED);
    llvm::errs() << "error: Could not open " << OutputFilename << ": "
                 << error_code.message() << "\n";
    if (llvm::errs().has_colors())
      llvm::errs().resetColor();
    return 3;
  }

  ///////////////////////////////
  // initialise and run passes //
  ///////////////////////////////

  llvm::legacy::PassManager pass_manager;
  llvm::PassRegistry &Registry = *llvm::PassRegistry::getPassRegistry();
  llvm::initializeCore(Registry);
  llvm::initializeTransformUtils(Registry);
  llvm::initializeAnalysis(Registry);

  llvm::initializeAllocWrapInfoPass(Registry);
  llvm::initializeAllocSiteInfoPass(Registry);
  llvm::initializeRemovePtrToIntPass(Registry);
  llvm::initializeDsaAnalysisPass(Registry);
  llvm::initializeDsaInfoPassPass(Registry);
  llvm::initializeCompleteCallGraphPass(Registry);

  // add an appropriate DataLayout instance for the module
  const llvm::DataLayout *dl = &module->getDataLayout();
  if (!dl && !DefaultDataLayout.empty()) {
    module->setDataLayout(DefaultDataLayout);
    dl = &module->getDataLayout();
  }

  assert(dl && "Could not find Data Layout for the module");

  /**
   * Here only passes that are strictly necessary to avoid crashes.
   * At the time, crabopt is called the bitcode should have been gone
   * through opt already.
   **/

  pass_manager.add(llvm::createPromoteMemoryToRegisterPass());
  
  // -- ensure one single exit point per function
  pass_manager.add(llvm::createUnifyFunctionExitNodesPass());
  // -- remove ptrtoint and inttoptr instructions
  pass_manager.add(seadsa::createRemovePtrToIntPass());

  if (!AsmOutputFilename.empty()) {
    pass_manager.add(createPrintModulePass(asmOutput->os()));
  }
  
  pass_manager.add(new previrt::transforms::CrabPass());

  // -- simplify invariants added in the bitcode (if any)
  pass_manager.add(llvm::createInstructionCombiningPass());
  // -- remove dead edges and blocks
  pass_manager.add(llvm::createCFGSimplificationPass());
  // -- remove global strings and values
  pass_manager.add(llvm::createGlobalDCEPass());

  if (!OutputFilename.empty()) {
    if (OutputAssembly) {
      pass_manager.add(createPrintModulePass(output->os()));
    } else {
      pass_manager.add(createBitcodeWriterPass(output->os()));
    }
  }

  pass_manager.run(*module.get());

  if (!AsmOutputFilename.empty()) {
    asmOutput->keep();
  }
  if (!OutputFilename.empty()) {
    output->keep();
  }

  return 0;
}


