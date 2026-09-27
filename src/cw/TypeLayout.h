/// \file TypeLayout.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstdint>
#include <optional>
#include <variant>
#include <vector>

namespace cw {

class ASTContext;
class ArrayType;
class Type;
struct FieldDecl;
struct StructDecl;

/// \brief Complete object storage, in bytes.
struct TypeLayout {
  std::uint64_t size{};
  std::uint64_t alignment{1};
};

/// \brief ABI storage facts; none of these fields changes the semantic type.
struct StructLayout {
  TypeLayout complete;
  std::uint64_t data_size{};
  std::uint64_t non_virtual_size{};
  std::optional<std::uint64_t> base_offset;
  std::vector<std::uint64_t> field_offsets;
};

enum class LayoutFailureKind { ArrayTooLarge, StructTooLarge };

/// \brief An array or struct exceeds the target's maximum object size.
/// The consumer chooses the diagnostic location and how to recover.
struct LayoutFailure {
  LayoutFailureKind kind{};
  const ArrayType* array{};       ///< Present for ArrayTooLarge.
  const StructDecl* structure{};  ///< Present for StructTooLarge.
  const FieldDecl* field{};       ///< Optional field at which the struct exceeded the limit.
};

using TypeLayoutResult = std::variant<TypeLayout, LayoutFailure>;
using StructLayoutResult = std::variant<const StructLayout*, LayoutFailure>;

namespace layout_detail {
TypeLayoutResult ComputeTypeLayout(const ASTContext& context, const Type& type);
std::variant<StructLayout, LayoutFailure> ComputeStructLayout(const ASTContext& context, const StructDecl& declaration);
}  // namespace layout_detail

}  // namespace cw
