#include "llvm/IR/Function.h"
#include "llvm/IR/Constants.h"
#include "llvm/Pass.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
//#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/LinkAllPasses.h" //createAlwaysInlinerLegacyPass

#include "Specializer.h" // materializeStringLiteral

#include <string>  // stoi, strtok, ...
#include <fstream> // ifstream
//#include <stdexcept> // std::invalid_argument

namespace previrt
{
  class ArgumentsConstraint : public llvm::ModulePass
  {
  public:
    static char ID;

    ArgumentsConstraint();
    virtual ~ArgumentsConstraint();
    virtual void getAnalysisUsage (llvm::AnalysisUsage &AU) const {}
    virtual llvm::StringRef getPassName() const
    { return "Partial specialization of program arguments"; }
    virtual bool runOnModule(llvm::Module &M);
  };
}

using namespace llvm;
using namespace previrt;

static cl::opt<std::string> InputFilename
("Pconstraints-input",
 cl::init(""),
 cl::Hidden,
 cl::desc("Specify the filename with input arguments"));


ArgumentsConstraint::ArgumentsConstraint()
  : ModulePass (ID) {}

ArgumentsConstraint::~ArgumentsConstraint() {}

// line is "N S" where N is any non-negative number and S is a string
// between double quotes
bool parse_input_line(std::string line, unsigned &index, std::string &s) {
  std::vector<std::string> tokens;
  std::size_t pos = 0;
  std::size_t found = line.find_first_of(' ', pos);
  if (found != std::string::npos) {
    tokens.push_back(line.substr(pos, found - pos));
    pos = found+1;
    tokens.push_back(line.substr(pos));
  } else {
    errs () << "Could not parse " << line << "\n";
    return false;
  }

  if (tokens.size() != 2) {
    return false;
  } else {
    // XXX: llvm disables exceptions
    //try {
    index = (unsigned) std::stoi(tokens[0]);
    // }
    // catch (const std::invalid_argument &ia) {
    //   return false;
    // }
    s = tokens[1];
    return true;
  }
}

// out contains all argv's parameters defined by the user
void populate_program_arguments(std::string filename,
				std::map<unsigned, std::string> &out,
				int &argc) {
  std::string line;
  std::ifstream fd (filename);
  if (fd.is_open()) {
    std::string argc_line;
    getline(fd,argc_line);
    argc = std::stoi(argc_line);
    while (getline(fd,line)) {
      unsigned i; std::string val;
      if (parse_input_line(line, i, val)) {
	out.insert(std::make_pair(i, val));
      }
    }
    fd.close();
  } else {
    errs () << filename << " not found\n";
  }
}

