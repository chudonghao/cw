/// \file TypeLayout.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "TypeLayout.h"

#include <algorithm>
#include <map>
#include <vector>

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

// The size of the largest empty struct subobject of a struct, as in Clang's
// EmptySubobjectMap::ComputeEmptySubobjectSizes. Arrays contribute their element type.
std::uint64_t LargestEmptySubobject(const ASTContext& context, const StructDecl& declaration) {
  std::uint64_t largest = 0;
  const auto include = [&](const Type& type) {
    const Type* element = &type;
    while (const auto* array = element->AsArrayType()) {
      element = array->GetElementType().GetTypePtr();
    }
    if (const auto* structure = element->AsStructType()) {
      const StructDecl& member = *structure->GetDeclaration();
      largest = std::max(largest, member.IsEmpty() ? std::get<TypeLayout>(context.GetTypeLayout(*structure)).size
                                                   : LargestEmptySubobject(context, member));
    }
  };
  for (const StructType* base : declaration.base_types) {
    include(*base);
  }
  for (const auto& field : declaration.Fields) {
    include(*field->type.GetTypePtr());
  }
  return largest;
}

// The empty struct subobjects already placed in the struct under layout, by offset. Two
// subobjects of the same empty type cannot share an address. This follows Clang's
// EmptySubobjectMap: only an empty base can be placed beyond the data size, so other placements
// record their empty subobjects only below the size of the largest empty subobject, and no
// offset beyond the largest recorded one can conflict.
class EmptySubobjectMap {
 public:
  EmptySubobjectMap(const ASTContext& context, const StructDecl& declaration)
      : context_(context), limit_(LargestEmptySubobject(context, declaration)) {}

  /// \brief Whether an object of `type` at `offset` keeps every empty subobject at a distinct address.
  bool CanPlace(const Type& type, std::uint64_t offset) const {
    return VisitEmptySubobjects(
        type, offset, [&](std::uint64_t at) { return at <= max_offset_; },
        [&](const StructDecl& empty, std::uint64_t at) {
          const auto it = placed_.find(at);
          return it == placed_.end() || std::find(it->second.begin(), it->second.end(), &empty) == it->second.end();
        });
  }

  /// \brief Records the empty subobjects of a base or field of `type` placed at `offset`.
  void Add(const Type& type, std::uint64_t offset, bool is_empty_base) {
    VisitEmptySubobjects(
        type, offset, [&](std::uint64_t at) { return is_empty_base || at < limit_; },
        [&](const StructDecl& empty, std::uint64_t at) {
          auto& types = placed_[at];
          if (std::find(types.begin(), types.end(), &empty) == types.end()) {
            types.push_back(&empty);
          }
          max_offset_ = std::max(max_offset_, at);
          return true;
        });
  }

 private:
  // Calls `visit` for each empty struct subobject of an object of `type` at `offset` until it
  // returns false. Subobjects at offsets that `within` rejects are skipped; offsets only grow
  // toward nested subobjects and later array elements.
  template <class Within, class Visit>
  bool VisitEmptySubobjects(const Type& type, std::uint64_t offset, const Within& within, const Visit& visit) const {
    if (!within(offset)) {
      return true;
    }
    if (const auto* array = type.AsArrayType()) {
      const Type& element = *array->GetElementType().GetTypePtr();
      const auto size = std::get<TypeLayout>(context_.GetTypeLayout(element)).size;
      // A zero-size element cannot contain an empty struct, whose size is at least one.
      for (std::uint64_t index = 0; size != 0 && index < array->GetLength() && within(offset + index * size); ++index) {
        if (!VisitEmptySubobjects(element, offset + index * size, within, visit)) {
          return false;
        }
      }
      return true;
    }
    const auto* structure = type.AsStructType();
    if (!structure) {
      return true;
    }
    const StructDecl& declaration = *structure->GetDeclaration();
    if (declaration.IsEmpty() && !visit(declaration, offset)) {
      return false;
    }
    const auto& layout = *std::get<const StructLayout*>(context_.GetStructLayout(declaration));
    for (std::size_t index = 0; index < declaration.base_types.size(); ++index) {
      if (!VisitEmptySubobjects(*declaration.base_types[index], offset + layout.base_offsets[index], within, visit)) {
        return false;
      }
    }
    for (std::size_t index = 0; index < declaration.Fields.size(); ++index) {
      if (!VisitEmptySubobjects(*declaration.Fields[index]->type.GetTypePtr(), offset + layout.field_offsets[index],
                                within, visit)) {
        return false;
      }
    }
    return true;
  }

