/// \file ASTContext.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <memory>
#include <unordered_map>
#include <vector>

#include "ABI.h"
#include "ast.h"

namespace cw {

/// \brief Floating-point representation facts consumed by numeric semantics.
struct FloatingPointProperties {
  unsigned storage_bits{};           ///< Number of bits in the representation.
  unsigned significand_bits{};       ///< Precision including the implicit leading bit.
  int maximum_exponent{};            ///< Exclusive upper bound for the binary exponent.
  int minimum_subnormal_exponent{};  ///< Exponent of the least positive subnormal.
};

/// \brief Owns one translation unit and its persistent semantic state.
class ASTContext {
  struct QualTypeHash {
    std::size_t operator()(QualType type) const;
  };

  struct FunctionTypeKey {
    std::vector<const Type*> parameter_types;
    const Type* return_type{};

    bool operator==(const FunctionTypeKey& other) const {
      return return_type == other.return_type && parameter_types == other.parameter_types;
    }
  };

  struct ArrayTypeKey {
    QualType element_type{};
    ArrayLength length{};

    bool operator==(const ArrayTypeKey& other) const {
      return element_type == other.element_type && length == other.length;
    }
  };

  struct ArrayTypeKeyHash {
    std::size_t operator()(const ArrayTypeKey& key) const;
  };

  struct FunctionTypeKeyHash {
    std::size_t operator()(const FunctionTypeKey& key) const;
  };

  struct ReferenceTypeKey {
    ReferenceMode mode{};
    const Type* referent_type{};

    bool operator==(const ReferenceTypeKey& other) const {
      return mode == other.mode && referent_type == other.referent_type;
    }
  };

  struct ReferenceTypeKeyHash {
    std::size_t operator()(const ReferenceTypeKey& key) const;
  };

  const ABIKind abi_;
  std::vector<std::unique_ptr<Type>> types_;  ///< Owned semantic types.
  const ComptimeIntType* comptime_int_type_{};
  const NullType* null_type_{};
  const FunctionOverloadSetType* function_overload_set_type_{};
  const AddressOfFunctionOverloadSetType* address_of_function_overload_set_type_{};
  std::unordered_map<BuiltinTypeKind, const BuiltinType*> builtin_types_;
  std::unordered_map<const StructDecl*, const StructType*> struct_types_;
  std::unordered_map<ArrayTypeKey, const ArrayType*, ArrayTypeKeyHash> array_types_;
  std::unordered_map<QualType, const PointerType*, QualTypeHash> pointer_types_;
  std::unordered_map<const PointerType*, const VirtualSlotType*> virtual_slot_types_;
  std::unordered_map<FunctionTypeKey, const FunctionType*, FunctionTypeKeyHash> function_types_;
  std::unordered_map<ReferenceTypeKey, const ReferenceType*, ReferenceTypeKeyHash> reference_types_;
  std::unique_ptr<TranslationUnitDecl> translation_unit_;  ///< Owned AST root.

 public:
  explicit ASTContext(ABIKind abi = ABIKind::Itanium);
  ~ASTContext();

  ASTContext(const ASTContext&) = delete;
  ASTContext& operator=(const ASTContext&) = delete;
  ASTContext(ASTContext&&) = delete;
  ASTContext& operator=(ASTContext&&) = delete;

  ABIKind GetABIKind() const { return abi_; }

  /// \brief Returns the owned translation unit.
  TranslationUnitDecl* GetTranslationUnitDecl();

  /// \brief Returns the owned translation unit.
  const TranslationUnitDecl* GetTranslationUnitDecl() const;

  /// \brief Returns the canonical semantic type for \p kind.
  const BuiltinType* GetBuiltinType(BuiltinTypeKind kind);

  /// \brief Returns the semantic width; type must be a built-in integer.
  unsigned GetIntegerBitWidth(const BuiltinType& type) const;

  /// \brief Returns representation facts; type must be a built-in floating-point type.
  FloatingPointProperties GetFloatingPointProperties(const BuiltinType& type) const;

  /// \brief Returns the canonical exact compile-time integer type.
  const ComptimeIntType* GetComptimeIntType();

  /// \brief Returns the canonical nonobject type of the null literal.
  const NullType* GetNullType();

  /// \brief Returns the internal singleton function-overload-set type.
  const FunctionOverloadSetType* GetFunctionOverloadSetType();

  /// \brief Returns the internal singleton addressed-function-overload-set type.
  const AddressOfFunctionOverloadSetType* GetAddressOfFunctionOverloadSetType();

  /// \brief Returns the canonical semantic type for \p declaration.
  const StructType* GetStructType(const StructDecl* declaration);

  /// \brief Returns the canonical fixed-size array type.
  const ArrayType* GetArrayType(QualType element_type, ArrayLength length);

  /// \brief Returns the canonical pointer type for \p pointee.
  const PointerType* GetPointerType(QualType pointee);

  /// \brief Returns the canonical virtual slot type wrapping \p entry_pointer_type.
  const VirtualSlotType* GetVirtualSlotType(const PointerType* entry_pointer_type);

  /// \brief Returns the canonical function type for the complete signature.
  const FunctionType* GetFunctionType(const std::vector<const Type*>& parameter_types, const Type* return_type);

  /// \brief Returns the canonical reference type for \p mode and \p referent_type.
  const ReferenceType* GetReferenceType(ReferenceMode mode, const Type* referent_type);
};

}  // namespace cw
