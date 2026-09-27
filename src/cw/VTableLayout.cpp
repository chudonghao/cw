/// \file VTableLayout.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "VTableLayout.h"

#include <boost/assert.hpp>

#include "ASTContext.h"

namespace cw {
namespace {

const StructDecl* GetReturnRecord(const Type& type) {
  const Type* object = nullptr;
  if (const auto* pointer = type.AsPointerType()) {
    object = pointer->GetPointee().GetTypePtr();
  } else if (const auto* reference = type.AsReferenceType()) {
    object = reference->GetReferentType();
  }
  return object && object->AsStructType() ? object->AsStructType()->GetDeclaration() : nullptr;
}

std::uint64_t GetReturnAdjustment(const ASTContext& context, const VirtualFunctionDecl& implementation,
                                  const VirtualFunctionDecl& interface) {
  const auto* from = implementation.type.GetTypePtr()->AsFunctionType()->GetReturnType();
  const auto* to = interface.type.GetTypePtr()->AsFunctionType()->GetReturnType();
  if (from == to) {
    return 0;
  }
  const StructDecl* derived = GetReturnRecord(*from);
  const StructDecl* base = GetReturnRecord(*to);
  BOOST_ASSERT(derived && base);
  std::uint64_t offset = 0;
  while (derived != base) {
    const auto& layout = *std::get<const StructLayout*>(context.GetStructLayout(*derived));
    BOOST_ASSERT(derived->base_type && layout.base_offset);
    offset += *layout.base_offset;
    derived = derived->base_type->GetDeclaration();
  }
  return offset;
}

}  // namespace

VTableLayout layout_detail::ComputeVTableLayout(const ASTContext& context, const StructDecl& declaration) {
  BOOST_ASSERT(declaration.IsPolymorphic() && !declaration.ContainsErrors());
  VTableLayout result;
  if (declaration.base_type && declaration.base_type->GetDeclaration()->IsPolymorphic()) {
    const auto& layout = *std::get<const StructLayout*>(context.GetStructLayout(declaration));
    BOOST_ASSERT(layout.base_offset == 0);
    result = context.GetVTableLayout(*declaration.base_type->GetDeclaration());
  }
  if (!declaration.VirtualDecl) {
    return result;
  }
  for (const auto& function : declaration.VirtualDecl->Functions) {
    const auto* overridden = function->overridden_virtual_function;
    if (overridden) {
      const auto inherited_index = result.function_indices.at(overridden);
      // Preserve every inherited static result contract, including older covariant slots.
      for (auto& entry : result.entries) {
        if (entry.final_overrider == overridden) {
          entry.final_overrider = function.get();
          entry.return_adjustment = GetReturnAdjustment(context, *function, *entry.interface);
        }
      }
      if (result.entries[inherited_index].return_adjustment == 0) {
        result.function_indices.emplace(function.get(), inherited_index);
        continue;
      }
      // An adjusted base result cannot serve calls expecting the derived result.
      // Retain that base slot and append the unadjusted entry, as in the target ABI.
    }
    result.function_indices.emplace(function.get(), result.entries.size());
    result.entries.push_back({function.get(), function.get(), 0});
  }
  return result;
}

}  // namespace cw
