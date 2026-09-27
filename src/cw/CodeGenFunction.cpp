/// \file CodeGenFunction.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "CodeGenFunction.h"

#include <algorithm>
#include <cstdint>
#include <iterator>
#include <vector>

#include <boost/assert.hpp>

#include <llvm/IR/CFG.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/GlobalVariable.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Intrinsics.h>
#include <llvm/IR/Module.h>

#include "ASTContext.h"
#include "SemaConstant.h"

namespace cw::codegen_detail {

namespace {

bool IsAggregate(const Type& type) { return type.AsArrayType() || type.AsStructType(); }

void NameCallResult(llvm::CallInst& call) {
  if (!call.getType()->isVoidTy()) {
    call.setName("call");
  }
}

bool HasArrayElements(const ArrayType& type) {
  // An empty inner dimension removes all leaf elements; zero-sized class elements still have lifetimes.
  for (const auto* array = &type; array; array = array->GetElementType().GetTypePtr()->AsArrayType()) {
    if (array->GetLength() == 0) {
      return false;
    }
  }
  return true;
}

}  // namespace

CodeGenFunction::CodeGenFunction(CodeGen& codegen, llvm::Function& function)
    : codegen_(codegen), function_(function), builder_(*codegen.llvm_context_) {}

CodeGenFunction::ConditionalEvaluation::ConditionalEvaluation(CodeGenFunction& owner, llvm::BasicBlock* entry,
                                                              llvm::BasicBlock* arm)
    : owner_(owner),
      previous_entry_(owner.conditional_entry_),
      previous_condition_(owner.conditional_condition_),
      previous_inverted_(owner.conditional_inverted_) {
  owner_.conditional_condition_ = nullptr;
  owner_.conditional_inverted_ = false;
  if (previous_entry_) {
    return;
  }
  owner_.conditional_entry_ = entry;
  // A single split already provides a dominating formation condition. Nested or multi-edge
  // paths need a flag reset at the outer split, where even the skipped path executes it.
  const auto* branch = llvm::dyn_cast<llvm::CondBrInst>(entry->getTerminator());
  if (branch && arm->getSinglePredecessor() == entry) {
    if (branch->getSuccessor(0) == arm) {
      owner_.conditional_condition_ = branch->getCondition();
    } else if (branch->getSuccessor(1) == arm) {
      owner_.conditional_condition_ = branch->getCondition();
      owner_.conditional_inverted_ = true;
    }
  }
}

CodeGenFunction::ConditionalEvaluation::~ConditionalEvaluation() {
  owner_.conditional_entry_ = previous_entry_;
  owner_.conditional_condition_ = previous_condition_;
  owner_.conditional_inverted_ = previous_inverted_;
}

Address CodeGenFunction::MakeAddress(llvm::Value* pointer, llvm::Type* element_type, const Type* semantic_type,
                                     Overlap overlap) const {
  const auto alignment = semantic_type ? llvm::Align(codegen_.GetTypeLayoutForMem(*semantic_type).alignment)
                                       : codegen_.module_->getDataLayout().getABITypeAlign(element_type);
  return {pointer, element_type, alignment, semantic_type, overlap};
}

Address CodeGenFunction::CreateStorage(llvm::Type* type, llvm::StringRef name, const Type* semantic_type) {
  // Reserve storage in the entry block; initialization remains at its source evaluation point.
  auto& entry = function_.getEntryBlock();
  llvm::IRBuilder<> allocations(function_.getContext());
  allocations.SetInsertPoint(&entry, last_alloca_ ? std::next(last_alloca_->getIterator()) : entry.begin());
  auto* storage = allocations.CreateAlloca(type, nullptr, name);
  last_alloca_ = storage;
  Address address = MakeAddress(storage, type, semantic_type, Overlap::DoesNotOverlap);
  storage->setAlignment(address.alignment);
  return address;
}

Address CodeGenFunction::DeclareVariable(const VarDecl& declaration, llvm::StringRef name) {
  auto result = codegen_.ConvertTypeForMem(*declaration.type.GetTypePtr());
  if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&result)) {
    codegen_.DiagnoseTypeConversionFailure(declaration, *failure, "this local variable type");
    return {};
  }
  auto* type = std::get<llvm::Type*>(result);
  if (type->isVoidTy()) {
    codegen_.Unsupported(declaration, "this local variable type");
    return {};
  }
  if (name.empty()) {
    name = declaration.name;
  }
  Address address = CreateStorage(type, name, declaration.type.GetTypePtr());
  locals_.emplace(&declaration, address);
  return address;
}

Address CodeGenFunction::GetStorage(const VarDecl& declaration) {
  if (const auto it = codegen_.globals_.find(&declaration); it != codegen_.globals_.end()) {
    return MakeAddress(it->second, it->second->getValueType(), declaration.type.GetTypePtr(), Overlap::DoesNotOverlap);
  }
  const auto it = locals_.find(&declaration);
  if (it == locals_.end()) {
    codegen_.InternalError(declaration, "variable declaration has no storage");
    return {};
  }
  return it->second;
}

Address CodeGenFunction::EmitArrayElement(Address array, llvm::Value* index, bool in_bounds) {
  auto* type = llvm::cast<llvm::ArrayType>(array.element_type);
  auto* element_type = type->getElementType();
  // Compiler-generated indices stay within the array; user subscripts carry no bounds promise yet.
  const auto flags = in_bounds ? llvm::GEPNoWrapFlags::inBounds() | llvm::GEPNoWrapFlags::noUnsignedWrap()
                               : llvm::GEPNoWrapFlags::none();
  auto* pointer =
      builder_.CreateGEP(type, array.pointer, {llvm::ConstantInt::get(index->getType(), 0), index}, "element", flags);
  const auto stride = codegen_.module_->getDataLayout().getTypeAllocSize(element_type).getFixedValue();
  const auto* semantic_type = array.semantic_type->AsArrayType()->GetElementType().GetTypePtr();
  return {pointer, element_type, llvm::commonAlignment(array.alignment, stride), semantic_type,
          Overlap::DoesNotOverlap};
}

Address CodeGenFunction::EmitStructElement(Address object, unsigned index, llvm::StringRef name) {
  auto* type = llvm::cast<llvm::StructType>(object.element_type);
  auto* pointer = builder_.CreateStructGEP(type, object.pointer, index, name);
  const auto offset = codegen_.module_->getDataLayout().getStructLayout(type)->getElementOffset(index);
  return {pointer, type->getElementType(index), llvm::commonAlignment(object.alignment, offset)};
}

Address CodeGenFunction::EmitBase(Address object, const StructDecl& declaration) {
  const auto& shared = *std::get<const StructLayout*>(codegen_.ast_context_->GetStructLayout(declaration));
  const auto& representation = codegen_.struct_representations_.at(&declaration);
  Address address = object;
  if (*shared.base_offset != 0) {
    if (representation.base_index) {
      address = EmitStructElement(object, *representation.base_index, "base");
    } else {
      address.pointer =
          builder_.CreateGEP(builder_.getInt8Ty(), object.pointer, builder_.getInt64(*shared.base_offset), "base",
                             llvm::GEPNoWrapFlags::inBounds() | llvm::GEPNoWrapFlags::noUnsignedWrap());
    }
  }
  address.element_type = codegen_.struct_representations_.at(declaration.base_type->GetDeclaration()).type;
  address.alignment = llvm::commonAlignment(object.alignment, *shared.base_offset);
  address.semantic_type = declaration.base_type;
  address.overlap = Overlap::MayOverlap;
  return address;
}

Address CodeGenFunction::EmitField(Address object, const StructDecl& declaration, const FieldDecl& field) {
  const auto& representation = codegen_.struct_representations_.at(&declaration);
  Address address = EmitStructElement(object, representation.field_indices.at(&field), field.name);
  address.semantic_type = field.type.GetTypePtr();
  address.overlap = Overlap::DoesNotOverlap;
  return address;
}

std::uint64_t CodeGenFunction::GetOperationSize(Address address) const {
  BOOST_ASSERT(address.semantic_type);
  if (const auto* record = address.semantic_type->AsStructType()) {
    const auto& layout =
        *std::get<const StructLayout*>(codegen_.ast_context_->GetStructLayout(*record->GetDeclaration()));
    if (record->GetDeclaration()->IsEmpty()) {
      return 0;
    }
    if (address.overlap == Overlap::MayOverlap) {
      return layout.data_size;
    }
  }
  return codegen_.GetTypeLayoutForMem(*address.semantic_type).size;
}

void CodeGenFunction::EmitAggregateCopy(Address destination, Address source) {
  BOOST_ASSERT(destination.element_type == source.element_type);
  const auto size = std::min(GetOperationSize(destination), GetOperationSize(source));
  // Both expressions have already been evaluated, including for zero-sized objects.
  // LLVM memcpy permits equal source and destination addresses, so self-assignment needs no branch.
  if (size != 0) {
    builder_.CreateMemCpy(destination.pointer, destination.alignment, source.pointer, source.alignment, size);
  }
}

llvm::Value* CodeGenFunction::EmitCoercedLoad(Address source, llvm::Type* type) {
  const auto& layout = codegen_.module_->getDataLayout();
  const auto size = GetOperationSize(source);
  BOOST_ASSERT(size != 0);
  if (layout.getTypeStoreSize(type).getFixedValue() <= size) {
    return builder_.CreateAlignedLoad(type, source.pointer, source.alignment);
  }
  // The ABI may round up the value without providing extra readable bytes in the source object.
  Address temporary = CreateStorage(type, "coerce");
  builder_.CreateMemCpy(temporary.pointer, temporary.alignment, source.pointer, source.alignment, size);
  return builder_.CreateAlignedLoad(type, temporary.pointer, temporary.alignment);
}

void CodeGenFunction::EmitCoercedStore(llvm::Value* value, Address destination) {
  const auto& layout = codegen_.module_->getDataLayout();
  const auto size = GetOperationSize(destination);
  BOOST_ASSERT(size != 0);
  if (layout.getTypeStoreSize(value->getType()).getFixedValue() <= size) {
    builder_.CreateAlignedStore(value, destination.pointer, destination.alignment);
    return;
  }
  // Only the object's bytes may be written, even if the ABI supplies a wider representation.
  if (value->getType()->isIntegerTy()) {
    auto* narrowed = builder_.CreateTrunc(value, builder_.getIntNTy(size * 8), "coerce");
    builder_.CreateAlignedStore(narrowed, destination.pointer, destination.alignment);
    return;
  }
  Address temporary = CreateStorage(value->getType(), "coerce");
  builder_.CreateAlignedStore(value, temporary.pointer, temporary.alignment);
  builder_.CreateMemCpy(destination.pointer, destination.alignment, temporary.pointer, temporary.alignment, size);
}

llvm::Value* CodeGenFunction::EmitLoadOfScalar(Address address, const Type& type) {
  BOOST_ASSERT(address.element_type == std::get<llvm::Type*>(codegen_.ConvertTypeForMem(type)));
  auto* value = builder_.CreateAlignedLoad(address.element_type, address.pointer, address.alignment);
  if (const auto* builtin = type.AsBuiltinType(); builtin && builtin->GetBuiltinTypeKind() == BuiltinTypeKind::Bool) {
    return builder_.CreateICmpNE(value, builder_.getInt8(0), "loadedv");
  }
  return value;
}

