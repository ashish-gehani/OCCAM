/*

  Author: Hashim Sharif
  Email: hsharif3@illinois.edu

*/

#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/IR/Instruction.h"        
#include "llvm/IR/Instructions.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Constants.h"
#include<map>
#include<set>
#include<iostream>
#include<vector>
#include<map>
#include<fstream>
#include<queue>
#include<stack>
#include<string.h>

using namespace llvm;
using namespace std;


class ExtendedCallGraph {

private:

  static char ID;
  map<string, map<string, bool>> bitcastGlobals;
  map<string, string> functionNames;
  bool debugFlag;
                
  bool isPrimitiveType(string type){

    if(type != "i32" && type != "i1" && type != "i8*" && type != "i64")
      return false;
    else
      return true;
  }

  string strip(const string& in) {

    if(in.find("struct") == -1) // The casted type is not a struct type
      return in;

    char final[2000];
    char* cursor = final;
    for(string::const_iterator c = in.begin(), end = in.end(); c != end; ++c) {
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


  bool filterStructs(string type_string){

    if(type_string.find("%struct") != -1 && type_string.find("(") == -1 && type_string.find("[") == -1)
      return true;
    else
      return false;
  }


  bool isTraversed(map<Function*, bool> & successorMap, Function * function, int & count){

    if(successorMap.find(function) != successorMap.end()){    
      return true;
    }
    else{

      successorMap[function] = true;
      count += 1; 
      return false;
    }
  }


  void incrementResolved(map<Instruction*, bool> & resolvedInst, Instruction * Inst, int & resolved){

    if(resolvedInst.find(Inst) == resolvedInst.end()){
      resolved++;
      resolvedInst[Inst] = true;
    }
  }


  void incrementUnresolved(map<Instruction*, bool> & unresolvedInst, Instruction * Inst, int & unresolved){
    
    if(unresolvedInst.find(Inst) == unresolvedInst.end()){
      unresolved++;
      unresolvedInst[Inst] = true;
    }
  }
  
  bool checkArgs(CallInst* ci, Function *f){

      
    if(ci->getNumOperands() != f->getFunctionType()->getNumParams())
      return false;

    return true; // hacking

  /*   
    int i = 0;
    for(Function::arg_iterator it = f->arg_begin(), end = f->arg_end(); it != end; it++){
      Value * arg = &*it;
      if(arg->getType() != ci->getOperand(i)->getType())
        return false; 
      i++;   
    }
    return true;
   */
  }

public:

  // The resolve call routines takes as input an indirect callInst and fills the functionsCalled map with the called functions
  void resolveCall(CallInst * callInst, Module & M, map<Function*, bool> & functionsCalled){

    // Ignoring direct function calls. Direct function calls return non NULL pointers to the called function
    Function * calledFunction = callInst->getCalledFunction();
    if(calledFunction != NULL){
	   return;
    }

    // callValue is the operand of the callInst
    Value * callValue = callInst->getCalledValue();
    // Resolving calls of the form "call bitcast_expresssion $Type $Function"
    if(ConstantExpr * callExpr = dyn_cast<ConstantExpr>(&*callValue)){
      if(Function * calledFunction = dyn_cast<Function>(callExpr->getOperand(0))){         
         if(checkArgs(callInst, calledFunction))
           functionsCalled[calledFunction] = true;
      }
    }

    // FIXIT: Add an additional check for a bitcast instruction


            if(Instruction * inst = dyn_cast<Instruction>(&*callValue)){

		// Extracting the first GEP inst that uses the operand of the call instruction. This instruction extracts the function pointer from a structure type global
		GetElementPtrInst* GEVInst;
		while(true && inst != NULL){

			if((GEVInst = dyn_cast<GetElementPtrInst>(&*inst))){
			  break;
			}
			Value * op = inst->getOperand(0); // FIXIT: only handling operand(0). Handling only loads?
			inst = dyn_cast<Instruction>(&*op);
	    }

	    if(GEVInst == NULL || GEVInst->getPointerOperandType() == NULL){
	      return; // can't resolve
	    }

	    string type_str;
	    llvm::raw_string_ostream rso(type_str);
            GEVInst->getPointerOperandType()->print(rso);
            string strippedType = strip(rso.str()); // TODO: Why do same structure types have different IDS?

        // Extract the last index index of the GEP instruction. This index is used to index the function pointer in the global variable
		// TODO: Clean this up
		int finalIndex = 0;
		for(unsigned int k = 0; k < GEVInst->getNumIndices(); k++){
			if(GEVInst->getOperand(k + 1) != NULL){
			  if(ConstantInt * constInt = dyn_cast<ConstantInt>(&*GEVInst->getOperand(k + 1))){
				int index = constInt->getZExtValue();
				finalIndex = index;
			  }
			}
		}


		if(bitcastGlobals.find(strippedType) != bitcastGlobals.end()){

			  map<string, bool> globalNames = bitcastGlobals[strippedType];
			  // Extract all global variables of the target type. The target type is the type of the object holding the function pointer
			  for (std::map<string, bool>::iterator it = globalNames.begin(); it != globalNames.end(); ++it) {

				string globalName = it->first;
				GlobalVariable * gv = M.getGlobalVariable(StringRef(globalName), true);
				if(gv != NULL){
				  if(Constant * constant = dyn_cast<Constant>(&*gv)){
					if(constant->getOperand(0) == NULL) continue;
					if(Constant * const2 =  dyn_cast<Constant>(&*constant->getOperand(0)))
					{
						if(const2->getAggregateElement(finalIndex) != NULL){
						  // Extract the "potential" callee function name from the global object based on the GEP index
					      string functionName = const2->getAggregateElement(finalIndex)->getName();
						  Function * calledFunction = M.getFunction(StringRef(functionName));
						  if(calledFunction == NULL) continue; // Called function may not be in module
						  if(checkArgs(callInst, calledFunction))
                                                    functionsCalled[calledFunction] = true;
						}
					 }
				  }
				}
				else {
				  if(globalName == NULL)  return;
				  Function * calledFunction = M.getFunction(StringRef(globalName));
				  if(calledFunction != NULL){
                                        if(checkArgs(callInst, calledFunction))
					  functionsCalled[calledFunction] = true;
				  }
				}
			  }
		  }
	 }


  }     


   /* The initializeCallGraph function initializes the calllGrah data structures.
    * Specifically it builds a mapping between structure types and global corresponding to them. This is important for
    * handling indirect calls that use a function pointer embedded inside a global variable of structure type
    */

  void initializeCallGraph(Module & M) {

    debugFlag = false; // Set Debug Mode to False
    /* Traversing the list of globals in the module
     * The loop extracts the type of each global variable and saves the mapping in a hashmap bitcastGlobals
     */
    for(Module::global_iterator global = M.global_begin(), globalEnd = M.global_end(); global != globalEnd; global++){

        Type * globalType = global->getType();
        string type_str;
        llvm::raw_string_ostream rso(type_str);
        globalType->print(rso);
        string type_string = rso.str();

        // Only considering struct type globals
        if(filterStructs(type_string) && global->hasInitializer()){

          string globalName = global->getName().str();
          // The strip routine normalizes the kernel struct types
          string strippedType = strip(type_string);
          map<string, bool> globalNames;

          if(bitcastGlobals.find(strippedType) != bitcastGlobals.end()){
            globalNames = bitcastGlobals[strippedType];
          }

          globalNames[globalName] = true;
          bitcastGlobals[strippedType] = globalNames;
       }
    }

    // Adding all module level function names to the functionNames hashMap
    for (Module::iterator F = M.begin(), Fend = M.end(); F != Fend; ++F){
      functionNames[F->getName().str()] = false;
    }

    if(debugFlag)
      errs()<<"Function / Type correspondence : \n";
        
    // Find all bitcast instructions within stores, calls etc. The bitcast calls typecast globals to type*
    for (Module::iterator F = M.begin(), Fend = M.end(); F != Fend; ++F) {
      Function * func = &*F;
      for(inst_iterator inst = inst_begin(func), e = inst_end(func); inst != e; ++inst) {

    	//FIXIT SHOULD HANLDLE GENERAL BITCAST CALLS SEPARATELY
        /*if(BitCastInst * bitcastInst = dyn_cast<BitCastInst>(&*inst)){
          if(ConstantExpr* constExpr = dyn_cast<ConstantExpr>(&*bitcastInst))
          {
              if(debugFlag)
                errs()<<"constant EXPRESSION\n";
          }
        }*/

        // In the kernel bitcode the bitcode cast instructions are done as an argument to a function call
        if (CallInst* callInst = dyn_cast<CallInst>(&*inst)){

         // Function * F = callInst->getCalledFunction();
         /* TEST1
          *
          * if(F != NULL){                // Only looking at indirect calls
            continue;
          }*/

          // traversing list of Call Instruction operands. The bitcast expressions are parsed to extract the kernel globals (these globals hold function pointers)
          for(unsigned int j = 0; j < callInst->getNumArgOperands(); j++){

            Value * operand = callInst->getOperand(j);
            if (ConstantExpr* constExpr = dyn_cast<ConstantExpr>(&*operand)){

              if(constExpr->getOperand(0) == NULL  || constExpr->getOperand(0)->getValueName() == NULL)
                continue;

              // Extracting the type of the ConstantExpr. This is the target datatype of the bitcast instruction
              string type_str;
              llvm::raw_string_ostream rso(type_str);
              constExpr->getType()->print(rso);
              string typeString = rso.str();

              // Only considering struct types (these types have the function pointers as field attributes)
              if(!isPrimitiveType(typeString)){

                string strippedType = strip(typeString);
                if(bitcastGlobals.find(strippedType) != bitcastGlobals.end()){
                  // Extracting the name of the global variable
                  string operandName = string(constExpr->getOperand(0)->getValueName()->first().data());
                  GlobalVariable * gv = M.getGlobalVariable(StringRef(operandName), true);
                  if(gv == NULL){
                	// Checking if the operand of the bitcast instruction is a llvm::Function defined in the Module
                    Function * funcV = M.getFunction(StringRef(operandName));
                    if(funcV == NULL){
                      if(debugFlag)
                        errs()<<" skipping : "<< operandName <<"\n";
                      continue;
                    }
                    else{
                      if(debugFlag){
                        errs()<<"   Function  : "<<operandName<<"\n";
                        errs()<<"   Type  : "<<typeString<<" \n";
                      }

                    }
                  }

                  // Adding the map from the data type string to the global name
                  map<string, bool> globalNames = bitcastGlobals[strippedType];
                  globalNames[operandName] = true;
                  bitcastGlobals[strippedType] = globalNames;
                }
                else{
                  map<string, bool> globalNames;
                  globalNames[string(constExpr->getOperand(0)->getValueName()->first().data())] = true;
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


