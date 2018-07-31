/*

  Author: Hashim Sharif
  Email: hsharif3@illinois.edu

*/

#include "llvm/Analysis/CallGraph.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instruction.h"        
#include "llvm/IR/Instructions.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Constants.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

#include<map>
#include<string>

class ExtendedCallGraph {

  static char ID;
  std::map<std::string, std::map<std::string, bool>> bitcastGlobals;
  std::map<std::string, std::string> functionNames;
  bool debugFlag;
                
  bool isPrimitiveType(std::string type) const {

    if(type != "i32" && type != "i1" && type != "i8*" && type != "i64")
      return false;
    else
      return true;
  }

  std::string strip(const std::string& in) const {

    // The casted type is not a struct type    
    if(in.find("struct") == std::string::npos) 
      return in;

    char final[2000];
    char* cursor = final;
    for(std::string::const_iterator c = in.begin(), end = in.end(); c != end; ++c) {
      char cc = *c;
      if ((cc >= 'a' && cc <= 'z') || (cc >= 'A' && cc <= 'Z') ||  (cc == '_'))
	{
          *cursor = cc;
          ++cursor;
	}
    }

    *cursor = 0;
    return final;
  }


  bool filterStructs(std::string type_string) const {

    if(type_string.find("%struct") != std::string::npos &&
       type_string.find("(") == std::string::npos &&
       type_string.find("[") == std::string::npos)
      return true;
    else
      return false;
  }


  bool isTraversed(std::map<llvm::Function*, bool> & successorMap,
		   llvm::Function * function, int & count){

    if(successorMap.find(function) != successorMap.end()){    
      return true;
    }
    else{

      successorMap[function] = true;
      count += 1; 
      return false;
    }
  }


  void incrementResolved(std::map<llvm::Instruction*, bool> & resolvedInst,
			 llvm::Instruction * Inst, int & resolved) const {
    
    if(resolvedInst.find(Inst) == resolvedInst.end()){
      resolved++;
      resolvedInst[Inst] = true;
    }
  }


  void incrementUnresolved(std::map<llvm::Instruction*, bool> & unresolvedInst,
			   llvm::Instruction * Inst, int & unresolved) const {
    
    if(unresolvedInst.find(Inst) == unresolvedInst.end()){
      unresolved++;
      unresolvedInst[Inst] = true;
    }
  }
  
  bool checkArgs(llvm::CallInst* ci, llvm::Function *f) const {

    if(ci->getNumOperands() != f->getFunctionType()->getNumParams())
      return false;

    return true; // hacking

  }

 public:

  // The resolve call routines takes as input an indirect callInst and
  // fills the functionsCalled map with the called functions
  void resolveCall(llvm::CallInst * callInst, llvm::Module & M,
		   std::map<llvm::Function*, bool> & functionsCalled){

    // Ignoring direct function calls. 
    llvm::Function * calledFunction = callInst->getCalledFunction();
    if(calledFunction){
      return;
    }

    // callValue is the operand of the callInst
    llvm::Value * callValue = callInst->getCalledValue();
    // Resolving calls of the form "call bitcast_expresssion $Type $Function"
    if(llvm::ConstantExpr * callExpr = llvm::dyn_cast<llvm::ConstantExpr>(&*callValue)){
      if(llvm::Function * calledFunction = llvm::dyn_cast<llvm::Function>(callExpr->getOperand(0))){         
	if(checkArgs(callInst, calledFunction))
	  functionsCalled[calledFunction] = true;
      }
    }

    // FIXIT: Add an additional check for a bitcast instruction

    if(llvm::Instruction * inst = llvm::dyn_cast<llvm::Instruction>(&*callValue)){

      // Extracting the first GEP inst that uses the operand of the
      // call instruction. This instruction extracts the function
      // pointer from a structure type global
      llvm::GetElementPtrInst* GEVInst;
      std::set<llvm::Instruction*> visited;
      while(inst){
	if (!visited.insert(inst).second) {
	  // break cycle
	  break;
	}
	
	if((GEVInst = llvm::dyn_cast<llvm::GetElementPtrInst>(&*inst))){
	  break;
	}
	llvm::Value * op = inst->getOperand(0); // FIXIT: only handling operand(0). Handling only loads?
	inst = llvm::dyn_cast<llvm::Instruction>(&*op);
      }

      if(!GEVInst || !(GEVInst->getPointerOperandType())){
	return; // can't resolve
      }

      std::string type_str;
      llvm::raw_string_ostream rso(type_str);
      GEVInst->getPointerOperandType()->print(rso);
      std::string strippedType = strip(rso.str()); // TODO: Why do same structure types have different IDS?

      // Extract the last index index of the GEP instruction. This
      // index is used to index the function pointer in the global
      // variable.
      // TODO: Clean this up
      int finalIndex = 0;
      for(unsigned int k = 0; k < GEVInst->getNumIndices(); k++){
	if(GEVInst->getOperand(k + 1) != NULL){
	  if(llvm::ConstantInt * constInt =
	     llvm::dyn_cast<llvm::ConstantInt>(&*GEVInst->getOperand(k + 1))){
	    int index = constInt->getZExtValue();
	    finalIndex = index;
	  }
	}
      }


      if(bitcastGlobals.find(strippedType) != bitcastGlobals.end()){

	std::map<std::string, bool> globalNames = bitcastGlobals[strippedType];
	// Extract all global variables of the target type. The target
	// type is the type of the object holding the function pointer
	for (auto &kv: globalNames) {

	  std::string globalName = kv.first;
	  llvm::GlobalVariable * gv = M.getGlobalVariable(llvm::StringRef(globalName), true);
	  if(gv){
	    if(llvm::Constant * constant = llvm::dyn_cast<llvm::Constant>(&*gv)){
	      if(!constant->getOperand(0)) continue;
	      if(llvm::Constant * const2 =  llvm::dyn_cast<llvm::Constant>(&*constant->getOperand(0)))
		{
		  if(const2->getAggregateElement(finalIndex) != NULL){
		    // Extract the "potential" callee function name
		    // from the global object based on the GEP index
		    std::string functionName = const2->getAggregateElement(finalIndex)->getName();
		    llvm::Function * calledFunction = M.getFunction(llvm::StringRef(functionName));
		    if(!calledFunction) continue; // Called function may not be in module
		    if(checkArgs(callInst, calledFunction))
		      functionsCalled[calledFunction] = true;
		  }
		}
	    }
	  }
	  else {
	    if(globalName.empty())  return;
	    llvm::Function * calledFunction = M.getFunction(llvm::StringRef(globalName));
	    if(calledFunction){
	      if(checkArgs(callInst, calledFunction))
		functionsCalled[calledFunction] = true;
	    }
	  }
	}
      }
    }
  }     