void CodeGenFunction::EmitStoreOfScalar(llvm::Value* value, Address address, const Type& type) {
  BOOST_ASSERT(value->getType() == std::get<llvm::Type*>(codegen_.ConvertType(type)));
  BOOST_ASSERT(address.element_type == std::get<llvm::Type*>(codegen_.ConvertTypeForMem(type)));
  if (value->getType()->isIntegerTy(1)) {
    value = builder_.CreateZExt(value, address.element_type, "storedv");
  }
  builder_.CreateAlignedStore(value, address.pointer, address.alignment);
}

llvm::BasicBlock* CodeGenFunction::CreateBasicBlock(llvm::StringRef name) {
  // Attach blocks immediately so the module also owns them if emission fails.
  return llvm::BasicBlock::Create(*codegen_.llvm_context_, name, &function_);
}

bool CodeGenFunction::HaveInsertPoint() const { return builder_.GetInsertBlock() != nullptr; }

void CodeGenFunction::EmitBranch(llvm::BasicBlock* target) {
  if (HaveInsertPoint()) {
    BOOST_ASSERT(!builder_.GetInsertBlock()->hasTerminator());
    builder_.CreateBr(target);
  }
  builder_.ClearInsertionPoint();
}

void CodeGenFunction::EmitBlock(llvm::BasicBlock* block, bool is_finished) {
  EmitBranch(block);
  if (is_finished && block->use_empty()) {
    block->eraseFromParent();
    return;
  }
  if (block != &function_.back()) {
    block->moveAfter(&function_.back());
  }
  builder_.SetInsertPoint(block);
}

bool CodeGenFunction::EmitBranchOnBoolExpr(const Expr& expression, llvm::BasicBlock* true_block,
                                           llvm::BasicBlock* false_block) {
  const Expr& condition = *expression.IgnoreParens();
  if (condition.GetKind() == NodeKind::UnaryOperator) {
    const auto& unary = static_cast<const UnaryOperator&>(condition);
    if (unary.op == expr::exclaim) {
      return EmitBranchOnBoolExpr(*unary.Operand, false_block, true_block);
    }
  }
  if (condition.GetKind() == NodeKind::BinaryOperator) {
    const auto& binary = static_cast<const BinaryOperator&>(condition);
    if (binary.op == expr::ampamp || binary.op == expr::pipepipe) {
      const bool is_and = binary.op == expr::ampamp;
      auto* rhs = CreateBasicBlock(is_and ? "land.rhs" : "lor.rhs");
      auto* entry = builder_.GetInsertBlock();
      if (!EmitBranchOnBoolExpr(*binary.LHS, is_and ? rhs : true_block, is_and ? false_block : rhs)) {
        return false;
      }
      EmitBlock(rhs);
      ConditionalEvaluation evaluation(*this, entry, rhs);
      return EmitBranchOnBoolExpr(*binary.RHS, true_block, false_block);
    }
  }
  if (condition.GetKind() == NodeKind::ConditionalOperator) {
    const auto& conditional = static_cast<const ConditionalOperator&>(condition);
    auto* then_block = CreateBasicBlock("cond.true");
    auto* else_block = CreateBasicBlock("cond.false");
    auto* entry = builder_.GetInsertBlock();
    if (!EmitBranchOnBoolExpr(*conditional.Cond, then_block, else_block)) {
      return false;
    }
    EmitBlock(then_block);
    {
      ConditionalEvaluation evaluation(*this, entry, then_block);
      if (!EmitBranchOnBoolExpr(*conditional.Then, true_block, false_block)) {
        return false;
      }
    }
    EmitBlock(else_block);
    ConditionalEvaluation evaluation(*this, entry, else_block);
    return EmitBranchOnBoolExpr(*conditional.Else, true_block, false_block);
  }
  auto* value = EmitScalarExpr(condition);
  if (!value) {
    return false;
  }
  BOOST_ASSERT(value->getType()->isIntegerTy(1));
  builder_.CreateCondBr(value, true_block, false_block);
  builder_.ClearInsertionPoint();
  return true;
}

void CodeGenFunction::AddTemporaryCleanup(Address address, const Type& type) {
  if (type.GetTriviality() != TypeTriviality::NonTrivial) {
    return;
  }
  Cleanup cleanup{address, &type, {}};
  if (conditional_condition_) {
    if (conditional_inverted_) {
      llvm::IRBuilder<> before_branch(conditional_entry_->getTerminator());
      conditional_condition_ = before_branch.CreateNot(conditional_condition_, "cleanup.condition");
      conditional_inverted_ = false;
    }
    cleanup.condition = conditional_condition_;
  } else if (conditional_entry_) {
    Address flag = CreateStorage(builder_.getInt1Ty(), "cleanup.active");
    llvm::IRBuilder<> reset(conditional_entry_->getTerminator());
    reset.CreateAlignedStore(builder_.getFalse(), flag.pointer, flag.alignment);
    builder_.CreateAlignedStore(builder_.getTrue(), flag.pointer, flag.alignment);
    cleanup.condition = flag;
  }
  temporary_cleanups_.push_back(cleanup);
}

bool CodeGenFunction::EmitCleanup(const Cleanup& cleanup) {
  llvm::Value* condition = nullptr;
  if (const auto* value = std::get_if<llvm::Value*>(&cleanup.condition)) {
    condition = *value;
  } else if (const auto* flag = std::get_if<Address>(&cleanup.condition)) {
    condition = builder_.CreateAlignedLoad(flag->element_type, flag->pointer, flag->alignment, "cleanup.active");
  }
  if (!condition) {
    return EmitDestroy(cleanup.address, *cleanup.type);
  }
  auto* destroy = CreateBasicBlock("cleanup.destroy");
  auto* continuation = CreateBasicBlock("cleanup.end");
  builder_.CreateCondBr(condition, destroy, continuation);
  builder_.ClearInsertionPoint();
  EmitBlock(destroy);
  if (!EmitDestroy(cleanup.address, *cleanup.type)) {
    return false;
  }
  EmitBlock(continuation);
  return true;
}

bool CodeGenFunction::EmitTemporaryCleanups(std::size_t depth) {
  for (std::size_t index = temporary_cleanups_.size(); index > depth; --index) {
    if (!EmitCleanup(temporary_cleanups_[index - 1])) {
      return false;
    }
  }
  temporary_cleanups_.resize(depth);
  return true;
}

bool CodeGenFunction::EmitLocalCleanups(std::size_t depth) {
  if (!HaveInsertPoint()) {
    return true;
  }
  // Emitting an exit must not consume the state needed to emit another reachable path.
  for (std::size_t index = local_cleanups_.size(); index > depth; --index) {
    const auto& cleanup = local_cleanups_[index - 1];
    if (!cleanup.active) {
      continue;
    }
    if (cleanup.kind == LocalCleanup::Kind::ExitVirtualDispatch) {
      EmitVTablePointer(cleanup.address, *cleanup.type->AsStructType()->GetDeclaration());
    } else if (!EmitDestroy(cleanup.address, *cleanup.type)) {
      return false;
    }
  }
  return true;
}

bool CodeGenFunction::EmitFullExpr(const Expr& expression) {
  const auto depth = temporary_cleanups_.size();
  return EmitIgnoredExpr(expression) && EmitTemporaryCleanups(depth);
}

bool CodeGenFunction::EmitCondition(const Expr& expression, llvm::BasicBlock* true_block,
                                    llvm::BasicBlock* false_block) {
  const auto depth = temporary_cleanups_.size();
  auto* true_exit = CreateBasicBlock("cond.cleanup.true");
  auto* false_exit = CreateBasicBlock("cond.cleanup.false");
  if (!EmitBranchOnBoolExpr(expression, true_exit, false_exit)) {
    return false;
  }
  if (temporary_cleanups_.size() == depth) {
    // Preserve direct branching when the condition creates no objects needing cleanup.
    true_exit->replaceAllUsesWith(true_block);
    false_exit->replaceAllUsesWith(false_block);
    true_exit->eraseFromParent();
    false_exit->eraseFromParent();
    return true;
  }
  auto* cleanup = CreateBasicBlock("cond.cleanup");
  EmitBlock(true_exit);
  EmitBranch(cleanup);
  EmitBlock(false_exit);
  EmitBlock(cleanup);
  auto* value = builder_.CreatePHI(builder_.getInt1Ty(), 2, "condition");
  value->addIncoming(builder_.getTrue(), true_exit);
  value->addIncoming(builder_.getFalse(), false_exit);
  if (!EmitTemporaryCleanups(depth)) {
    return false;
  }
  builder_.CreateCondBr(value, true_block, false_block);
  builder_.ClearInsertionPoint();
  return true;
}

bool CodeGenFunction::EmitArrayLoop(std::uint64_t count, bool reverse, llvm::StringRef name,
                                    llvm::function_ref<bool(llvm::Value*)> emit_element) {
  if (count == 0) {
    return true;
  }
  auto* predecessor = builder_.GetInsertBlock();
  auto* body = CreateBasicBlock(name);
  auto* end = CreateBasicBlock("array.end");
  EmitBlock(body);
  auto* cursor = builder_.CreatePHI(builder_.getInt64Ty(), 2, "array.index");
  cursor->addIncoming(builder_.getInt64(reverse ? count : 0), predecessor);
  auto* index = reverse ? builder_.CreateSub(cursor, builder_.getInt64(1), "array.previous") : cursor;
  if (!emit_element(index)) {
    return false;
  }
  auto* next = reverse ? index : builder_.CreateAdd(index, builder_.getInt64(1), "array.next");
  cursor->addIncoming(next, builder_.GetInsertBlock());
  auto* finished = builder_.CreateICmpEQ(next, builder_.getInt64(reverse ? 0 : count), "array.finished");
  builder_.CreateCondBr(finished, end, body);
  builder_.ClearInsertionPoint();
  EmitBlock(end);
  return true;
}

bool CodeGenFunction::EmitDestroy(Address address, const Type& type) {
  if (type.GetTriviality() != TypeTriviality::NonTrivial) {
    return true;
  }
  if (const auto* array = type.AsArrayType()) {
    if (!HasArrayElements(*array)) {
      return true;
    }
    return EmitArrayLoop(array->GetLength(), true, "array.destroy", [&](llvm::Value* index) {
      return EmitDestroy(EmitArrayElement(address, index, /*in_bounds=*/true), *array->GetElementType().GetTypePtr());
    });
  }
  const auto* structure = type.AsStructType();
  BOOST_ASSERT(structure);
  return EmitStructorCall(*codegen_.destructors_.at(structure->GetDeclaration()), address, {});
}

void CodeGenFunction::EmitVTablePointer(Address object, const StructDecl& stage) {
  if (stage.IsPolymorphic()) {
    builder_.CreateAlignedStore(codegen_.GetVTableAddressPoint(stage), object.pointer, object.alignment);
  }
}

