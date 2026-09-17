/// \file ASTContext.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "ASTContext.h"

#include <climits>
#include <memory>
#include <utility>

#include <boost/assert.hpp>
#include <boost/container_hash/hash.hpp>

namespace cw {

unsigned ASTContext::GetIntegerBitWidth(const BuiltinType& type) const {
  BOOST_ASSERT(type.IsInteger());
  switch (type.GetBuiltinTypeKind()) {
    case BuiltinTypeKind::I8:
    case BuiltinTypeKind::U8:
      return 8;
    case BuiltinTypeKind::I16:
    case BuiltinTypeKind::U16:
      return 16;
    case BuiltinTypeKind::I32:
    case BuiltinTypeKind::U32:
      return 32;
    case BuiltinTypeKind::I64:
    case BuiltinTypeKind::U64:
      return 64;
    case BuiltinTypeKind::ISize:
    case BuiltinTypeKind::USize:
      return static_cast<unsigned>(sizeof(void*) * CHAR_BIT);
    default:
      BOOST_ASSERT(false && "type is not a built-in integer");
      return 0;
  }
}

FloatingPointProperties ASTContext::GetFloatingPointProperties(const BuiltinType& type) const {
  BOOST_ASSERT(type.IsFloatingPoint());
  if (type.GetBuiltinTypeKind() == BuiltinTypeKind::F32) {
    return {32, 24, 128, -149};
  }
  return {64, 53, 1024, -1074};
}

ASTContext::ASTContext(ABIKind abi) : abi_(abi), translation_unit_(std::make_unique<TranslationUnitDecl>()) {}

ASTContext::~ASTContext() = default;

TranslationUnitDecl* ASTContext::GetTranslationUnitDecl() { return translation_unit_.get(); }

const TranslationUnitDecl* ASTContext::GetTranslationUnitDecl() const { return translation_unit_.get(); }

const ComptimeIntType* ASTContext::GetComptimeIntType() {
  if (comptime_int_type_) {
    return comptime_int_type_;
  }

  std::unique_ptr<Type> type(new ComptimeIntType());
  comptime_int_type_ = static_cast<const ComptimeIntType*>(type.get());
  types_.push_back(std::move(type));
  return comptime_int_type_;
}

const NullType* ASTContext::GetNullType() {
  if (null_type_) {
    return null_type_;
  }
  std::unique_ptr<Type> type(new NullType());
  null_type_ = static_cast<const NullType*>(type.get());
  types_.push_back(std::move(type));
  return null_type_;
}

const FunctionOverloadSetType* ASTContext::GetFunctionOverloadSetType() {
  if (function_overload_set_type_) {
    return function_overload_set_type_;
  }

  std::unique_ptr<Type> type(new FunctionOverloadSetType());
  function_overload_set_type_ = static_cast<const FunctionOverloadSetType*>(type.get());
  types_.push_back(std::move(type));
  return function_overload_set_type_;
}

const AddressOfFunctionOverloadSetType* ASTContext::GetAddressOfFunctionOverloadSetType() {
  if (address_of_function_overload_set_type_) {
    return address_of_function_overload_set_type_;
  }

  std::unique_ptr<Type> type(new AddressOfFunctionOverloadSetType());
  address_of_function_overload_set_type_ = static_cast<const AddressOfFunctionOverloadSetType*>(type.get());
  types_.push_back(std::move(type));
  return address_of_function_overload_set_type_;
}

std::size_t ASTContext::FunctionTypeKeyHash::operator()(const FunctionTypeKey& key) const {
  std::size_t result = 0;
  boost::hash_combine(result, key.return_type);
  for (const Type* parameter_type : key.parameter_types) {
    boost::hash_combine(result, parameter_type);
  }
  return result;
}

std::size_t ASTContext::QualTypeHash::operator()(QualType type) const {
  std::size_t result = 0;
  boost::hash_combine(result, type.GetTypePtr());
  boost::hash_combine(result, type.IsConstQualified());
  return result;
}

std::size_t ASTContext::ReferenceTypeKeyHash::operator()(const ReferenceTypeKey& key) const {
  std::size_t result = 0;
  boost::hash_combine(result, key.mode);
  boost::hash_combine(result, key.referent_type);
  return result;
}

std::size_t ASTContext::ArrayTypeKeyHash::operator()(const ArrayTypeKey& key) const {
  std::size_t result = 0;
  boost::hash_combine(result, QualTypeHash{}(key.element_type));
  boost::hash_combine(result, key.length);
  return result;
}

const BuiltinType* ASTContext::GetBuiltinType(BuiltinTypeKind kind) {
  BOOST_ASSERT(kind != BuiltinTypeKind::Invalid);

  const auto it = builtin_types_.find(kind);
  if (it != builtin_types_.end()) {
    return it->second;
  }

  std::unique_ptr<Type> type(new BuiltinType(kind));
  const auto* result = static_cast<const BuiltinType*>(type.get());
  types_.push_back(std::move(type));
  builtin_types_.emplace(kind, result);
  return result;
}

const StructType* ASTContext::GetStructType(const StructDecl* declaration) {
  BOOST_ASSERT(declaration);

  const auto it = struct_types_.find(declaration);
  if (it != struct_types_.end()) {
    return it->second;
  }

  std::unique_ptr<Type> type(new StructType(declaration));
  const auto* result = static_cast<const StructType*>(type.get());
  types_.push_back(std::move(type));
  struct_types_.emplace(declaration, result);
  return result;
}

const ArrayType* ASTContext::GetArrayType(QualType element_type, ArrayLength length) {
  BOOST_ASSERT(element_type);

  const ArrayTypeKey key{element_type, length};
  const auto it = array_types_.find(key);
  if (it != array_types_.end()) {
    return it->second;
  }

  std::unique_ptr<Type> type(new ArrayType(element_type, length));
  const auto* result = static_cast<const ArrayType*>(type.get());
  types_.push_back(std::move(type));
  array_types_.emplace(key, result);
  return result;
}

const PointerType* ASTContext::GetPointerType(QualType pointee) {
  BOOST_ASSERT(pointee);

  const auto it = pointer_types_.find(pointee);
  if (it != pointer_types_.end()) {
    return it->second;
  }

  std::unique_ptr<Type> type(new PointerType(pointee));
  const auto* result = static_cast<const PointerType*>(type.get());
  types_.push_back(std::move(type));
  pointer_types_.emplace(pointee, result);
  return result;
}

const VirtualSlotType* ASTContext::GetVirtualSlotType(const PointerType* entry_pointer_type) {
  BOOST_ASSERT(entry_pointer_type);
  const QualType pointee = entry_pointer_type->GetPointee();
  BOOST_ASSERT(pointee && pointee.GetTypePtr()->GetKind() == TypeKind::Function);

  const auto it = virtual_slot_types_.find(entry_pointer_type);
  if (it != virtual_slot_types_.end()) {
    return it->second;
  }

  std::unique_ptr<Type> type(new VirtualSlotType(entry_pointer_type));
  const auto* result = static_cast<const VirtualSlotType*>(type.get());
  types_.push_back(std::move(type));
  virtual_slot_types_.emplace(entry_pointer_type, result);
  return result;
}

const FunctionType* ASTContext::GetFunctionType(const std::vector<const Type*>& parameter_types,
                                                const Type* return_type) {
  BOOST_ASSERT(return_type);
  for (const Type* parameter_type : parameter_types) {
    BOOST_ASSERT(parameter_type);
  }

  FunctionTypeKey key{parameter_types, return_type};
  const auto it = function_types_.find(key);
  if (it != function_types_.end()) {
    return it->second;
  }

  std::unique_ptr<Type> type(new FunctionType(parameter_types, return_type));
  const auto* result = static_cast<const FunctionType*>(type.get());
  types_.push_back(std::move(type));
  function_types_.emplace(std::move(key), result);
  return result;
}

const ReferenceType* ASTContext::GetReferenceType(ReferenceMode mode, const Type* referent_type) {
  BOOST_ASSERT(referent_type);

  const ReferenceTypeKey key{mode, referent_type};
  const auto it = reference_types_.find(key);
  if (it != reference_types_.end()) {
    return it->second;
  }

  std::unique_ptr<Type> type(new ReferenceType(mode, referent_type));
  const auto* result = static_cast<const ReferenceType*>(type.get());
  types_.push_back(std::move(type));
  reference_types_.emplace(key, result);
  return result;
}

}  // namespace cw