  const ASTContext& context_;
  std::uint64_t limit_;
  std::uint64_t max_offset_{};
  std::map<std::uint64_t, std::vector<const StructDecl*>> placed_;
};

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
  const auto too_large = [&](const FieldDecl* field = nullptr) {
    return LayoutFailure{LayoutFailureKind::StructTooLarge, nullptr, &declaration, field};
  };
  std::vector<const StructLayout*> bases;
  for (const StructType* base_type : declaration.base_types) {
    BOOST_ASSERT(base_type);
    const auto layout = context.GetStructLayout(*base_type->GetDeclaration());
    if (const auto* failure = std::get_if<LayoutFailure>(&layout)) {
      return *failure;
    }
    bases.push_back(std::get<const StructLayout*>(layout));
  }

  StructLayout result;
  result.base_offsets.resize(bases.size());
  std::uint64_t size = 0;
  std::uint64_t data_size = 0;
  EmptySubobjectMap empty_subobjects(context, declaration);

  // Places a direct base as Clang's ItaniumRecordLayoutBuilder::LayoutBase does: an empty base
  // first tries offset zero, then every base moves past empty subobjects of the same type.
  const auto place_base = [&](std::size_t index) {
    const StructType& base_type = *declaration.base_types[index];
    const bool is_empty = base_type.GetDeclaration()->IsEmpty();
    const StructLayout& base = *bases[index];
    result.complete.alignment = std::max(result.complete.alignment, base.complete.alignment);
    std::uint64_t offset = 0;
    if (!is_empty || !empty_subobjects.CanPlace(base_type, 0)) {
      if (!AlignSize(data_size, base.complete.alignment, limit, offset)) {
        return false;
      }
      while (!empty_subobjects.CanPlace(base_type, offset)) {
        if (!AddSize(offset, base.complete.alignment, limit, offset)) {
          return false;
        }
      }
    }
    result.base_offsets[index] = offset;
    empty_subobjects.Add(base_type, offset, is_empty);
    std::uint64_t end;
    if (!AddSize(offset, is_empty ? base.complete.size : base.non_virtual_size, limit, end)) {
      return false;
    }
    if (!is_empty) {
      data_size = end;
    }
    size = std::max(size, end);
    return true;
  };

  // The first polymorphic base is primary and shares its vptr at offset zero. A polymorphic
  // struct without one places its own vptr there, before every nonempty base.
  const auto primary = std::find_if(declaration.base_types.begin(), declaration.base_types.end(),
                                    [](const StructType* base) { return base->GetDeclaration()->IsPolymorphic(); });
  const auto primary_index = static_cast<std::size_t>(primary - declaration.base_types.begin());
  if (primary != declaration.base_types.end()) {
    result.primary_base = primary_index;
    if (!place_base(primary_index)) {
      return too_large();
    }
  } else if (declaration.IsPolymorphic()) {
    size = data_size = context.GetTargetInfo().GetPointerBitWidth() / 8;
    result.complete.alignment = std::max(result.complete.alignment, context.GetTargetInfo().GetPointerAlignment());
  }
  for (std::size_t index = 0; index < bases.size(); ++index) {
    if (index != primary_index && !place_base(index)) {
      return too_large();
    }
  }

  for (const auto& field : declaration.Fields) {
    BOOST_ASSERT(field && field->type && field->type.GetTypePtr()->IsObject());
    const Type& field_type = *field->type.GetTypePtr();
    const auto field_result = context.GetTypeLayout(field_type);
    if (const auto* failure = std::get_if<LayoutFailure>(&field_result)) {
      return *failure;
    }
    const auto layout = std::get<TypeLayout>(field_result);
    result.complete.alignment = std::max(result.complete.alignment, layout.alignment);
    std::uint64_t offset;
    if (!AlignSize(data_size, layout.alignment, limit, offset)) {
      return too_large(field.get());
    }
    while (!empty_subobjects.CanPlace(field_type, offset)) {
      if (!AddSize(offset, layout.alignment, limit, offset)) {
        return too_large(field.get());
      }
    }
    empty_subobjects.Add(field_type, offset, false);
    result.field_offsets.push_back(offset);
    if (!AddSize(offset, layout.size, limit, data_size)) {
      return too_large(field.get());
    }
    size = std::max(size, data_size);
  }

  result.non_virtual_size = size;
  result.data_size = data_size;
  if (declaration.IsEmpty()) {
    size = std::max<std::uint64_t>(size, 1);
  }
  if (!AlignSize(size, result.complete.alignment, limit, result.complete.size)) {
    return too_large();
  }
  const bool skip_tail_padding =
      declaration.triviality == TypeTriviality::Trivial && declaration.IsCXX11StandardLayout();
  if (skip_tail_padding) {
    result.data_size = result.non_virtual_size = result.complete.size;
  }
  return result;
}

}  // namespace cw::layout_detail