llvm::Value* CodeGenFunction::EmitVirtualPointerIsNotNull(llvm::Value* pointer) {
  auto* offset = builder_.CreateExtractValue(pointer, 0, "slot.offset");
  auto* adjustment = builder_.CreateExtractValue(pointer, 1, "slot.adjustment");
  auto* has_offset = builder_.CreateICmpNE(offset, builder_.getInt64(0));
  auto* virtual_bit = builder_.CreateAnd(adjustment, builder_.getInt64(1));
  auto* is_virtual = builder_.CreateICmpNE(virtual_bit, builder_.getInt64(0));
  return builder_.CreateOr(has_offset, is_virtual, "slot.nonnull");
}

llvm::Value* CodeGenFunction::EmitVirtualCallee(const VirtualFunctionDecl& declaration, llvm::Value* receiver) {
  const auto* receiver_type = declaration.ParmVars.front()->type.GetTypePtr()->AsReferenceType();
  const auto& structure = *receiver_type->GetReferentType()->AsStructType()->GetDeclaration();
  const auto index = codegen_.ast_context_->GetVTableLayout(structure).function_indices.at(&declaration);
  auto* table = builder_.CreateAlignedLoad(builder_.getPtrTy(), receiver, llvm::Align(8), "vtable");
  auto* slot = builder_.CreateConstInBoundsGEP1_64(builder_.getPtrTy(), table, index, "virtual.slot");
  return builder_.CreateAlignedLoad(builder_.getPtrTy(), slot, llvm::Align(8), "virtual.callee");
}

llvm::Value* CodeGenFunction::EmitVirtualCallee(llvm::Value* pointer, llvm::Value*& receiver) {
  // CW values select virtual slots only; ordinary member-function addresses are not in this type's value domain.
  auto* adjustment =
      builder_.CreateAShr(builder_.CreateExtractValue(pointer, 1), builder_.getInt64(1), "this.adjustment");
  receiver = builder_.CreateGEP(builder_.getInt8Ty(), receiver, adjustment, "virtual.this");
  auto* table = builder_.CreateAlignedLoad(builder_.getPtrTy(), receiver, llvm::Align(8), "vtable");
  // Apple arm64 consumes only the low 32 bits of the unsigned virtual slot offset.
  auto* offset =
      builder_.CreateZExt(builder_.CreateTrunc(builder_.CreateExtractValue(pointer, 0), builder_.getInt32Ty()),
                          builder_.getInt64Ty(), "slot.offset");
  auto* slot = builder_.CreateGEP(builder_.getInt8Ty(), table, offset, "virtual.slot");
  return builder_.CreateAlignedLoad(builder_.getPtrTy(), slot, llvm::Align(8), "virtual.callee");
}

void CodeGenFunction::GenerateThunk(const VTableEntry& entry, const CodeGen::FunctionInfo& info,
                                    llvm::Function& implementation) {
  StartFunction();
  // Overrides preserve parameters. Forward the ABI values and result slot directly;
  // a thunk must not introduce parameter objects or their cleanup.
  BOOST_ASSERT(function_.getFunctionType() == implementation.getFunctionType());
  std::vector<llvm::Value*> arguments;
  for (auto& argument : function_.args()) {
    arguments.push_back(&argument);
  }
  auto* call = builder_.CreateCall(implementation.getFunctionType(), &implementation, arguments);
  NameCallResult(*call);
  call->setAttributes(implementation.getAttributes());
  llvm::Value* result = call;
  if (entry.return_adjustment != 0) {
    auto* adjusted =
        builder_.CreateGEP(builder_.getInt8Ty(), result, builder_.getInt64(entry.return_adjustment), "return.adjusted",
                           llvm::GEPNoWrapFlags::inBounds() | llvm::GEPNoWrapFlags::noUnsignedWrap());
    const auto* return_type = entry.interface->type.GetTypePtr()->AsFunctionType()->GetReturnType();
    result = return_type->AsPointerType() ? builder_.CreateSelect(builder_.CreateIsNull(result),
                                                                  llvm::ConstantPointerNull::get(builder_.getPtrTy()),
                                                                  adjusted, "return.nullable")
                                          : adjusted;
  }
  EmitReturnBlock();
  if (info.type->getReturnType()->isVoidTy()) {
    builder_.CreateRetVoid();
  } else {
    builder_.CreateRet(result);
  }
  builder_.ClearInsertionPoint();
}

void CodeGenFunction::EnterDestructorCleanups(const DestructorDecl& declaration) {
  const auto& structure = *declaration.target_type->GetDeclaration();
  // These entries enclose the user body, so every return destroys locals before subobjects.
  if (structure.base_type) {
    local_cleanups_.push_back({EmitBase(this_address_, structure), structure.base_type, nullptr, true});
  }
  for (const auto& field : structure.Fields) {
    if (field->type.GetTypePtr()->GetTriviality() == TypeTriviality::NonTrivial) {
      local_cleanups_.push_back({EmitField(this_address_, structure, *field), field->type.GetTypePtr(), nullptr, true});
    }
  }
  if (structure.base_type && structure.base_type->GetDeclaration()->IsPolymorphic()) {
    local_cleanups_.push_back({EmitBase(this_address_, structure), structure.base_type, nullptr, true,
                               LocalCleanup::Kind::ExitVirtualDispatch});
  }
}

void CodeGenFunction::StartFunction() {
  BOOST_ASSERT(function_.empty());
  builder_.SetInsertPoint(llvm::BasicBlock::Create(*codegen_.llvm_context_, "entry", &function_));
  return_block_ = CreateBasicBlock("return");
}

void CodeGenFunction::FinishFunction() {
  EmitReturnBlock();
  if (HaveInsertPoint()) {
    builder_.CreateRetVoid();
    builder_.ClearInsertionPoint();
  }
}

bool CodeGenFunction::Generate(const FunctionDecl& declaration, const CodeGen::FunctionInfo& function_info) {
  StartFunction();
  if (function_info.this_index) {
    auto* target = function_.getArg(*function_info.this_index);
    target->setName("this");
    const StructType* this_type = declaration.GetKind() == NodeKind::ConstructorDecl
                                      ? static_cast<const ConstructorDecl&>(declaration).target_type
                                      : static_cast<const DestructorDecl&>(declaration).target_type;
    this_address_ = MakeAddress(target, function_info.this_type, this_type);
  }
  if (!declaration.type.GetTypePtr()->AsFunctionType()->GetReturnType()->IsVoid()) {
    if (!declaration.ReturnVar) {
      return codegen_.InternalError(declaration, "function has no result declaration");
    }
    const auto& result = *declaration.ReturnVar;
    const llvm::StringRef name = result.name.empty() ? ".result" : llvm::StringRef(result.name);
    if (function_info.result_index) {
      auto* address = function_.getArg(*function_info.result_index);
      address->setName(name);
      locals_.emplace(&result, MakeAddress(address, function_info.result.memory_type, result.type.GetTypePtr(),
                                           Overlap::DoesNotOverlap));
    } else if (!DeclareVariable(result, name)) {
      return false;
    }
  }
  for (std::size_t index = 0; index < declaration.ParmVars.size(); ++index) {
    const auto& parameter = *declaration.ParmVars[index];
    const auto& info = function_info.parameters[index];
    llvm::Argument* argument = info.llvm_index ? function_.getArg(*info.llvm_index) : nullptr;
    if (info.abi.kind == CodeGen::ABIArgInfo::Kind::Indirect) {
      // The caller has already formed this parameter's independent value object.
      argument->setName(parameter.name);
      locals_.emplace(&parameter, MakeAddress(argument, info.abi.memory_type, parameter.type.GetTypePtr(),
                                              Overlap::DoesNotOverlap));
      continue;
    }
    const bool aggregate = IsAggregate(*parameter.type.GetTypePtr());
    const bool coerced = argument && aggregate && info.abi.direct_type != info.abi.memory_type;
    Address storage = DeclareVariable(parameter, argument && !coerced ? parameter.name + ".addr" : parameter.name);
    if (!storage) {
      return false;
    }
    if (argument) {
      argument->setName(coerced ? parameter.name + ".coerce" : parameter.name);
      if (aggregate) {
        EmitCoercedStore(argument, storage);
      } else {
        EmitStoreOfScalar(argument, storage, *parameter.type.GetTypePtr());
      }
    }
  }
  if (declaration.GetKind() == NodeKind::DestructorDecl) {
    EmitVTablePointer(this_address_, *static_cast<const DestructorDecl&>(declaration).target_type->GetDeclaration());
    EnterDestructorCleanups(static_cast<const DestructorDecl&>(declaration));
  }
  if (!EmitCompound(*declaration.Body) || !EmitLocalCleanups(0)) {
    return false;
  }
  return EmitFunctionReturn(declaration, function_info);
}

bool CodeGenFunction::GenerateGlobalVarInit(const VarGroupDecl& declaration) {
  StartFunction();
  if (!EmitVarGroup(declaration)) {
    return false;
  }
  FinishFunction();
  return true;
}

void CodeGenFunction::GenerateGlobalInit(llvm::ArrayRef<llvm::Function*> initializers) {
  StartFunction();
  for (auto* initializer : initializers) {
    builder_.CreateCall(initializer);
  }
  FinishFunction();
}

bool CodeGenFunction::GenerateGlobalDestructor(const VarDecl& declaration) {
  StartFunction();
  auto* object = function_.getArg(0);
  object->setName("object");
  auto* type = codegen_.globals_.at(&declaration)->getValueType();
  if (!EmitDestroy(MakeAddress(object, type, declaration.type.GetTypePtr(), Overlap::DoesNotOverlap),
                   *declaration.type.GetTypePtr())) {
    return false;
  }
  FinishFunction();
  return true;
}

bool CodeGenFunction::RegisterGlobalDestructor(const VarDecl& declaration) {
  if (!CodeGen::NeedsGlobalDestruction(*declaration.type.GetTypePtr())) {
    return true;
  }
  auto* destructor = codegen_.GetGlobalDestructor(declaration);
  if (!destructor) {
    return false;
  }
  auto* call =
      builder_.CreateCall(codegen_.cxa_atexit_, {destructor, codegen_.globals_.at(&declaration), codegen_.dso_handle_});
  call->setDoesNotThrow();
  return true;
}

bool CodeGenFunction::EmitCompound(const CompoundStmt& statement) {
  const auto depth = local_cleanups_.size();
  for (const auto& child : statement.Stmts) {
    if (!HaveInsertPoint()) {
      break;
    }
    if (!EmitStmt(*child)) {
      return false;
    }
  }
  if (HaveInsertPoint()) {
    for (const auto& tail : statement.TailExprs) {
      if (!EmitFullExpr(*tail)) {
        return false;
      }
    }
  }
  if (!EmitLocalCleanups(depth)) {
    return false;
  }
  local_cleanups_.resize(depth);
  return true;
}

