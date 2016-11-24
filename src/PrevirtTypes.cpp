//
// OCCAM
//
// Copyright (c) 2011-2012, SRI International
//
//  All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// * Neither the name of SRI International nor the names of its contributors may
//   be used to endorse or promote products derived from this software without
//   specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

/*
 * PrevirtTypes.cpp
 *
 *  Created on: Jul 8, 2011
 *      Author: malecha
 */

#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/ADT/APFloat.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Analysis/ValueTracking.h"

#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"

#include "PrevirtTypes.h"
#include "proto/Previrt.pb.h"
#include "Specializer.h"

using namespace llvm;

namespace previrt
{
  PrevirtType::EqCache PrevirtType::cacheEq;

  PrevirtType::PrevirtType()
  {
    buffer.set_type(proto::U);
  }

  PrevirtType::PrevirtType(const proto::PrevirtType& pt)
  {
    buffer.CopyFrom(pt);
  }

  PrevirtType&
  PrevirtType::operator=(const PrevirtType& from)
  {
    this->buffer.CopyFrom(from.buffer);
    return *this;
  }

  bool
  PrevirtType::operator!=(const PrevirtType& other) const
  {
    return !(*this == other);
  }

  bool
  PrevirtType::operator==(const PrevirtType& other) const
  {
    if (buffer.type() != other.buffer.type())
      return false;
    switch (buffer.type()) {
    default:
      assert(false && "missing case in PrevirtType::operator==");
    case proto::U:
    case proto::N:
      return true;
    case proto::S:
      return buffer.str().data() == other.buffer.str().data();
    case proto::I:
    case proto::F:
      return buffer.int_().bits() == other.buffer.int_().bits()
          && buffer.int_().value() == other.buffer.int_().value();
    case proto::G:
      return buffer.global().name() == other.buffer.global().name();
    }
    return false;
  }

  static bool
  StringFromValue(const Value* val, StringRef &out)
  {
    return getConstantStringInfo(val, out, 0, false);
  }

  PrevirtType
  PrevirtType::unknown()
  {
    PrevirtType t;
    t.buffer.set_type(proto::U);
    return t;
  }

