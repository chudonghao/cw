/// \file TypeLayout.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "TypeLayout.h"

#include <algorithm>

#include <boost/assert.hpp>

#include "ASTContext.h"

namespace cw::layout_detail {

namespace {

bool AddSize(std::uint64_t left, std::uint64_t right, std::uint64_t limit, std::uint64_t& result) {
  if (left > limit || right > limit - left) {
    return false;
  }
  result = left + right;
  return true;
}

bool AlignSize(std::uint64_t size, std::uint64_t alignment, std::uint64_t limit, std::uint64_t& result) {
  return AddSize(size, (alignment - size % alignment) % alignment, limit, result);
}

// A single empty base can share offset zero with data, but not with another
// subobject of the same empty type, including one nested in a member or array.
bool HasEmptySubobjectAtZero(const ASTContext& context, const Type& type, const StructDecl& empty) {
  if (const auto* array = type.AsArrayType()) {
    return array->GetLength() != 0 && HasEmptySubobjectAtZero(context, *array->GetElementType().GetTypePtr(), empty);
  }
  const auto* structure = type.AsStructType();
  if (!structure) {
    return false;
  }
  const auto& declaration = *structure->GetDeclaration();
  if (&declaration == &empty) {
    return true;
  }
  const auto& layout = *std::get<const StructLayout*>(context.GetStructLayout(declaration));
  if (declaration.base_type && *layout.base_offset == 0 &&
      HasEmptySubobjectAtZero(context, *declaration.base_type, empty)) {
    return true;
  }
  for (std::size_t index = 0; index < declaration.Fields.size(); ++index) {
    if (layout.field_offsets[index] == 0 &&
        HasEmptySubobjectAtZero(context, *declaration.Fields[index]->type.GetTypePtr(), empty)) {
      return true;
    }
  }
  return false;
}

bool ConflictsWithEmptyBase(const ASTContext& context, const StructDecl& declaration, const Type& field) {
  for (auto* base = declaration.base_type; base; base = base->GetDeclaration()->base_type) {
    if (base->GetDeclaration()->IsEmpty() && HasEmptySubobjectAtZero(context, field, *base->GetDeclaration())) {
      return true;
    }
  }
  return false;
}

}  // namespace

TypeLayoutResult ComputeTypeLayout(const ASTContext& context, const Type& type) {
  BOOST_ASSERT(type.IsObject());
  const auto& target = context.GetTargetInfo();
  if (const auto* builtin = type.AsBuiltinType()) {
    std::uint64_t size = 1;
    if (builtin->IsInteger()) {
      size = context.GetIntegerBitWidth(*builtin) / 8;
    } else if (builtin->IsFloatingPoint()) {
      size = context.GetFloatingPointProperties(*builtin).storage_bits / 8;
    }
    return TypeLayout{size, target.GetScalarAlignment(static_cast<unsigned>(size * 8))};
  }
  if (type.AsPointerType()) {
    return TypeLayout{target.GetPointerBitWidth() / 8, target.GetPointerAlignment()};
  }
  if (type.AsVirtualSlotType()) {
    return TypeLayout{2 * target.GetPointerBitWidth() / 8, target.GetPointerAlignment()};
  }
  if (const auto* array = type.AsArrayType()) {
    const auto element = context.GetTypeLayout(*array->GetElementType().GetTypePtr());
    if (const auto* failure = std::get_if<LayoutFailure>(&element)) {
      return *failure;
    }
    const auto layout = std::get<TypeLayout>(element);
    if (layout.size != 0 && array->GetLength() > target.GetMaxObjectSize() / layout.size) {
      return LayoutFailure{LayoutFailureKind::ArrayTooLarge, array};
    }
    return TypeLayout{layout.size * array->GetLength(), layout.alignment};
  }
  const auto* structure = type.AsStructType();
  BOOST_ASSERT(structure);
  const auto result = context.GetStructLayout(*structure->GetDeclaration());
  if (const auto* failure = std::get_if<LayoutFailure>(&result)) {
    return *failure;
  }
  return std::get<const StructLayout*>(result)->complete;
}

std::variant<StructLayout, LayoutFailure> ComputeStructLayout(const ASTContext& context,
                                                              const StructDecl& declaration) {
  BOOST_ASSERT(!declaration.is_invalid);
  BOOST_ASSERT(declaration.triviality == TypeTriviality::Trivial ||
               declaration.triviality == TypeTriviality::NonTrivial);
  const auto limit = context.GetTargetInfo().GetMaxObjectSize();
  StructLayout result;
  const auto* base_declaration = declaration.base_type ? declaration.base_type->GetDeclaration() : nullptr;
  const StructLayout* base = nullptr;
  if (base_declaration) {
    const auto layout = context.GetStructLayout(*base_declaration);
    if (const auto* failure = std::get_if<LayoutFailure>(&layout)) {
      return *failure;
    }
    base = std::get<const StructLayout*>(layout);
  }
  const bool base_is_empty = base_declaration && base_declaration->IsEmpty();
  result.complete.alignment = base ? base->complete.alignment : 1;

  // In single inheritance a polymorphic base is primary. A class introducing virtual
  // functions places its own vptr before any nonempty ordinary base.
  std::uint64_t size = 0;
  std::uint64_t data_size = 0;
  if (declaration.IsPolymorphic() && (!base_declaration || !base_declaration->IsPolymorphic())) {
    size = data_size = context.GetTargetInfo().GetPointerBitWidth() / 8;
    result.complete.alignment = std::max(result.complete.alignment, context.GetTargetInfo().GetPointerAlignment());
  }
  if (base) {
    std::uint64_t offset = 0;
    if (!base_is_empty && !AlignSize(data_size, base->complete.alignment, limit, offset)) {
      return LayoutFailure{LayoutFailureKind::StructTooLarge, nullptr, &declaration};
    }
    result.base_offset = offset;
    if (base_is_empty) {
      size = std::max(size, base->complete.size);
    } else {
      if (!AddSize(offset, base->non_virtual_size, limit, data_size)) {
        return LayoutFailure{LayoutFailureKind::StructTooLarge, nullptr, &declaration};
      }
      size = std::max(size, data_size);
    }
  }

  for (const auto& field : declaration.Fields) {
    BOOST_ASSERT(field && field->type && field->type.GetTypePtr()->IsObject());
    const auto field_result = context.GetTypeLayout(*field->type.GetTypePtr());
    if (const auto* failure = std::get_if<LayoutFailure>(&field_result)) {
      return *failure;
    }
    const auto layout = std::get<TypeLayout>(field_result);
    result.complete.alignment = std::max(result.complete.alignment, layout.alignment);
    std::uint64_t offset;
    if (!AlignSize(data_size, layout.alignment, limit, offset)) {
      return LayoutFailure{LayoutFailureKind::StructTooLarge, nullptr, &declaration, field.get()};
    }
    if (offset == 0 && base_is_empty && ConflictsWithEmptyBase(context, declaration, *field->type.GetTypePtr())) {
      offset = layout.alignment;
    }
    result.field_offsets.push_back(offset);
    if (!AddSize(offset, layout.size, limit, data_size)) {
      return LayoutFailure{LayoutFailureKind::StructTooLarge, nullptr, &declaration, field.get()};
    }
    size = std::max(size, data_size);
  }

  result.non_virtual_size = size;
  result.data_size = data_size;
  if (declaration.IsEmpty()) {
    size = std::max<std::uint64_t>(size, 1);
  }
  if (!AlignSize(size, result.complete.alignment, limit, result.complete.size)) {
    return LayoutFailure{LayoutFailureKind::StructTooLarge, nullptr, &declaration};
  }
  const bool skip_tail_padding =
      declaration.triviality == TypeTriviality::Trivial && declaration.IsCXX11StandardLayout();
  if (skip_tail_padding) {
    result.data_size = result.non_virtual_size = result.complete.size;
  }
  return result;
}

}  // namespace cw::layout_detail