bool CodeGenFunction::EmitStmt(const Stmt& statement) {
  switch (statement.GetKind()) {
    case NodeKind::CompoundStmt:
      return EmitCompound(static_cast<const CompoundStmt&>(statement));
    case NodeKind::ExprStmt: {
      const auto& expression = static_cast<const ExprStmt&>(statement).Expr;
      return !expression || EmitFullExpr(*expression);
    }
    case NodeKind::ImplicitThisInitializationCompleteStmt:
      EmitVTablePointer(this_address_, *this_address_.semantic_type->AsStructType()->GetDeclaration());
      return true;
    case NodeKind::DeclStmt: {
      const auto& declaration = static_cast<const DeclStmt&>(statement).Decl;
      if (declaration && declaration->GetKind() == NodeKind::VarGroupDecl) {
        return EmitVarGroup(static_cast<const VarGroupDecl&>(*declaration));
      }
      return codegen_.Unsupported(statement, "this local declaration");
    }
    case NodeKind::ReturnStmt: {
      const auto& expression = static_cast<const ReturnStmt&>(statement).Expr;
      if ((expression && !EmitFullExpr(*expression)) || !EmitLocalCleanups(0)) {
        return false;
      }
      EmitBranch(return_block_);
      return true;
    }
    case NodeKind::IfStmt:
      return EmitIfStmt(static_cast<const IfStmt&>(statement));
    case NodeKind::WhileStmt:
      return EmitWhileStmt(static_cast<const WhileStmt&>(statement));
    case NodeKind::BreakStmt:
      BOOST_ASSERT(!break_continue_stack_.empty());
      if (!EmitLocalCleanups(break_continue_stack_.back().cleanup_depth)) {
        return false;
      }
      EmitBranch(break_continue_stack_.back().break_block);
      return true;
    case NodeKind::ContinueStmt:
      BOOST_ASSERT(!break_continue_stack_.empty());
      if (!EmitLocalCleanups(break_continue_stack_.back().cleanup_depth)) {
        return false;
      }
      EmitBranch(break_continue_stack_.back().continue_block);
      return true;
    default:
      return codegen_.Unsupported(statement, "this statement");
  }
}

bool CodeGenFunction::EmitIfStmt(const IfStmt& statement) {
  auto* then_block = CreateBasicBlock("if.then");
  auto* continuation = CreateBasicBlock("if.end");
  auto* else_block = statement.Else ? CreateBasicBlock("if.else") : continuation;
  if (!EmitCondition(*statement.Cond, then_block, else_block)) {
    return false;
  }
  const auto before = local_cleanups_;
  EmitBlock(then_block);
  if (!EmitCompound(*statement.Then)) {
    return false;
  }
  const bool then_reachable = HaveInsertPoint();
  const auto after_then = local_cleanups_;
  EmitBranch(continuation);
  local_cleanups_ = before;
  if (statement.Else) {
    EmitBlock(else_block);
    if (!EmitCompound(*statement.Else)) {
      return false;
    }
    if (then_reachable && HaveInsertPoint()) {
      for (std::size_t index = 0; index < local_cleanups_.size(); ++index) {
        BOOST_ASSERT(local_cleanups_[index].active == after_then[index].active);
      }
    }
    EmitBranch(continuation);
  }
  if (then_reachable) {
    local_cleanups_ = after_then;
  }
  // A completed if with no incoming edge has no fallthrough path.
  EmitBlock(continuation, true);
  return true;
}

bool CodeGenFunction::EmitWhileStmt(const WhileStmt& statement) {
  auto* condition = CreateBasicBlock("while.cond");
  auto* body = CreateBasicBlock("while.body");
  auto* exit = CreateBasicBlock("while.end");
  EmitBlock(condition);
  if (!EmitCondition(*statement.Cond, body, exit)) {
    return false;
  }
  const auto before = local_cleanups_;
  EmitBlock(body);
  break_continue_stack_.push_back({exit, condition, local_cleanups_.size()});
  const bool emitted = EmitCompound(*statement.Body);
  break_continue_stack_.pop_back();
  if (!emitted) {
    return false;
  }
  EmitBranch(condition);
  local_cleanups_ = before;
  EmitBlock(exit, true);
  return true;
}

bool CodeGenFunction::EmitVarGroup(const VarGroupDecl& declaration) {
  for (const auto& variable : declaration.Vars) {
    if (codegen_.globals_.count(variable.get())) {
      continue;
    }
    Address storage = DeclareVariable(*variable);
    if (!storage) {
      return false;
    }
    if (variable->type.GetTypePtr()->GetTriviality() == TypeTriviality::NonTrivial) {
      local_cleanups_.push_back({storage, variable->type.GetTypePtr(), variable.get(), false});
    }
  }
  if (declaration.Body) {
    return EmitCompound(*declaration.Body);
  }
  for (std::size_t index = 0; index < declaration.InitExprs.size(); ++index) {
    const auto depth = temporary_cleanups_.size();
    if (!EmitInitialization(*declaration.Vars[index], *declaration.InitExprs[index]) || !EmitTemporaryCleanups(depth)) {
      return false;
    }
  }
  return true;
}

bool CodeGenFunction::EmitInitialization(const VarDecl& target, const Expr& source) {
  if (!EmitInitialization(GetStorage(target), *target.type.GetTypePtr(), source)) {
    return false;
  }
  // The target's storage duration determines who owns cleanup, even inside an initializer block.
  if (codegen_.globals_.count(&target)) {
    return RegisterGlobalDestructor(target);
  }
  for (auto& cleanup : local_cleanups_) {
    if (cleanup.declaration == &target) {
      cleanup.active = true;
      break;
    }
  }
  return true;
}

bool CodeGenFunction::EmitInitialization(Address target, const Type& type, const Expr& source) {
  if (!target) {
    return false;
  }
  if (IsAggregate(type)) {
    return EmitAggExpr(source, target);
  }
  // A reference's own slot holds its binding. Initializing it must not try to load that binding.
  llvm::Value* value = nullptr;
  if (type.AsReferenceType()) {
    value = EmitLValue(source).pointer;
  } else {
    value = EmitScalarExpr(source);
  }
  if (!value) {
    return false;
  }
  EmitStoreOfScalar(value, target, type);
  return true;
}

void CodeGenFunction::EmitReturnBlock() {
  // Fold simple exits without changing the shared result object's initialization points.
  auto* current = builder_.GetInsertBlock();
  if (current && (current->empty() || return_block_->use_empty())) {
    return_block_->replaceAllUsesWith(current);
    return_block_->eraseFromParent();
  } else if (!current && return_block_->hasOneUse()) {
    auto* branch = llvm::cast<llvm::UncondBrInst>(*return_block_->user_begin());
    auto* predecessor = branch->getParent();
    branch->eraseFromParent();
    return_block_->eraseFromParent();
    builder_.SetInsertPoint(predecessor);
  } else {
    EmitBlock(return_block_, true);
  }
  return_block_ = nullptr;
}

bool CodeGenFunction::EmitFunctionReturn(const FunctionDecl& declaration, const CodeGen::FunctionInfo& function_info) {
  EmitReturnBlock();
  if (!HaveInsertPoint()) {
    return true;
  }
  if (function_info.this_index) {
    builder_.CreateRet(this_address_.pointer);
    builder_.ClearInsertionPoint();
    return true;
  }
  if (function_info.result.kind != CodeGen::ABIArgInfo::Kind::Direct) {
    builder_.CreateRetVoid();
    builder_.ClearInsertionPoint();
    return true;
  }
  Address storage = GetStorage(*declaration.ReturnVar);
  if (!storage) {
    return false;
  }
  // Reference results load the binding pointer; value results load the result object.
  const auto& type = *declaration.ReturnVar->type.GetTypePtr();
  auto* value =
      IsAggregate(type) ? EmitCoercedLoad(storage, function_info.result.direct_type) : EmitLoadOfScalar(storage, type);
  builder_.CreateRet(value);
  builder_.ClearInsertionPoint();
  return true;
}

bool CodeGenFunction::EmitIgnoredExpr(const Expr& expression) {
  if (expression.value_category == ValueCategory::PureRValue &&
      expression.type.GetTypePtr()->GetTriviality() == TypeTriviality::NonTrivial) {
    auto conversion = codegen_.ConvertTypeForMem(*expression.type.GetTypePtr());
    if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&conversion)) {
      return codegen_.DiagnoseTypeConversionFailure(expression, *failure, "this discarded object type");
    }
    Address storage = CreateStorage(std::get<llvm::Type*>(conversion), "temporary", expression.type.GetTypePtr());
    if (!EmitAggExpr(expression, storage)) {
      return false;
    }
    AddTemporaryCleanup(storage, *expression.type.GetTypePtr());
    return true;
  }
  switch (expression.GetKind()) {
    case NodeKind::DestructorCallExpr: {
      const auto& call = static_cast<const DestructorCallExpr&>(expression);
      const auto* callee = static_cast<const DeclRefExpr*>(call.Callee->IgnoreParens());
      const auto& destructor = static_cast<const DestructorDecl&>(*callee->declaration);
      auto* pointer = EmitScalarExpr(*call.TargetAddress);
      if (!pointer) {
        return false;
      }
      const auto& info = *std::get<const CodeGen::FunctionInfo*>(codegen_.GetFunctionInfo(destructor));
      return EmitStructorCall(destructor, MakeAddress(pointer, info.this_type, destructor.target_type), {});
    }
    case NodeKind::CallExpr:
    case NodeKind::OperatorCallExpr:
    case NodeKind::ReceiverCallExpr:
      return EmitCall(static_cast<const CallExpr&>(expression), {{}, true}).has_value();
    case NodeKind::NullLiteral:
      return true;
    case NodeKind::ImplicitResultInitializationExpr: {
      const auto& initialization = static_cast<const ImplicitResultInitializationExpr&>(expression);
      return EmitInitialization(*initialization.Target, *initialization.Source);
    }
    case NodeKind::InitializationExpr: {
      const auto& initialization = static_cast<const InitializationExpr&>(expression);
      const Expr* target = initialization.Target->IgnoreParens();
      if (target->GetKind() == NodeKind::MemberExpr || target->GetKind() == NodeKind::BaseSubobjectExpr ||
          target->GetKind() == NodeKind::ThisExpr) {
        return EmitInitialization(EmitLValue(*target), *target->type.GetTypePtr(), *initialization.Source);
      }
      if (target->GetKind() != NodeKind::DeclRefExpr) {
        return codegen_.Unsupported(expression, "this initialization target");
      }
      const auto* declaration = static_cast<const DeclRefExpr&>(*target).declaration;
      switch (declaration->GetKind()) {
        case NodeKind::VarDecl:
        case NodeKind::ParmVarDecl:
        case NodeKind::ReturnVarDecl:
          return EmitInitialization(static_cast<const VarDecl&>(*declaration), *initialization.Source);
        default:
          return codegen_.Unsupported(expression, "this initialization target");
      }
    }
    case NodeKind::ParenExpr:
      return EmitIgnoredExpr(*static_cast<const ParenExpr&>(expression).SubExpr);
    case NodeKind::ConstructionExpr: {
      const auto& construction = static_cast<const ConstructionExpr&>(expression);
      if (construction.TargetAddress) {
        return EmitScalarExpr(expression) != nullptr;
      }
      auto result = codegen_.ConvertTypeForMem(*expression.type.GetTypePtr());
      if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&result)) {
        return codegen_.DiagnoseTypeConversionFailure(expression, *failure, "this construction type");
      }
      BOOST_ASSERT(construction.Args.empty());
      return true;
    }
    case NodeKind::ArrayValueExpr: {
      auto result = codegen_.ConvertTypeForMem(*expression.type.GetTypePtr());
      if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&result)) {
        return codegen_.DiagnoseTypeConversionFailure(expression, *failure, "this array type");
      }
      // A discarded trivial value has no observable storage, but its elements still execute in order.
      for (const auto& element : static_cast<const ArrayValueExpr&>(expression).Elements) {
        if (!EmitIgnoredExpr(*element)) {
          return false;
        }
      }
      return true;
    }
    case NodeKind::ImplicitCastExpr:
      if (IsAggregate(*expression.type.GetTypePtr())) {
        const auto& cast = static_cast<const ImplicitCastExpr&>(expression);
        if (cast.conversion_kind == ImplicitConversionKind::LValueToRValue) {
          return static_cast<bool>(EmitLValue(*cast.SubExpr));
        }
        if (cast.conversion_kind == ImplicitConversionKind::NoOp ||
            cast.conversion_kind == ImplicitConversionKind::Identity) {
          return EmitIgnoredExpr(*cast.SubExpr);
        }
      }
      break;
    case NodeKind::ConditionalOperator:
      if (expression.type.GetTypePtr()->IsVoid() || IsAggregate(*expression.type.GetTypePtr())) {
        return EmitIgnoredConditionalExpr(static_cast<const ConditionalOperator&>(expression));
      }
      break;
    default:
      break;
  }
  if (expression.value_category == ValueCategory::LValue || expression.value_category == ValueCategory::MoveLValue) {
    return static_cast<bool>(EmitLValue(expression));
  }
  return EmitScalarExpr(expression) != nullptr;
}