  PrevirtType
  PrevirtType::abstract(const llvm::Value* const val)
  {
    PrevirtType result;
    result.buffer.set_type(proto::U);
    const Constant* cnst = dyn_cast<const Constant>(val);
    if (cnst == NULL) {
#if DUMP
      errs() << "??\n";
#endif
      return result;
    }
#if DUMP

    errs() << *val << " ~ ";
    if (const ConstantInt* iv = dyn_cast<const ConstantInt>(val))
    errs() << *iv;
    else if (const ConstantArray* av = dyn_cast<const ConstantArray>(val))
    errs() << *av;
    else if (const ConstantFP* fv = dyn_cast<const ConstantFP>(val))
    errs() << *fv;
    else if (const ConstantExpr* cv = dyn_cast<const ConstantExpr>(val)) {
      if (cv->isNullValue())
      errs() << "NULL";
      switch (cv->getOpcode())
      {
        default:
        errs() << "??";
        break;
        case 41: // BITCAST
        errs() << "CONSTANT:" << *cv;
        break;
#if 0
        case Instruction::GetElementPtrInst: // GETELEMENTPTR
        //          errs() << "\nGetElementPtr" << *cv << "\n";
        //          for (ConstantExpr::op_iterator itr = cv->op_begin(), end = cv->op_end(); itr != end; ++itr) {
        //            errs() << "[["<< **itr << "]]";
        //          }
        Value* arg = cv->getOperand(0);
        if (cv->isGEPWithNoNotionalOverIndexing()) {
          if (GlobalVariable* gv = dyn_cast<GlobalVariable>(arg)) {
            if (gv->isConstant() && !gv->mayBeOverridden()) {
              if (ConstantArray* cnst = dyn_cast<ConstantArray> (
                      gv->getInitializer())) {

                if (cnst->isString()) {
                  errs() << "\"" << cnst->getAsString() << "\"";
                } else if (cnst->isCString()) {
                  errs() << "\"" << cnst->getAsCString() << "\"";
                } else {
                  errs() << "[";
                  for (ConstantArray::const_op_iterator i = cnst->op_begin(),
                      e = cnst->op_end(); i != e; ++i) {
                    errs() << (**i) << ",";
                  }
                  errs() << "]";
                }
              } else {
                errs() << "Non array";
              }
            } else
            errs() << "<NON-CONSTANT:" << cv->getOpcode() << "> ??";
          } else {
            errs() << "??";
          }
        } else {
          errs() << "??";
        }

        break;
#endif
      }
    } else
    errs() << "??";
    errs() << "\n";
#endif
    if (const ConstantInt* ci = dyn_cast<const ConstantInt> (val)) {
      result.buffer.set_type(proto::I);
      result.buffer.mutable_int_()->set_bits(ci->getBitWidth());
      result.buffer.mutable_int_()->set_value(
          ci->getValue().toString(16, true));
      return result;
    } else if (cnst->isNullValue()) {
      result.buffer.set_type(proto::N);
      return result;
    } else if (const ConstantFP* cf = dyn_cast<const ConstantFP>(val)) {
      char dst[128];
      const APFloat& val = cf->getValueAPF();
      val.convertToHexString(dst, 0, false, APFloat::rmNearestTiesToEven);
      if (&val.getSemantics() == &APFloat::Bogus) {
        result.buffer.mutable_float_()->set_sem(proto::Bogus);
      } else if (&val.getSemantics() == &APFloat::IEEEhalf) {
        result.buffer.mutable_float_()->set_sem(proto::IEEEhalf);
      } else if (&val.getSemantics() == &APFloat::IEEEdouble) {
        result.buffer.mutable_float_()->set_sem(proto::IEEEdouble);
      } else if (&val.getSemantics() == &APFloat::IEEEquad) {
        result.buffer.mutable_float_()->set_sem(proto::IEEEquad);
      } else if (&val.getSemantics() == &APFloat::IEEEsingle) {
        result.buffer.mutable_float_()->set_sem(proto::IEEEsingle);
      } else if (&val.getSemantics() == &APFloat::PPCDoubleDouble) {
        result.buffer.mutable_float_()->set_sem(proto::PPCDoubleDouble);
      } else if (&val.getSemantics() == &APFloat::x87DoubleExtended) {
        result.buffer.mutable_float_()->set_sem(proto::x87DoubleExtended);
      } else {
        return result;
      }
      result.buffer.mutable_float_()->set_data(dst);
      result.buffer.set_type(proto::F);
      return result;
    } else if (const GlobalValue* gv = dyn_cast<const GlobalValue>(cnst)) {
      const GlobalVariable* gvar = dyn_cast<GlobalVariable>(gv);

      if (gv->getName() != "") {
        if (gv->isExternalLinkage(gv->getLinkage())) {
          result.buffer.set_type(proto::G);
          result.buffer.mutable_global()->set_name(gv->getName().data());
          if (gvar) {
            result.buffer.mutable_global()->set_is_const(gvar->isConstant());
          }
          return result;
        } else {
          errs() << gv->getName() << " is not external!\n";
	  return result;
        }
      }
    } else if (isa<const ConstantExpr>(cnst)) {
	StringRef out;
	// See if it's a string constant
	if (StringFromValue(val, out)) {
	  result.buffer.set_type(proto::S);
	  result.buffer.mutable_str()->set_data(out);
	  return result;
	}
    }
    return result;
  }

  int
  PrevirtType::refines(const llvm::Value* const val) const
  {
    assert(val != NULL);
    const Constant* cnst = dyn_cast<const Constant>(val);
    // TODO: Why did I start needing this?
    if (cnst == NULL) {
      if (this->buffer.type() == proto::U)
        return LOOSE_MATCH;
      else
        return NO_MATCH;
    }
    switch (buffer.type()) {
    default:
      assert(false);
      break;
    case proto::U:
      return LOOSE_MATCH;
    case proto::N: {
      if (cnst->isNullValue())
        return EXACT_MATCH;
      else
        return NO_MATCH;
    }
    case proto::S: {
      StringRef out;
      if (StringFromValue(val, out)) {
        if (out == buffer.str().data())
          return EXACT_MATCH;
        else
          return NO_MATCH;
      }
      return NO_MATCH;
    }
    case proto::I:
      if (const ConstantInt* va = dyn_cast<const ConstantInt>(val)) {
        if (buffer.int_().bits() == va->getBitWidth()
            && buffer.int_().value() == va->getValue().toString(16, true))
          return EXACT_MATCH;
      }
      return NO_MATCH;
    case proto::F:
      if (const ConstantFP* va = dyn_cast<const ConstantFP>(val)) {
        const fltSemantics* sem = NULL;
        switch (buffer.float_().sem()) {
#define CASE(x) case proto::x: { if (&va->getValueAPF().getSemantics() != &APFloat::x) return NO_MATCH; sem = &APFloat::x; break; }
        CASE(IEEEdouble)
        CASE(IEEEhalf)
        CASE(IEEEsingle)
        CASE(IEEEquad)
        CASE(x87DoubleExtended)
        CASE(PPCDoubleDouble)
        CASE(Bogus)
#undef CASE
        }
        APFloat apf(*sem, buffer.float_().data());
        if (apf.bitwiseIsEqual(va->getValueAPF())) {
          return EXACT_MATCH;
        }
      }
      return NO_MATCH;
    case proto::G:
      if (const GlobalValue* gv = dyn_cast<const GlobalValue>(val->stripPointerCasts())) {
        if (gv->getName() == buffer.global().name()) {
          return EXACT_MATCH;
        }
      }
      return NO_MATCH;
    }

    return NO_MATCH;
  }