  /* The initializeCallGraph function initializes the calllGrah data
   * structures.  Specifically it builds a mapping between structure
   * types and global corresponding to them. This is important for
   * handling indirect calls that use a function pointer embedded
   * inside a global variable of structure type
   */

  void initializeCallGraph(llvm::Module & M) {

    debugFlag = false; // Set Debug Mode to False
    /* Traversing the list of globals in the module The loop extracts
     * the type of each global variable and saves the mapping in a
     * hashmap bitcastGlobals
     */
    for(llvm::Module::global_iterator global = M.global_begin(), globalEnd = M.global_end();
	global != globalEnd; global++){

      llvm::Type * globalType = global->getType();
      std::string type_str;
      llvm::raw_string_ostream rso(type_str);
      globalType->print(rso);
      std::string type_string = rso.str();

      // Only considering struct type globals
      if(filterStructs(type_string) && global->hasInitializer()){

	std::string globalName = global->getName().str();
	// The strip routine normalizes the kernel struct types
	std::string strippedType = strip(type_string);
	std::map<std::string, bool> globalNames;

	if(bitcastGlobals.find(strippedType) != bitcastGlobals.end()){
	  globalNames = bitcastGlobals[strippedType];
	}

	globalNames[globalName] = true;
	bitcastGlobals[strippedType] = globalNames;
      }
    }

    // Adding all module level function names to the functionNames hashMap
    for (llvm::Module::iterator F = M.begin(), Fend = M.end(); F != Fend; ++F){
      functionNames[F->getName().str()] = false;
    }

    if(debugFlag)
      llvm::errs()<<"Function / Type correspondence : \n";
        
    // Find all bitcast instructions within stores, calls etc. The
    // bitcast calls typecast globals to type*
    for (llvm::Module::iterator F = M.begin(), Fend = M.end(); F != Fend; ++F) {
      llvm::Function * func = &*F;
      for(llvm::inst_iterator inst = inst_begin(func), e = inst_end(func); inst != e; ++inst) {

        // In the kernel bitcode the bitcode cast instructions are
        // done as an argument to a function call
        if (llvm::CallInst* callInst = llvm::dyn_cast<llvm::CallInst>(&*inst)){

	  // llvm::Function * F = callInst->getCalledFunction();
	  /* TEST1
	   *
	   * if(F != NULL){                // Only looking at indirect calls
	   continue;
	   }*/

          // traversing list of Call Instruction operands. The bitcast
          // expressions are parsed to extract the kernel globals
          // (these globals hold function pointers)
          for(unsigned int j = 0; j < callInst->getNumArgOperands(); j++){

            llvm::Value * operand = callInst->getOperand(j);
            if (llvm::ConstantExpr* constExpr = llvm::dyn_cast<llvm::ConstantExpr>(&*operand)){

              if(constExpr->getOperand(0) == NULL  || constExpr->getOperand(0)->getValueName() == NULL)
                continue;

              // Extracting the type of the ConstantExpr. This is the
              // target datatype of the bitcast instruction
              std::string type_str;
              llvm::raw_string_ostream rso(type_str);
              constExpr->getType()->print(rso);
              std::string typeString = rso.str();

              // Only considering struct types (these types have the
              // function pointers as field attributes)
              if(!isPrimitiveType(typeString)){

                std::string strippedType = strip(typeString);
                if(bitcastGlobals.find(strippedType) != bitcastGlobals.end()){
                  // Extracting the name of the global variable
                  std::string operandName = std::string(constExpr->getOperand(0)->getValueName()->first().data());
                  llvm::GlobalVariable * gv = M.getGlobalVariable(llvm::StringRef(operandName), true);
                  if(!gv){
		    // Checking if the operand of the bitcast
		    // instruction is a llvm::Function defined in the
		    // Module
                    llvm::Function * funcV = M.getFunction(llvm::StringRef(operandName));
                    if(!funcV){
                      if(debugFlag)
                        llvm::errs() <<" skipping : "<< operandName <<"\n";
                      continue;
                    }
                    else{
                      if(debugFlag){
                        llvm::errs() <<"   Function  : "<<operandName<<"\n";
                        llvm::errs() <<"   Type  : "<<typeString<<" \n";
                      }

                    }
                  }

                  // Adding the map from the data type string to the global name
                  std::map<std::string, bool> globalNames = bitcastGlobals[strippedType];
                  globalNames[operandName] = true;
                  bitcastGlobals[strippedType] = globalNames;
                }
                else{
                  std::map<std::string, bool> globalNames;
                  globalNames[std::string(constExpr->getOperand(0)->getValueName()->first().data())] = true;
                  bitcastGlobals[strippedType] = globalNames;
                }
              }
            }
          }
        }
      }
    }

  }

};