bool CodeGenFunction::EmitIgnoredConditionalExpr(const ConditionalOperator& expression) {
  auto* entry = builder_.GetInsertBlock();
  auto* then_block = CreateBasicBlock("cond.true");
  auto* else_block = CreateBasicBlock("cond.false");
  auto* continuation = CreateBasicBlock("cond.end");
  if (!EmitBranchOnBoolExpr(*expression.Cond, then_block, else_block)) {
    return false;
  }
  EmitBlock(then_block);
  {
    ConditionalEvaluation evaluation(*this, entry, then_block);
    if (!EmitIgnoredExpr(*expression.Then)) {
      return false;
    }
  }
  EmitBranch(continuation);
  EmitBlock(else_block);
  {
    ConditionalEvaluation evaluation(*this, entry, else_block);
    if (!EmitIgnoredExpr(*expression.Else)) {
      return false;
    }
  }
  EmitBlock(continuation);
  return true;
}

Address CodeGenFunction::EmitLValue(const Expr& expression) {
  switch (expression.GetKind()) {
    case NodeKind::ThisExpr:
      BOOST_ASSERT(this_address_);
      return this_address_;
    case NodeKind::StringLiteral: {
      auto* global = codegen_.GetAddrOfStringLiteral(static_cast<const StringLiteral&>(expression));
      return MakeAddress(global, global->getValueType(), expression.type.GetTypePtr(), Overlap::DoesNotOverlap);
    }
    case NodeKind::DeclRefExpr: {
      const auto* declaration = static_cast<const DeclRefExpr&>(expression).declaration;
      if (declaration->GetKind() != NodeKind::VarDecl && declaration->GetKind() != NodeKind::ParmVarDecl &&
          declaration->GetKind() != NodeKind::ReturnVarDecl) {
        break;
      }
      Address storage = GetStorage(static_cast<const VarDecl&>(*declaration));
      if (!storage) {
        return {};
      }
      if (const auto* reference = declaration->type.GetTypePtr()->AsReferenceType()) {
        auto* pointer = EmitLoadOfScalar(storage, *declaration->type.GetTypePtr());
        auto result = codegen_.ConvertTypeForMem(*reference->GetReferentType());
        if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&result)) {
          codegen_.DiagnoseTypeConversionFailure(expression, *failure, "this reference type");
          return {};
        }
        return MakeAddress(pointer, std::get<llvm::Type*>(result), expression.type.GetTypePtr());
      }
      return storage;
    }
    case NodeKind::ParenExpr:
      return EmitLValue(*static_cast<const ParenExpr&>(expression).SubExpr);
    case NodeKind::MemberExpr:
      return EmitMemberExpr(static_cast<const MemberExpr&>(expression));
    case NodeKind::BaseSubobjectExpr: {
      const auto& base = static_cast<const BaseSubobjectExpr&>(expression);
      return EmitBaseSubobject(*base.Base, base.base_path, base.op == expr::arrow);
    }
    case NodeKind::ImplicitCastExpr: {
      const auto& cast = static_cast<const ImplicitCastExpr&>(expression);
      if (cast.conversion_kind == ImplicitConversionKind::BaseSubobject) {
        return EmitBaseSubobject(*cast.SubExpr, cast.base_path, /*through_pointer=*/false);
      }
      if (cast.conversion_kind == ImplicitConversionKind::NoOp ||
          cast.conversion_kind == ImplicitConversionKind::Identity) {
        return EmitLValue(*cast.SubExpr);
      }
      break;
    }
    case NodeKind::UnaryOperator: {
      const auto& unary = static_cast<const UnaryOperator&>(expression);
      if (unary.op == expr::move_) {
        return EmitLValue(*unary.Operand);
      }
      if (unary.op == expr::star) {
        auto* pointer = EmitScalarExpr(*unary.Operand);
        if (!pointer) {
          return {};
        }
        auto result = codegen_.ConvertTypeForMem(*expression.type.GetTypePtr());
        if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&result)) {
          codegen_.DiagnoseTypeConversionFailure(expression, *failure, "this dereference type");
          return {};
        }
        // Dereferencing locates the object. Only an enclosing value conversion reads it.
        return MakeAddress(pointer, std::get<llvm::Type*>(result), expression.type.GetTypePtr());
      }
      break;
    }
    case NodeKind::MaterializeTemporaryExpr: {
      const auto& temporary = static_cast<const MaterializeTemporaryExpr&>(expression);
      const Type& type = *expression.type.GetTypePtr();
      auto result = codegen_.ConvertTypeForMem(type);
      if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&result)) {
        codegen_.DiagnoseTypeConversionFailure(expression, *failure, "this temporary type");
        return {};
      }
      auto* memory_type = std::get<llvm::Type*>(result);
      if (IsAggregate(type)) {
        Address storage = CreateStorage(memory_type, "temporary", &type);
        if (!EmitAggExpr(*temporary.SubExpr, storage)) {
          return {};
        }
        AddTemporaryCleanup(storage, type);
        return storage;
      }
      auto* value = EmitScalarExpr(*temporary.SubExpr);
      if (!value) {
        return {};
      }
      Address storage = CreateStorage(memory_type, "temporary", &type);
      EmitStoreOfScalar(value, storage, type);
      return storage;
    }
    case NodeKind::BinaryOperator: {
      const auto& assignment = static_cast<const BinaryOperator&>(expression);
      if (!assignment.IsSimpleAssignment()) {
        break;
      }
      if (IsAggregate(*assignment.type.GetTypePtr())) {
        // Capture the source object, then locate the target; copy only after both have been evaluated.
        Address source = EmitLValue(*assignment.RHS);
        if (!source) {
          return {};
        }
        Address target = EmitLValue(*assignment.LHS);
        if (!target) {
          return {};
        }
        EmitAggregateCopy(target, source);
        return target;
      }
      // Capture the value before locating a possibly effectful target, then reuse that location.
      auto* value = EmitScalarExpr(*assignment.RHS);
      if (!value) {
        return {};
      }
      Address target = EmitLValue(*assignment.LHS);
      if (!target) {
        return {};
      }
      EmitStoreOfScalar(value, target, *assignment.LHS->type.GetTypePtr());
      return target;
    }
    case NodeKind::ArrayAssignmentExpr: {
      const auto& assignment = static_cast<const ArrayAssignmentExpr&>(expression);
      Address source = EmitLValue(*assignment.RHS);
      if (!source) {
        return {};
      }
      Address target = EmitLValue(*assignment.LHS);
      if (!target) {
        return {};
      }
      const auto& type = *assignment.type.GetTypePtr()->AsArrayType();
      return EmitArrayAssignment(target, source, type, *assignment.element_assignment) ? target : Address{};
    }
    case NodeKind::CallExpr:
    case NodeKind::OperatorCallExpr:
    case NodeKind::ReceiverCallExpr: {
      auto value = EmitCall(static_cast<const CallExpr&>(expression));
      if (!value) {
        return {};
      }
      auto result = codegen_.ConvertTypeForMem(*expression.type.GetTypePtr());
      if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&result)) {
        codegen_.DiagnoseTypeConversionFailure(expression, *failure, "this call result type");
        return {};
      }
      return MakeAddress(std::get<llvm::Value*>(*value), std::get<llvm::Type*>(result), expression.type.GetTypePtr());
    }
    case NodeKind::SubscriptExpr: {
      const auto& subscript = static_cast<const SubscriptExpr&>(expression);
      Address base = EmitLValue(*subscript.Base);
      if (!base) {
        return {};
      }
      auto* index = EmitScalarExpr(*subscript.Index);
      return index ? EmitArrayElement(base, index) : Address{};
    }
    case NodeKind::ConditionalOperator:
      return EmitConditionalLValue(static_cast<const ConditionalOperator&>(expression));
    default:
      break;
  }
  codegen_.Unsupported(expression, "this object expression");
  return {};
}

Address CodeGenFunction::EmitBaseSubobject(const Expr& source, const std::vector<const StructDecl*>& path,
                                           bool through_pointer) {
  const Type* type = source.type.GetTypePtr();
  if (through_pointer) {
    type = type->AsPointerType()->GetPointee().GetTypePtr();
  }
  const auto* declaration = type->AsStructType()->GetDeclaration();
  auto conversion = codegen_.ConvertStructType(*declaration);
  if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&conversion)) {
    codegen_.DiagnoseTypeConversionFailure(source, *failure, "this base subobject type");
    return {};
  }
  Address address = through_pointer ? MakeAddress(EmitScalarExpr(source), std::get<llvm::Type*>(conversion), type)
                                    : EmitLValue(source);
  if (!address) {
    return {};
  }
  auto* original = address.pointer;
  std::uint64_t offset = 0;
  BOOST_ASSERT(!path.empty());
  for (const auto* base : path) {
    BOOST_ASSERT(declaration->base_type && declaration->base_type->GetDeclaration() == base);
    const auto& shared = *std::get<const StructLayout*>(codegen_.ast_context_->GetStructLayout(*declaration));
    offset += *shared.base_offset;
    address = EmitBase(address, *declaration);
    declaration = base;
  }
  // Pointer conversions preserve null; zero-offset base paths need no runtime check.
  if (through_pointer && offset != 0) {
    auto* null = llvm::ConstantPointerNull::get(llvm::cast<llvm::PointerType>(original->getType()));
    address.pointer = builder_.CreateSelect(builder_.CreateICmpEQ(original, null), null, address.pointer, "base.null");
  }
  return address;
}