  llvm::Value*
  PrevirtType::concretize(Module& M, Type* type) const
  {
      llvm::Value *concreteValue = NULL;
      switch (buffer.type()) {
      default:
	  break;
      case proto::N:
	  concreteValue = Constant::getNullValue(type);
	  break;
      case proto::I:
	  assert(buffer.int_().IsInitialized());
	  concreteValue = 
	      ConstantInt::get(M.getContext(),
			       APInt(buffer.int_().bits(), buffer.int_().value(), 16));
	  break;
      case proto::F:
	  concreteValue =
	      ConstantFP::get(type, StringRef(buffer.float_().data()));
	  break;
      case proto::S:
	  assert(buffer.str().IsInitialized());
	  if (!buffer.str().cstr())
	      break;
	  { // Scope sc locally
	      GlobalVariable* sc = 
		  materializeStringLiteral(M, buffer.str().data().c_str());
	      concreteValue = charStarFromStringConstant(M, sc);
	  }
	  break;
      case proto::G:
	  assert(buffer.global().IsInitialized());
	  concreteValue = M.getGlobalVariable(buffer.global().name(), false);
	  if (concreteValue == NULL) {
	      // GlobalValues are always pointers and the resulting type
	      // will be a pointer to the type in the constructor, so we
	      // need to remove one of the pointer types to get the right
	      // type out. This works assuming the desired type was already
	      // a pointer, which should be the case because we only concretize
	      // arguments and you can't pass a structure or function except
	      // as a pointer.
	      assert(type->isPointerTy() 
		     && "Unexpected concretization of G to non-pointer type");
	      Type * elemType = type->getContainedType(0);
	      if (elemType->isFunctionTy()) {
		  concreteValue = M.getFunction(buffer.global().name());
		  if (concreteValue == NULL) {
		      concreteValue = Function::Create(cast<FunctionType>(elemType),
						       GlobalVariable::ExternalLinkage, buffer.global().name(), &M);
		  }
	      } else {
		  concreteValue = new GlobalVariable(M, elemType, buffer.global().is_const(),
						     GlobalVariable::ExternalLinkage, NULL, buffer.global().name());
	      }
	  }
	  break;
      }
      assert(type == concreteValue->getType()
	     && "Concretization did not procude value of expected type!");
      return concreteValue;
  }

  bool
  PrevirtType::isConcrete() const
  {
    // TODO: check which of these work
      
    return buffer.type() == proto::I || // Integer
      buffer.type() == proto::G || // Global
      buffer.type() == proto::N || // Null
      buffer.type() == proto::S || // String
      buffer.type() == proto::F;  // float
  }

  bool
  PrevirtType::isUnknown() const
  {
    return buffer.type() == proto::U;
  }

  std::string
  PrevirtType::to_string() const
  {
    switch (buffer.type()) {
    default:
      return "?";
    case proto::N:
      return "null";
    case proto::I:
      assert(buffer.int_().IsInitialized());
      return std::string("0x") + buffer.int_().value();
    case proto::F:
      return buffer.float_().data();
    case proto::S: {
      assert(buffer.str().IsInitialized());
      if (!buffer.str().cstr())
        return NULL;
      return std::string("S:") + utohexstr(HashString(buffer.str().data()));
    }
    case proto::G:
      assert(buffer.global().IsInitialized());
      return buffer.global().name();
    }

    return "?";
  }

#if 0
  static Function*
  buildNullEquality(Type* typ, LLVMContext& ctx)
  {
    Type* ft[2] = {typ, typ};
    FunctionType* ftyp = FunctionType::get(Type::getInt1Ty(ctx),
        ArrayRef<Type*> (ft), false);
    Function* f = Function::Create(ftyp, GlobalValue::LinkOnceODRLinkage,
        "null_eq");
    BasicBlock* bb = BasicBlock::Create(ctx, Twine("entry"), f);
    IRBuilder<> builder(bb);

    Function::ArgumentListType::iterator var = f->getArgumentList().begin();
    Argument* a1 = &(*var);
    var++;
    Argument* a2 = &(*var);
    Value* test = NULL;
    if (typ->isPointerTy()) {
      test = builder.CreateICmpEQ(
          builder.CreatePtrToInt(a1, Type::getInt64Ty(ctx)),
          builder.CreatePtrToInt(Constant::getNullValue(typ), Type::getInt64Ty(ctx)));
    } else if (typ->isIntegerTy()) {
      test = builder.CreateICmpEQ(a1, Constant::getNullValue(typ));
    } else {
      assert (false && "bad type for null equality");
    }

    builder.CreateRet(test);

    f->addFnAttr(Attribute::AlwaysInline);
    return f;
  }
#endif