bool ArgumentsConstraint::runOnModule(Module &M) {
  /*
    Given argv[0], argv[1], ... argv[argc-1] and k extra arguments
    from the manifest x1, ..., xk it builds a new argv array,
    new_argv, such that

    new_argv[0]       = x1,
    new_argv[1]       = x2,
    ...
    new_argv[k]       = xk,
    new_argv[k+1]     = argv[1],
    new_argv[k+2]     = argv[2],
    ...
    new_argv[k+argc-1]= argv[argc-1]

    XXX: note that we ignore argv[0] because we assume that it is
    always given by the manifest (x1).
   */

  Function *main = M.getFunction("main");

  if (!main) {
    errs() << "Running on module without 'main' function.\n"
	   << "Ignoring...\n";
    return false;
  }

  if (main->arg_size() != 2) {
    errs() << "main function has incorrect signature\n"
           << *(main->getFunctionType()) << "Ignoring...\n";
    return false;
  }

  // Create partial map from indexes to strings
  std::map<unsigned, std::string> argv_map;
  int extra_argc = -1;
  populate_program_arguments(InputFilename, argv_map, extra_argc);

  if (argv_map.empty()) {
    errs () << "User did not provide program parameters. Ignoring ...\n";
    return false;
  }

  if (argv_map.find(0) == argv_map.end()) {
    errs () << "argv[0] does not exist in the manifest. Ignoring ...\n";
    return false;
  }

  IRBuilder<> builder(M.getContext());
  IntegerType* intptrty =
    cast<IntegerType>(M.getDataLayout().getIntPtrType(M.getContext(), 0));
  Type* const strty =
    PointerType::getUnqual(IntegerType::get(M.getContext(),8));

  // new_main
  Function *new_main = Function::Create(main->getFunctionType(),
   					main->getLinkage(), "", &M);
  new_main->takeName(main);
  Function::arg_iterator ai = new_main->arg_begin();
  Value* argc = (Value*) &(*ai);
  Value* argv = (Value*) &(*(++ai));

  BasicBlock *entry = BasicBlock::Create(M.getContext(),"entry", new_main);
  builder.SetInsertPoint(entry);

  // Add sanity check: if argc-1 != manifest's first argument then return 1
  Value* matchArgcCond = builder.CreateICmpEQ(argc, ConstantInt::get(argc->getType(), extra_argc + 1));
  BasicBlock* entry_cont = BasicBlock::Create(M.getContext(),"entry", new_main);
  BasicBlock* errorBB = BasicBlock::Create(M.getContext(),"incorrect_argc", new_main);
  // wire up entry with entry_cont and errorBB blocks
  builder.CreateCondBr(matchArgcCond, entry_cont, errorBB);
  builder.SetInsertPoint(errorBB);
  builder.CreateRet(ConstantInt::get(new_main->getReturnType(), 1));

  entry = entry_cont;
  builder.SetInsertPoint(entry);
  // new argc
  Value* new_argc =
    builder.CreateAdd(argc,
		      ConstantInt::get(argc->getType(),
				       argv_map.size() -1 /*ignore argv[0]*/),
		      "new_argc");

  if (extra_argc != -1) {
    builder.CreateAssumption(builder.CreateICmpEQ(argc,
    						  ConstantInt::get(argc->getType(),
    								   (extra_argc + 1 /* add argv[0] from command line*/))));
  } else {
    errs () << "No argc given in the manifest so specialization might not take place\n";
  }

  // new argv
  Value* new_argv = builder.CreateAlloca(strty, new_argc, "new_argv");


  // copy the manifest into new_argv
  unsigned i=0;
  for (auto &kv: argv_map) {
    // create a global variable with the argument from the manifest
    GlobalVariable *gv_i = materializeStringLiteral(M, kv.second.c_str());
    gv_i->setName("new_argv");
    // take the address of the global variable
    Value *gv_i_ref =
      builder.CreateConstGEP2_32(
	      cast<PointerType>(gv_i->getType())->getElementType(),gv_i, 0, 0);
    // store the global variable into new_argv[i]
    Value *new_argv_i = builder.CreateConstGEP1_32(new_argv,i);
    builder.CreateStore(gv_i_ref, new_argv_i);
    i++;
  }

  /* Loop that copies argv into new_argv starting at index k

    Before
     Entry

   After
     Entry:
       ...
       goto PreHeader
     PreHeader:
       %j = alloca i32
       store 0 %j
       goto Header
     Header:
       %t1 = load %j
       %f = icmp slt %t1, %argc
       br %f, Body, Tail
     Body:
       %o1 = add %t1, %k
       %a1 = gep %new_argv, %o1
       %a2 = gep %argv, %t1
       store (load %a2), %a1
       %t2 = add %t1, 1
       store %t2, %j
       goto Header
     Tail:
       %r = call main(%newargc, %new_argv);
       ret %r
  */

  BasicBlock *pre_header = BasicBlock::Create(M.getContext(),"pre_header", new_main);
  builder.CreateBr(pre_header);
  builder.SetInsertPoint(pre_header);
  Type *intTy = argc->getType();
  AllocaInst *j = builder.CreateAlloca(intTy);
  builder.CreateStore(ConstantInt::get(intTy, 1), j); /*ignore argv[0]*/

  // header
  BasicBlock *header = BasicBlock::Create(M.getContext(),"header", new_main);
  builder.CreateBr(header);
  builder.SetInsertPoint(header);
  LoadInst *t1 = builder.CreateLoad(j);
  Value *cond = builder.CreateICmpSLT(t1, argc);
  BasicBlock *body = BasicBlock::Create(M.getContext(),"body", new_main);
  BasicBlock *tail = BasicBlock::Create(M.getContext(),"tail", new_main);
  builder.CreateCondBr(cond, body, tail);
  // body
  builder.SetInsertPoint(body);
  Value *o1 = builder.CreateZExtOrTrunc(
		builder.CreateAdd(ConstantInt::get(intTy, argv_map.size() -1 /*skip argv[0]*/),
				  t1),
		intptrty);
  Value *a1 = builder.CreateInBoundsGEP(new_argv, o1);
  Value *o2 = builder.CreateZExtOrTrunc(t1, intptrty);
  Value *a2 = builder.CreateInBoundsGEP(argv, o2);
  builder.CreateStore(builder.CreateLoad(a2),a1);
  Value *t2 = builder.CreateAdd(t1, ConstantInt::get(intTy,1));
  builder.CreateStore(t2, j);
  builder.CreateBr(header);
  //tail
  builder.SetInsertPoint(tail);


  // call the code of the original main with new argc and new argv
  Value* res = builder.CreateCall(main, {new_argc, new_argv});
  builder.CreateRet(res);

  // Modify main attributes so that it can be inlined
  main->setLinkage(GlobalValue::PrivateLinkage);
  main->removeFnAttr(Attribute::NoInline);
  main->removeFnAttr(Attribute::OptimizeNone);
  main->addFnAttr(Attribute::AlwaysInline);

  legacy::PassManager mgr;
  // remove alloca's
  mgr.add(createPromoteMemoryToRegisterPass());
  // break alloca's of aggregates into multiple allocas if possible
  // it also performs mem2reg to remove alloca's at the same time
  mgr.add(createSROAPass());
  // inline original main function
  mgr.add(createAlwaysInlinerLegacyPass());
  mgr.run(M);

  /* Old code that overrides argv with the arguments from the
     manifest */
  // Function::arg_iterator ai = main->arg_begin();
  // Value* argv = (Value*) &(*(++ai));

  // for (auto &kv: argv_map) {
  //   // create a global variable with the content of argv[i]
  //   GlobalVariable* gv_i = materializeStringLiteral(M, kv.second.c_str());
  //   // take the address of the global variable
  //   Value *gv_i_ref =
  //     builder.CreateConstGEP2_32(cast<PointerType>(gv_i->getType())->getElementType(),
  // 				 gv_i, 0, 0);
  //   // compute a gep instruction that access to argv[i]
  //   Value* argv_i = builder.CreateConstGEP1_32(argv, kv.first);
  //   // store the global variable into argv[i]
  //   builder.CreateStore(gv_i_ref, argv_i);
  // }

  // legacy::PassManager mgr;
  // mgr.add(createGlobalOptimizerPass());
  // mgr.add(createGlobalDCEPass());
  // mgr.run(M);

  return true;
}


char ArgumentsConstraint::ID = 0;

static RegisterPass<previrt::ArgumentsConstraint>
X("Pconstraints",
  "Partial specialization of main arguments",
  false, false);