Address CodeGenFunction::EmitMemberExpr(const MemberExpr& expression) {
  const Type* base_type = expression.Base->type.GetTypePtr();
  if (expression.op == expr::arrow) {
    base_type = base_type->AsPointerType()->GetPointee().GetTypePtr();
  }
  const auto* declaration = base_type->AsStructType()->GetDeclaration();
  auto conversion = codegen_.ConvertStructType(*declaration);
  if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&conversion)) {
    codegen_.DiagnoseTypeConversionFailure(expression, *failure, "this member access type");
    return {};
  }
  Address base = expression.op == expr::arrow
                     ? MakeAddress(EmitScalarExpr(*expression.Base), std::get<llvm::Type*>(conversion), base_type)
                     : EmitLValue(*expression.Base);
  if (!base) {
    return {};
  }
  return EmitField(base, *declaration, *expression.declaration);
}

Address CodeGenFunction::EmitConditionalLValue(const ConditionalOperator& expression) {
  auto* entry = builder_.GetInsertBlock();
  auto* then_block = CreateBasicBlock("cond.true");
  auto* else_block = CreateBasicBlock("cond.false");
  auto* continuation = CreateBasicBlock("cond.end");
  if (!EmitBranchOnBoolExpr(*expression.Cond, then_block, else_block)) {
    return {};
  }
  EmitBlock(then_block);
  Address then_address;
  {
    ConditionalEvaluation evaluation(*this, entry, then_block);
    then_address = EmitLValue(*expression.Then);
  }
  if (!then_address) {
    return {};
  }
  then_block = builder_.GetInsertBlock();
  EmitBranch(continuation);
  EmitBlock(else_block);
  Address else_address;
  {
    ConditionalEvaluation evaluation(*this, entry, else_block);
    else_address = EmitLValue(*expression.Else);
  }
  if (!else_address) {
    return {};
  }
  else_block = builder_.GetInsertBlock();
  EmitBlock(continuation);
  // Preserve the selected object; the enclosing AST decides whether to read or bind it.
  BOOST_ASSERT(then_address.element_type == else_address.element_type);
  auto* pointer = builder_.CreatePHI(then_address.pointer->getType(), 2, "cond");
  pointer->addIncoming(then_address.pointer, then_block);
  pointer->addIncoming(else_address.pointer, else_block);
  const auto overlap =
      then_address.overlap == Overlap::DoesNotOverlap && else_address.overlap == Overlap::DoesNotOverlap
          ? Overlap::DoesNotOverlap
          : Overlap::MayOverlap;
  return {pointer, then_address.element_type, std::min(then_address.alignment, else_address.alignment),
          expression.type.GetTypePtr(), overlap};
}

bool CodeGenFunction::EmitAggExpr(const Expr& expression, Address destination) {
  switch (expression.GetKind()) {
    case NodeKind::CallExpr:
    case NodeKind::OperatorCallExpr:
    case NodeKind::ReceiverCallExpr:
      return EmitCall(static_cast<const CallExpr&>(expression), {destination, false}).has_value();
    case NodeKind::ParenExpr:
      return EmitAggExpr(*static_cast<const ParenExpr&>(expression).SubExpr, destination);
    case NodeKind::ConstructionExpr:
      return EmitConstruction(static_cast<const ConstructionExpr&>(expression), destination);
    case NodeKind::ArrayConstructionExpr: {
      const auto& construction = static_cast<const ArrayConstructionExpr&>(expression);
      Address source = EmitLValue(*construction.Source);
      return source && EmitArrayConstruction(destination, source, *expression.type.GetTypePtr()->AsArrayType(),
                                             *construction.element_constructor);
    }
    case NodeKind::ImplicitCastExpr: {
      const auto& cast = static_cast<const ImplicitCastExpr&>(expression);
      if (cast.conversion_kind == ImplicitConversionKind::LValueToRValue) {
        Address source = EmitLValue(*cast.SubExpr);
        if (!source) {
          return false;
        }
        EmitAggregateCopy(destination, source);
        return true;
      }
      if (cast.conversion_kind == ImplicitConversionKind::NoOp ||
          cast.conversion_kind == ImplicitConversionKind::Identity) {
        return EmitAggExpr(*cast.SubExpr, destination);
      }
      break;
    }
    case NodeKind::ArrayValueExpr: {
      const auto& array = static_cast<const ArrayValueExpr&>(expression);
      for (std::size_t index = 0; index < array.Elements.size(); ++index) {
        const Expr& element = *array.Elements[index];
        Address storage = EmitArrayElement(destination, builder_.getInt64(index), /*in_bounds=*/true);
        if (!EmitInitialization(storage, *element.type.GetTypePtr(), element)) {
          return false;
        }
      }
      return true;
    }
    case NodeKind::ConditionalOperator: {
      const auto& conditional = static_cast<const ConditionalOperator&>(expression);
      auto* entry = builder_.GetInsertBlock();
      auto* then_block = CreateBasicBlock("cond.true");
      auto* else_block = CreateBasicBlock("cond.false");
      auto* continuation = CreateBasicBlock("cond.end");
      if (!EmitBranchOnBoolExpr(*conditional.Cond, then_block, else_block)) {
        return false;
      }
      EmitBlock(then_block);
      {
        ConditionalEvaluation evaluation(*this, entry, then_block);
        if (!EmitAggExpr(*conditional.Then, destination)) {
          return false;
        }
      }
      EmitBranch(continuation);
      EmitBlock(else_block);
      {
        ConditionalEvaluation evaluation(*this, entry, else_block);
        if (!EmitAggExpr(*conditional.Else, destination)) {
          return false;
        }
      }
      EmitBlock(continuation);
      return true;
    }
    default:
      break;
  }
  return codegen_.Unsupported(expression, "this aggregate expression");
}

bool CodeGenFunction::EmitConstruction(const ConstructionExpr& expression, Address destination) {
  // Without virtual bases, structor bodies share one entry and treat this as a
  // possibly overlapping subobject. The enclosing initialization supplies its address.
  if (expression.constructor) {
    std::vector<const Expr*> sources;
    for (const auto& argument : expression.Args) {
      sources.push_back(argument.get());
    }
    return EmitStructorCall(*expression.constructor, destination, sources);
  }
  BOOST_ASSERT(expression.Args.empty());
  const auto size = GetOperationSize(destination);
  // On the supported target, all trivial defaults have an all-zero representation, including pointers.
  if (size != 0) {
    builder_.CreateMemSet(destination.pointer, builder_.getInt8(0), size, destination.alignment);
  }
  return true;
}

bool CodeGenFunction::EmitArrayConstruction(Address destination, Address source, const ArrayType& type,
                                            const ConstructorDecl& constructor) {
  if (!HasArrayElements(type)) {
    return true;
  }
  return EmitArrayLoop(type.GetLength(), false, "array.construct", [&](llvm::Value* index) {
    Address target_element = EmitArrayElement(destination, index, /*in_bounds=*/true);
    Address source_element = EmitArrayElement(source, index, /*in_bounds=*/true);
    const Type& element_type = *type.GetElementType().GetTypePtr();
    if (const auto* array = element_type.AsArrayType()) {
      return EmitArrayConstruction(target_element, source_element, *array, constructor);
    }
    const auto& info = *std::get<const CodeGen::FunctionInfo*>(codegen_.GetFunctionInfo(constructor));
    BOOST_ASSERT(info.parameters.size() == 1);
    std::vector<llvm::Value*> arguments(info.type->getNumParams());
    arguments[*info.this_index] = target_element.pointer;
    arguments[*info.parameters.front().llvm_index] = source_element.pointer;
    auto* call = builder_.CreateCall(info.type, codegen_.functions_.at(&constructor), arguments);
    NameCallResult(*call);
    call->setAttributes(info.attributes);
    return true;
  });
}

bool CodeGenFunction::EmitArrayAssignment(Address destination, Address source, const ArrayType& type,
                                          const FunctionDecl& assignment) {
  if (!HasArrayElements(type)) {
    return true;
  }
  return EmitArrayLoop(type.GetLength(), false, "array.assign", [&](llvm::Value* index) {
    Address target_element = EmitArrayElement(destination, index, /*in_bounds=*/true);
    Address source_element = EmitArrayElement(source, index, /*in_bounds=*/true);
    const Type& element_type = *type.GetElementType().GetTypePtr();
    if (const auto* array = element_type.AsArrayType()) {
      return EmitArrayAssignment(target_element, source_element, *array, assignment);
    }
    const auto& signature = *assignment.type.GetTypePtr()->AsFunctionType();
    const auto& info = *std::get<const CodeGen::FunctionInfo*>(codegen_.GetFunctionInfo(assignment));
    BOOST_ASSERT(info.parameters.size() == 2);
    std::vector<llvm::Value*> arguments(info.type->getNumParams());
    arguments[*info.parameters[0].llvm_index] = target_element.pointer;
    arguments[*info.parameters[1].llvm_index] = source_element.pointer;
    // Each implicit element call is a full-expression; operand temporaries belong to the outer one.
    const auto depth = temporary_cleanups_.size();
    EmitCall(signature, info, codegen_.functions_.at(&assignment), arguments, {{}, true});
    return EmitTemporaryCleanups(depth);
  });
}

bool CodeGenFunction::EmitStructorCall(const FunctionDecl& declaration, Address target,
                                       llvm::ArrayRef<const Expr*> sources) {
  const auto& info = *std::get<const CodeGen::FunctionInfo*>(codegen_.GetFunctionInfo(declaration));
  BOOST_ASSERT(info.this_index && target.element_type == info.this_type);
  std::vector<llvm::Value*> arguments(info.type->getNumParams());
  arguments[*info.this_index] = target.pointer;
  if (!EmitCallArguments(*declaration.type.GetTypePtr()->AsFunctionType(), info, sources, EvaluationOrder::LeftToRight,
                         arguments)) {
    return false;
  }
  auto* call = builder_.CreateCall(info.type, codegen_.functions_.at(&declaration), arguments);
  NameCallResult(*call);
  call->setAttributes(info.attributes);
  return true;
}

