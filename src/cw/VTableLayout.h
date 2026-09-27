/// \file VTableLayout.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <cstdint>
#include <unordered_map>
#include <vector>

namespace cw {

class ASTContext;
struct StructDecl;
struct VirtualFunctionDecl;

/// \brief One callable slot and its static result contract in the target vtable.
struct VTableEntry {
  const VirtualFunctionDecl* interface{};
  const VirtualFunctionDecl* final_overrider{};
  std::uint64_t return_adjustment{};
};

/// \brief Target layout of the single primary vtable, independent of LLVM objects.
struct VTableLayout {
  std::vector<VTableEntry> entries;
  std::unordered_map<const VirtualFunctionDecl*, std::size_t> function_indices;
};

namespace layout_detail {
VTableLayout ComputeVTableLayout(const ASTContext& context, const StructDecl& declaration);
}  // namespace layout_detail

}  // namespace cw