  static Function*
  buildIntEquality(IntegerType* typ, LLVMContext& ctx)
  {
    Type* ft[2] =
      { typ, typ };
    FunctionType* ftyp = FunctionType::get(Type::getInt1Ty(ctx),
        ArrayRef<Type*>(ft), false);
    Function* f = Function::Create(ftyp, GlobalValue::LinkOnceODRLinkage,
        "int_eq");
    BasicBlock* bb = BasicBlock::Create(ctx, Twine("entry"), f);
    IRBuilder<> builder(bb);

    Function::ArgumentListType::iterator var = f->getArgumentList().begin();
    Argument* a1 = &(*var);
    var++;
    Argument* a2 = &(*var);
    Value* test = builder.CreateICmpEQ(a1, a2);
    builder.CreateRet(test);

    f->addFnAttr(Attribute::AlwaysInline);
    return f;
  }

  static Function*
  buildStringEquality(PointerType* typ, Module& M)
  {
    Type* ft[2] =
      { typ, typ };
    FunctionType* ftyp = FunctionType::get(Type::getInt1Ty(M.getContext()),
        ArrayRef<Type*>(ft), false);
    Function* f = Function::Create(ftyp, GlobalValue::LinkOnceODRLinkage,
        "int_eq");
    BasicBlock* bb = BasicBlock::Create(M.getContext(), Twine("entry"), f);
    IRBuilder<> builder(bb);

    FunctionType* strcmp_type = FunctionType::get(
        Type::getInt32Ty(M.getContext()), ArrayRef<Type*>(ft), false);
    Constant* strcmp = M.getOrInsertFunction("strcmp", strcmp_type);

    Value* vals[2] =
      { &*(f->getArgumentList().begin()), &*(++f->getArgumentList().begin()) };
    Value* test = builder.CreateCall(strcmp, ArrayRef<Value*>(vals, 2), "");
    Value* result = builder.CreateICmpEQ(test,
        ConstantInt::get(test->getType(), 0, true));
    builder.CreateRet(result);
    f->addFnAttr(Attribute::AlwaysInline);
    return f;
  }

  Function*
  PrevirtType::getEqualityFunction(Module* M) const
  {
    switch (buffer.type()) {
    default:
      return NULL;
    case proto::N: {
      return NULL;
    }
    case proto::I: {
      assert(buffer.int_().IsInitialized());
      IntegerType* typ = Type::getIntNTy(M->getContext(), buffer.int_().bits());
      EqCache::iterator i = PrevirtType::cacheEq.find(typ);
      if (i != PrevirtType::cacheEq.end()) {
        return i->second;
      }
      Function* f = buildIntEquality(typ, M->getContext());

      PrevirtType::cacheEq.insert(std::make_pair(typ, f));
      M->getFunctionList().push_back(f);
      return f;
    }
    case proto::S: {
      assert(buffer.str().IsInitialized());
      PointerType* typ = Type::getInt8PtrTy(M->getContext());
      EqCache::iterator i = PrevirtType::cacheEq.find(typ);
      if (i != PrevirtType::cacheEq.end()) {
        return i->second;
      }
      Function* f = buildStringEquality(typ, *M);

      PrevirtType::cacheEq.insert(std::make_pair(typ, f));
      M->getFunctionList().push_back(f);
      return f;
    }
    }

    return NULL;
  }

  template<>
    void
    codeInto<previrt::proto::PrevirtType, PrevirtType>(
        const previrt::proto::PrevirtType& buf, PrevirtType& result)
    {
      assert(buf.IsInitialized());
      result.buffer.CopyFrom(buf);
    }

  template<>
    void
    codeInto<PrevirtType, proto::PrevirtType>(const PrevirtType& typ,
        proto::PrevirtType& buf)
    {
      assert(typ.buffer.IsInitialized());
      buf.CopyFrom(typ.buffer);
    }
}