llvm::Value* CodeGenFunction::EmitScalarExpr(const Expr& expression) {
  auto conversion = codegen_.ConvertType(*expression.type.GetTypePtr());
  if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&conversion)) {
    codegen_.DiagnoseTypeConversionFailure(expression, *failure, "this expression type");
    return nullptr;
  }
  auto* result_type = std::get<llvm::Type*>(conversion);
  switch (expression.GetKind()) {
    case NodeKind::ConstructionExpr: {
      const auto& construction = static_cast<const ConstructionExpr&>(expression);
      BOOST_ASSERT(construction.TargetAddress);
      auto* pointer = EmitScalarExpr(*construction.TargetAddress);
      if (!pointer) {
        return nullptr;
      }
      auto target_type =
          codegen_.ConvertTypeForMem(*expression.type.GetTypePtr()->AsPointerType()->GetPointee().GetTypePtr());
      if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&target_type)) {
        codegen_.DiagnoseTypeConversionFailure(expression, *failure, "this construction target type");
        return nullptr;
      }
      return EmitConstruction(construction,
                              MakeAddress(pointer, std::get<llvm::Type*>(target_type),
                                          construction.type.GetTypePtr()->AsPointerType()->GetPointee().GetTypePtr()))
                 ? pointer
                 : nullptr;
    }
    case NodeKind::BoolLiteral:
      return builder_.getInt1(static_cast<const BoolLiteral&>(expression).value);
    case NodeKind::CharacterLiteral:
      return builder_.getInt8(static_cast<const CharacterLiteral&>(expression).value);
    case NodeKind::FloatLiteral:
      return llvm::ConstantFP::get(*codegen_.llvm_context_, static_cast<const FloatLiteral&>(expression).value);
    case NodeKind::ParenExpr:
      return EmitScalarExpr(*static_cast<const ParenExpr&>(expression).SubExpr);
    case NodeKind::CallExpr:
    case NodeKind::OperatorCallExpr:
    case NodeKind::ReceiverCallExpr: {
      auto value = EmitCall(static_cast<const CallExpr&>(expression));
      return value ? std::get<llvm::Value*>(*value) : nullptr;
    }
    case NodeKind::ImplicitOverloadSetSelectionExpr: {
      const auto& selection = static_cast<const ImplicitOverloadSetSelectionExpr&>(expression);
      if (selection.selected_declaration->GetKind() == NodeKind::VirtualFunctionDecl) {
        return codegen_.GetVirtualFunctionPointer(
            static_cast<const VirtualFunctionDecl&>(*selection.selected_declaration));
      }
      const auto it = codegen_.functions_.find(selection.selected_declaration);
      if (it == codegen_.functions_.end()) {
        codegen_.InternalError(expression, "selected function has no LLVM declaration");
        return nullptr;
      }
      // The source overload set is retained for diagnostics, not runtime evaluation.
      return it->second;
    }
    case NodeKind::ImplicitCastExpr: {
      const auto& cast = static_cast<const ImplicitCastExpr&>(expression);
      switch (cast.conversion_kind) {
        case ImplicitConversionKind::BaseSubobject:
          return EmitBaseSubobject(*cast.SubExpr, cast.base_path, /*through_pointer=*/true).pointer;
        case ImplicitConversionKind::NullToPointer:
          return llvm::Constant::getNullValue(result_type);
        case ImplicitConversionKind::LValueToRValue: {
          Address source = EmitLValue(*cast.SubExpr);
          if (!source) {
            return nullptr;
          }
          return EmitLoadOfScalar(source, *expression.type.GetTypePtr());
        }
        case ImplicitConversionKind::ComptimeIntegerMaterialization: {
          // Reuse the exact integer evaluator only at the materialization selected by Sema.
          auto result = sema_detail::EvaluateConstantInteger(*cast.SubExpr, *codegen_.ast_context_);
          const auto* integer = std::get_if<llvm::APSInt>(&result);
          if (!integer) {
            codegen_.Unsupported(expression, "this compile-time integer expression");
            return nullptr;
          }
          const auto* type = expression.type.GetTypePtr()->AsBuiltinType();
          return builder_.getInt(integer->extOrTrunc(codegen_.ast_context_->GetIntegerBitWidth(*type)));
        }
        case ImplicitConversionKind::IntegerToInteger:
        case ImplicitConversionKind::IntegerToFloat:
        case ImplicitConversionKind::FloatToFloat:
        case ImplicitConversionKind::FloatToInteger: {
          auto* value = EmitScalarExpr(*cast.SubExpr);
          if (!value) {
            return nullptr;
          }
          const auto* source_type = cast.SubExpr->type.GetTypePtr()->AsBuiltinType();
          if (cast.conversion_kind == ImplicitConversionKind::IntegerToInteger) {
            // Widen using the source interpretation; narrowing keeps low bits and equal widths keep all bits.
            return builder_.CreateIntCast(value, result_type, source_type->IsSignedInteger(), "conv");
          }
          if (cast.conversion_kind == ImplicitConversionKind::IntegerToFloat) {
            return source_type->IsSignedInteger() ? builder_.CreateSIToFP(value, result_type, "conv")
                                                  : builder_.CreateUIToFP(value, result_type, "conv");
          }
          if (cast.conversion_kind == ImplicitConversionKind::FloatToFloat) {
            return builder_.CreateFPCast(value, result_type, "conv");
          }
          // Saturation includes NaN -> 0; ordinary fptosi/fptoui would produce poison out of range.
          const auto intrinsic = expression.type.GetTypePtr()->AsBuiltinType()->IsSignedInteger()
                                     ? llvm::Intrinsic::fptosi_sat
                                     : llvm::Intrinsic::fptoui_sat;
          return builder_.CreateIntrinsic(intrinsic, {result_type, value->getType()}, {value}, {}, "conv");
        }
        case ImplicitConversionKind::Identity:
        case ImplicitConversionKind::Qualification:
          return EmitScalarExpr(*cast.SubExpr);
        default:
          break;
      }
      break;
    }
    case NodeKind::UnaryOperator: {
      const auto& unary = static_cast<const UnaryOperator&>(expression);
      if (unary.op == expr::amp) {
        return EmitLValue(*unary.Operand).pointer;
      }
      if (unary.op == expr::exclaim || unary.op == expr::plus || unary.op == expr::minus) {
        auto* operand = EmitScalarExpr(*unary.Operand);
        if (!operand) {
          return nullptr;
        }
        if (unary.op == expr::exclaim) {
          return builder_.CreateNot(operand);
        }
        if (unary.Operand->type.GetTypePtr()->AsBuiltinType()->IsFloatingPoint()) {
          return unary.op == expr::minus ? builder_.CreateFNeg(operand, "fneg") : operand;
        }
        // Ordinary typed negation wraps, including when IRBuilder folds a constant.
        return unary.op == expr::minus ? builder_.CreateNeg(operand, "sub") : operand;
      }
      break;
    }
    case NodeKind::BinaryOperator: {
      const auto& binary = static_cast<const BinaryOperator&>(expression);
      if (binary.op == expr::ampamp || binary.op == expr::pipepipe) {
        return EmitLogicalExpr(binary);
      }
      if (binary.LHS->type.GetTypePtr()->AsNullType() && binary.RHS->type.GetTypePtr()->AsNullType()) {
        // Untyped nulls have no runtime object or pointer type to evaluate.
        return builder_.getInt1(binary.op == expr::equalequal);
      }
      // Finish the left value's loads and conversions before any right-side effects.
      auto* lhs = EmitScalarExpr(*binary.LHS);
      if (!lhs) {
        return nullptr;
      }
      auto* rhs = EmitScalarExpr(*binary.RHS);
      if (!rhs) {
        return nullptr;
      }
      // Sema has converted both operands to their common type; the result may instead be bool.
      if (binary.LHS->type.GetTypePtr()->AsVirtualSlotType()) {
        // Sema permits virtual interface pointers to be compared only with null.
        auto* left = EmitVirtualPointerIsNotNull(lhs);
        auto* right = EmitVirtualPointerIsNotNull(rhs);
        return binary.op == expr::equalequal ? builder_.CreateICmpEQ(left, right, "cmp")
                                             : builder_.CreateICmpNE(left, right, "cmp");
      }
      if (binary.LHS->type.GetTypePtr()->AsPointerType()) {
        if (binary.op == expr::equalequal) {
          return builder_.CreateICmpEQ(lhs, rhs, "cmp");
        }
        if (binary.op == expr::exclaimequal) {
          return builder_.CreateICmpNE(lhs, rhs, "cmp");
        }
        break;
      }
      const auto* operand_type = binary.LHS->type.GetTypePtr()->AsBuiltinType();
      if (operand_type->IsFloatingPoint()) {
        // Keep default IEEE behavior and per-operation rounding; do not grant fast-math permissions.
        switch (binary.op) {
          case expr::plus:
            return builder_.CreateFAdd(lhs, rhs, "add");
          case expr::minus:
            return builder_.CreateFSub(lhs, rhs, "sub");
          case expr::star:
            return builder_.CreateFMul(lhs, rhs, "mul");
          case expr::slash:
            return builder_.CreateFDiv(lhs, rhs, "div");
          case expr::equalequal:
            return builder_.CreateFCmpOEQ(lhs, rhs, "cmp");
          case expr::exclaimequal:
            return builder_.CreateFCmpUNE(lhs, rhs, "cmp");
          case expr::less:
            return builder_.CreateFCmpOLT(lhs, rhs, "cmp");
          case expr::lessequal:
            return builder_.CreateFCmpOLE(lhs, rhs, "cmp");
          case expr::greater:
            return builder_.CreateFCmpOGT(lhs, rhs, "cmp");
          case expr::greaterequal:
            return builder_.CreateFCmpOGE(lhs, rhs, "cmp");
          default:
            break;
        }
        break;
      }
      const bool is_signed = operand_type->IsSignedInteger();
      // Do not attach overflow flags: ordinary integer arithmetic wraps at its type width.
      switch (binary.op) {
        case expr::plus:
          return builder_.CreateAdd(lhs, rhs, "add");
        case expr::minus:
          return builder_.CreateSub(lhs, rhs, "sub");
        case expr::star:
          return builder_.CreateMul(lhs, rhs, "mul");
        case expr::slash:
        case expr::percent:
          return EmitIntegerDivRem(lhs, rhs, binary.op == expr::slash, is_signed);
        case expr::equalequal:
          return builder_.CreateICmpEQ(lhs, rhs, "cmp");
        case expr::exclaimequal:
          return builder_.CreateICmpNE(lhs, rhs, "cmp");
        case expr::less:
          return is_signed ? builder_.CreateICmpSLT(lhs, rhs, "cmp") : builder_.CreateICmpULT(lhs, rhs, "cmp");
        case expr::lessequal:
          return is_signed ? builder_.CreateICmpSLE(lhs, rhs, "cmp") : builder_.CreateICmpULE(lhs, rhs, "cmp");
        case expr::greater:
          return is_signed ? builder_.CreateICmpSGT(lhs, rhs, "cmp") : builder_.CreateICmpUGT(lhs, rhs, "cmp");
        case expr::greaterequal:
          return is_signed ? builder_.CreateICmpSGE(lhs, rhs, "cmp") : builder_.CreateICmpUGE(lhs, rhs, "cmp");
        default:
          break;
      }
      break;
    }
    case NodeKind::ConditionalOperator:
      return EmitConditionalExpr(static_cast<const ConditionalOperator&>(expression));
    default:
      break;
  }
  codegen_.Unsupported(expression, "this scalar expression");
  return nullptr;
}

