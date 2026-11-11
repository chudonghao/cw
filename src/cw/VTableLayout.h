/// \file VTableLayout.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <cstdint>
#include <functional>
#include <map>
#include <unordered_map>
#include <variant>
#include <vector>

namespace cw {

class ASTContext;
struct StructDecl;
struct VirtualFunctionDecl;

/// \brief A base subobject of a complete object, identified by its struct and its offset in that object.
struct BaseSubobject {
  const StructDecl* base{};
  std::uint64_t offset{};

  friend bool operator<(const BaseSubobject& left, const BaseSubobject& right) {
    if (left.offset != right.offset) {
      return left.offset < right.offset;
    }
    return std::less<const StructDecl*>{}(left.base, right.base);
  }
};

/// \brief The offset from the subobject that holds a vtable pointer to the start of the complete object.
struct VTableOffsetToTop {
  std::int64_t offset{};
};

/// \brief The type information slot, which is null because no RTTI is generated.
struct VTableTypeInfo {};

/// \brief One callable entry and the static result contract of the interface that introduced it.
struct VTableEntry {
  const VirtualFunctionDecl* interface{};
  const VirtualFunctionDecl* final_overrider{};
  std::int64_t this_adjustment{};    ///< Added to the receiver address before the final overrider runs.
  std::int64_t return_adjustment{};  ///< Added to the object address in the final overrider's result.
};

using VTableComponent = std::variant<VTableOffsetToTop, VTableTypeInfo, VTableEntry>;

/// \brief The component a vtable pointer points to: the first entry of one vtable in a group.
struct VTableAddressPoint {
  std::size_t vtable_index{};
  std::size_t component_index{};
};

/// \brief Target layout of the vtable group of a dynamic struct, independent of LLVM objects.
///
/// The model follows Clang's ItaniumVTableBuilder. Final overriders are taken from the complete
/// struct for every base subobject, so a base's vtable is laid out again inside each derived group.
struct VTableLayout {
  /// The primary vtable first, then one secondary vtable for each base subobject with its own vtable pointer.
  std::vector<std::vector<VTableComponent>> vtables;
  /// Every dynamic base subobject; a primary base shares the address point of the struct that contains it.
  std::map<BaseSubobject, VTableAddressPoint> address_points;
  /// Entry index in the primary vtable, relative to its address point.
  std::unordered_map<const VirtualFunctionDecl*, std::size_t> function_indices;
};

namespace layout_detail {
VTableLayout ComputeVTableLayout(const ASTContext& context, const StructDecl& declaration);
}  // namespace layout_detail

}  // namespace cw