llvm::Value* CodeGenFunction::EmitIntegerDivRem(llvm::Value* lhs, llvm::Value* rhs, bool is_division, bool is_signed) {
  if (!is_signed) {
    return is_division ? builder_.CreateUDiv(lhs, rhs, "div") : builder_.CreateURem(lhs, rhs, "rem");
  }
  const auto emit_negative_one = [&]() -> llvm::Value* {
    return is_division ? builder_.CreateNeg(lhs, "sub") : llvm::ConstantInt::get(lhs->getType(), 0);
  };
  const auto emit_ordinary = [&]() {
    return is_division ? builder_.CreateSDiv(lhs, rhs, "div") : builder_.CreateSRem(lhs, rhs, "rem");
  };
  // Both operands have already been evaluated, even if the remainder is known to be zero.
  if (const auto* divisor = llvm::dyn_cast<llvm::ConstantInt>(rhs)) {
    return divisor->isMinusOne() ? emit_negative_one() : emit_ordinary();
  }

  // LLVM's signed division and remainder are undefined for MIN and -1. Branch before
  // either instruction; computing an unsafe result before a select would still be undefined.
  auto* negative_one = CreateBasicBlock(is_division ? "div.negone" : "rem.negone");
  auto* ordinary = CreateBasicBlock(is_division ? "div.normal" : "rem.normal");
  auto* continuation = CreateBasicBlock(is_division ? "div.end" : "rem.end");
  builder_.CreateCondBr(builder_.CreateICmpEQ(rhs, llvm::ConstantInt::getAllOnesValue(rhs->getType())), negative_one,
                        ordinary);
  builder_.ClearInsertionPoint();
  EmitBlock(negative_one);
  auto* special_value = emit_negative_one();
  EmitBranch(continuation);
  EmitBlock(ordinary);
  auto* ordinary_value = emit_ordinary();
  EmitBlock(continuation);
  auto* result = builder_.CreatePHI(lhs->getType(), 2, is_division ? "div" : "rem");
  result->addIncoming(special_value, negative_one);
  result->addIncoming(ordinary_value, ordinary);
  return result;
}

llvm::Value* CodeGenFunction::EmitLogicalExpr(const BinaryOperator& expression) {
  auto* entry = builder_.GetInsertBlock();
  const bool is_and = expression.op == expr::ampamp;
  auto* rhs = CreateBasicBlock(is_and ? "land.rhs" : "lor.rhs");
  auto* continuation = CreateBasicBlock(is_and ? "land.end" : "lor.end");
  if (!EmitBranchOnBoolExpr(*expression.LHS, is_and ? rhs : continuation, is_and ? continuation : rhs)) {
    return nullptr;
  }
  // A nested LHS can short-circuit along several edges to the same result block.
  auto* result = llvm::PHINode::Create(builder_.getInt1Ty(), 2, "", continuation);
  for (auto* predecessor : llvm::predecessors(continuation)) {
    result->addIncoming(builder_.getInt1(!is_and), predecessor);
  }
  EmitBlock(rhs);
  llvm::Value* value = nullptr;
  {
    ConditionalEvaluation evaluation(*this, entry, rhs);
    value = EmitScalarExpr(*expression.RHS);
  }
  if (!value) {
    return nullptr;
  }
  auto* rhs_exit = builder_.GetInsertBlock();
  EmitBlock(continuation);
  result->addIncoming(value, rhs_exit);
  return result;
}

llvm::Value* CodeGenFunction::EmitConditionalExpr(const ConditionalOperator& expression) {
  auto* entry = builder_.GetInsertBlock();
  auto* then_block = CreateBasicBlock("cond.true");
  auto* else_block = CreateBasicBlock("cond.false");
  auto* continuation = CreateBasicBlock("cond.end");
  if (!EmitBranchOnBoolExpr(*expression.Cond, then_block, else_block)) {
    return nullptr;
  }
  EmitBlock(then_block);
  llvm::Value* then_value = nullptr;
  {
    ConditionalEvaluation evaluation(*this, entry, then_block);
    then_value = EmitScalarExpr(*expression.Then);
  }
  if (!then_value) {
    return nullptr;
  }
  then_block = builder_.GetInsertBlock();
  EmitBranch(continuation);
  EmitBlock(else_block);
  llvm::Value* else_value = nullptr;
  {
    ConditionalEvaluation evaluation(*this, entry, else_block);
    else_value = EmitScalarExpr(*expression.Else);
  }
  if (!else_value) {
    return nullptr;
  }
  else_block = builder_.GetInsertBlock();
  EmitBlock(continuation);
  auto* result = builder_.CreatePHI(then_value->getType(), 2, "cond");
  result->addIncoming(then_value, then_block);
  result->addIncoming(else_value, else_block);
  return result;
}

std::optional<RValue> CodeGenFunction::EmitCall(const CallExpr& expression, ReturnValueSlot slot) {
  const Expr* callee = expression.Callee->IgnoreParens();
  const Decl* declaration =
      callee->GetKind() == NodeKind::DeclRefExpr ? static_cast<const DeclRefExpr&>(*callee).declaration : nullptr;
  const FunctionType* signature = nullptr;
  llvm::Value* target = nullptr;
  const VirtualFunctionDecl* virtual_function = nullptr;
  llvm::Value* virtual_pointer = nullptr;
  if (declaration && declaration->GetKind() == NodeKind::VirtualFunctionDecl) {
    const auto& function = static_cast<const VirtualFunctionDecl&>(*declaration);
    signature = function.type.GetTypePtr()->AsFunctionType();
    if (expression.is_nonvirtual) {
      target = codegen_.functions_.at(function.definition);
    } else {
      virtual_function = &function;
    }
  } else if (declaration && declaration->GetKind() == NodeKind::FunctionDecl) {
    const auto* function = static_cast<const FunctionDecl*>(declaration);
    signature = function->type.GetTypePtr()->AsFunctionType();
    const auto it = codegen_.functions_.find(function);
    if (it == codegen_.functions_.end()) {
      codegen_.InternalError(expression, "selected function has no LLVM declaration");
      return std::nullopt;
    }
    target = it->second;
  } else {
    const auto* slot_type = callee->type.GetTypePtr()->AsVirtualSlotType();
    const auto* pointer_type =
        slot_type ? slot_type->GetEntryPointerType() : callee->type.GetTypePtr()->AsPointerType();
    signature = pointer_type ? pointer_type->GetPointee().GetTypePtr()->AsFunctionType() : nullptr;
    if (!signature) {
      codegen_.Unsupported(expression, "this call target");
      return std::nullopt;
    }
    // Capture the callee value before arguments can modify the function pointer object.
    target = EmitScalarExpr(*expression.Callee);
    if (!target) {
      return std::nullopt;
    }
    if (slot_type) {
      virtual_pointer = target;
    }
  }
  auto conversion = codegen_.GetFunctionInfo(*signature);
  if (const auto* failure = std::get_if<CodeGen::TypeConversionFailure>(&conversion)) {
    codegen_.DiagnoseTypeConversionFailure(expression, *failure, "this call signature");
    return std::nullopt;
  }
  const auto& info = *std::get<const CodeGen::FunctionInfo*>(conversion);

  // Receiver syntax stores its first argument separately; operator calls already have complete Args.
  std::vector<const Expr*> sources;
  if (expression.GetKind() == NodeKind::ReceiverCallExpr) {
    sources.push_back(static_cast<const ReceiverCallExpr&>(expression).Receiver.get());
  }
  for (const auto& argument : expression.Args) {
    sources.push_back(argument.get());
  }
  const auto& parameters = signature->GetParameterTypes();
  if (sources.size() != parameters.size()) {
    codegen_.InternalError(expression, "call arguments do not match the selected signature");
    return std::nullopt;
  }

  // Complete each argument, including value loads, before evaluating the next one.
  std::vector<llvm::Value*> arguments(info.type->getNumParams());
  const auto order = expression.GetKind() == NodeKind::OperatorCallExpr &&
                             static_cast<const OperatorCallExpr&>(expression).IsSimpleAssignment()
                         ? EvaluationOrder::RightToLeft
                         : EvaluationOrder::LeftToRight;
  if (!EmitCallArguments(*signature, info, sources, order, arguments)) {
    return std::nullopt;
  }
  if (virtual_function) {
    target = EmitVirtualCallee(*virtual_function, arguments[*info.parameters.front().llvm_index]);
  } else if (virtual_pointer) {
    target = EmitVirtualCallee(virtual_pointer, arguments[*info.parameters.front().llvm_index]);
  }
  return EmitCall(*signature, info, target, arguments, slot);
}

RValue CodeGenFunction::EmitCall(const FunctionType& signature, const CodeGen::FunctionInfo& info, llvm::Value* target,
                                 std::vector<llvm::Value*>& arguments, ReturnValueSlot slot) {
  const bool aggregate_result = IsAggregate(*signature.GetReturnType());
  BOOST_ASSERT(!slot.address || (aggregate_result && slot.address.element_type == info.result.memory_type));
  Address result_address = slot.address;
  if (aggregate_result && !result_address && (!slot.is_unused || info.result_index)) {
    result_address = CreateStorage(info.result.memory_type, "call.result", signature.GetReturnType());
  }
  if (info.result_index) {
    arguments[*info.result_index] = result_address.pointer;
  }
  auto* call = builder_.CreateCall(info.type, target, arguments);
  NameCallResult(*call);
  call->setAttributes(info.attributes);
  if (aggregate_result && result_address && info.result.kind == CodeGen::ABIArgInfo::Kind::Direct) {
    EmitCoercedStore(call, result_address);
  }
  if (aggregate_result && result_address && !slot.address) {
    AddTemporaryCleanup(result_address, *signature.GetReturnType());
  }
  if (slot.is_unused || signature.GetReturnType()->IsVoid()) {
    return RValue{};
  }
  if (aggregate_result) {
    return RValue{result_address};
  }
  return RValue{static_cast<llvm::Value*>(call)};
}

bool CodeGenFunction::EmitCallArguments(const FunctionType& signature, const CodeGen::FunctionInfo& info,
                                        llvm::ArrayRef<const Expr*> sources, EvaluationOrder order,
                                        std::vector<llvm::Value*>& arguments) {
  const auto& parameters = signature.GetParameterTypes();
  BOOST_ASSERT(sources.size() == parameters.size());
  for (std::size_t position = 0; position < sources.size(); ++position) {
    // Evaluation order controls formation and cleanup registration, not ABI parameter positions.
    const auto index = order == EvaluationOrder::LeftToRight ? position : sources.size() - position - 1;
    const auto& parameter = info.parameters[index];
    if (parameter.abi.kind == CodeGen::ABIArgInfo::Kind::Ignore) {
      if (!EmitIgnoredExpr(*sources[index])) {
        return false;
      }
      continue;
    }
    llvm::Value* value = nullptr;
    if (IsAggregate(*parameters[index])) {
      Address storage = CreateStorage(parameter.abi.memory_type, "argument", parameters[index]);
      if (!EmitAggExpr(*sources[index], storage)) {
        return false;
      }
      AddTemporaryCleanup(storage, *parameters[index]);
      value = parameter.abi.kind == CodeGen::ABIArgInfo::Kind::Indirect
                  ? storage.pointer
                  : EmitCoercedLoad(storage, parameter.abi.direct_type);
    } else {
      value =
          parameters[index]->AsReferenceType() ? EmitLValue(*sources[index]).pointer : EmitScalarExpr(*sources[index]);
    }
    if (!value) {
      return false;
    }
    arguments[*parameter.llvm_index] = value;
  }
  return true;
}

}  // namespace cw::codegen_detail
