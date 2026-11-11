/// \file VTableLayout.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "VTableLayout.h"

#include <algorithm>
#include <utility>

#include <boost/assert.hpp>

#include "ASTContext.h"

namespace cw {
namespace {

const StructLayout& GetStructLayout(const ASTContext& context, const StructDecl& declaration) {
  return *std::get<const StructLayout*>(context.GetStructLayout(declaration));
}

// The struct whose virtual block declares a virtual function, which is also its receiver type.
const StructDecl& GetOwner(const VirtualFunctionDecl& function) {
  const auto* receiver = function.ParmVars.front()->type.GetTypePtr()->AsReferenceType();
  return *receiver->GetReferentType()->AsStructType()->GetDeclaration();
}

const StructDecl* GetReturnRecord(const Type& type) {
  const Type* object = nullptr;
  if (const auto* pointer = type.AsPointerType()) {
    object = pointer->GetPointee().GetTypePtr();
  } else if (const auto* reference = type.AsReferenceType()) {
    object = reference->GetReferentType();
  }
  return object && object->AsStructType() ? object->AsStructType()->GetDeclaration() : nullptr;
}

// Collects the offset of every `base` subobject in an object of `derived` placed at `offset`.
void CollectBaseOffsets(const ASTContext& context, const StructDecl& derived, const StructDecl& base,
                        std::uint64_t offset, std::vector<std::uint64_t>& offsets) {
  if (&derived == &base) {
    offsets.push_back(offset);
    return;
  }
  const auto& layout = GetStructLayout(context, derived);
  for (std::size_t index = 0; index < derived.base_types.size(); ++index) {
    CollectBaseOffsets(context, *derived.base_types[index]->GetDeclaration(), base, offset + layout.base_offsets[index],
                       offsets);
  }
}

// The adjustment from the result of `derived` to the result that `base` promises, as Clang's
// ComputeReturnAdjustmentBaseOffset. Sema accepts a covariant result only through a unique base.
std::int64_t GetReturnAdjustment(const ASTContext& context, const VirtualFunctionDecl& derived,
                                 const VirtualFunctionDecl& base) {
  const auto* from = derived.type.GetTypePtr()->AsFunctionType()->GetReturnType();
  const auto* to = base.type.GetTypePtr()->AsFunctionType()->GetReturnType();
  if (from == to) {
    return 0;
  }
  const StructDecl* derived_record = GetReturnRecord(*from);
  const StructDecl* base_record = GetReturnRecord(*to);
  BOOST_ASSERT(derived_record && base_record);
  std::vector<std::uint64_t> offsets;
  CollectBaseOffsets(context, *derived_record, *base_record, 0, offsets);
  BOOST_ASSERT(offsets.size() == 1);
  return static_cast<std::int64_t>(offsets.front());
}

// The final overrider of every virtual function in every base subobject of a complete struct, as
// Clang's FinalOverriders. Without virtual bases each subobject has one path to the complete
// object, and its final overrider is the last override along that path.
class FinalOverriders {
 public:
  struct Overrider {
    const VirtualFunctionDecl* function{};
    std::uint64_t offset{};  ///< Offset of the subobject whose struct declares `function`.
  };

  FinalOverriders(const ASTContext& context, const StructDecl& most_derived) : context_(context) {
    std::vector<BaseSubobject> path;
    Compute(most_derived, 0, path);
  }

  /// \brief The final overrider of `function` in the subobject at `offset` of the struct that declares it.
  Overrider Get(const VirtualFunctionDecl& function, std::uint64_t offset) const {
    return overriders_.at({&function, offset});
  }

 private:
  void Compute(const StructDecl& declaration, std::uint64_t offset, std::vector<BaseSubobject>& path) {
    path.push_back({&declaration, offset});
    if (declaration.VirtualDecl) {
      for (const auto& function : declaration.VirtualDecl->Functions) {
        Overrider overrider{function.get(), offset};
        // Sema records each override against the final overriders of the base subobjects it replaces.
        for (auto derived = std::next(path.rbegin()); derived != path.rend(); ++derived) {
          if (const auto* override_function = FindOverride(*derived->base, *overrider.function)) {
            overrider = {override_function, derived->offset};
          }
        }
        overriders_.emplace(std::make_pair(function.get(), offset), overrider);
      }
    }
    const auto& layout = GetStructLayout(context_, declaration);
    for (std::size_t index = 0; index < declaration.base_types.size(); ++index) {
      Compute(*declaration.base_types[index]->GetDeclaration(), offset + layout.base_offsets[index], path);
    }
    path.pop_back();
  }

  static const VirtualFunctionDecl* FindOverride(const StructDecl& declaration, const VirtualFunctionDecl& function) {
    if (!declaration.VirtualDecl) {
      return nullptr;
    }
    for (const auto& candidate : declaration.VirtualDecl->Functions) {
      const auto& overridden = candidate->overridden_virtual_functions;
      if (std::find(overridden.begin(), overridden.end(), &function) != overridden.end()) {
        return candidate.get();
      }
    }
    return nullptr;
  }

  const ASTContext& context_;
  std::map<std::pair<const VirtualFunctionDecl*, std::uint64_t>, Overrider> overriders_;
};

// Lays out the vtable group of one complete struct, as Clang's ItaniumVTableBuilder without
// virtual bases: the primary vtable, then the secondary vtables of the non-primary dynamic bases
// in base declaration order, each nested group in the same order.
class VTableBuilder {
 public:
  VTableBuilder(const ASTContext& context, const StructDecl& most_derived)
      : context_(context), most_derived_(most_derived), overriders_(context, most_derived) {}

  VTableLayout Build() && {
    LayoutPrimaryAndSecondaryVTables({&most_derived_, 0});
    return std::move(result_);
  }

 private:
  void LayoutPrimaryAndSecondaryVTables(BaseSubobject base) {
    const auto vtable_index = result_.vtables.size();
    auto& components = result_.vtables.emplace_back();
    components.push_back(VTableOffsetToTop{-static_cast<std::int64_t>(base.offset)});
    components.push_back(VTableTypeInfo{});
    const auto address_point = components.size();

    std::vector<const StructDecl*> primary_bases;
    method_indices_.clear();
    AddMethods(base, components, primary_bases);
    if (base.base == &most_derived_) {
      for (const auto& [function, index] : method_indices_) {
        result_.function_indices.emplace(function, index - address_point);
      }
    }

    // The struct and its chain of primary bases share this vtable pointer.
    for (const StructDecl* current = base.base; current;) {
      result_.address_points.emplace(BaseSubobject{current, base.offset},
                                     VTableAddressPoint{vtable_index, address_point});
      const auto& layout = GetStructLayout(context_, *current);
      current = layout.primary_base ? current->base_types[*layout.primary_base]->GetDeclaration() : nullptr;
    }
    LayoutSecondaryVTables(base);
  }

  // Adds the entries of a primary base chain from the most basic struct outward. A function that
  // overrides one in the chain reuses its entry unless the result needs an adjustment.
  void AddMethods(BaseSubobject base, std::vector<VTableComponent>& components,
                  std::vector<const StructDecl*>& primary_bases) {
    const StructDecl& declaration = *base.base;
    const auto& layout = GetStructLayout(context_, declaration);
    if (layout.primary_base) {
      const StructDecl& primary = *declaration.base_types[*layout.primary_base]->GetDeclaration();
      BOOST_ASSERT(layout.base_offsets[*layout.primary_base] == 0);
      AddMethods({&primary, base.offset}, components, primary_bases);
      primary_bases.push_back(&primary);
    }
    if (!declaration.VirtualDecl) {
      return;
    }
    std::vector<const VirtualFunctionDecl*> new_functions;
    for (const auto& function_owner : declaration.VirtualDecl->Functions) {
      const VirtualFunctionDecl& function = *function_owner;
      if (const auto* overridden = FindNearestOverriddenFunction(function, primary_bases);
          overridden && GetReturnAdjustment(context_, function, *overridden) == 0) {
        const auto index = method_indices_.at(overridden);
        method_indices_.erase(overridden);
        method_indices_.emplace(&function, index);
        continue;
      }
      new_functions.push_back(&function);
    }
    for (const VirtualFunctionDecl* function : new_functions) {
      const auto overrider = overriders_.Get(*function, base.offset);
      method_indices_.emplace(function, components.size());
      // An abstract entry is never called through, so it needs no adjustment.
      const bool is_abstract = overrider.function->is_abstract;
      components.push_back(VTableEntry{
          function, overrider.function,
          is_abstract ? 0 : static_cast<std::int64_t>(overrider.offset) - static_cast<std::int64_t>(base.offset),
          is_abstract ? 0 : GetReturnAdjustment(context_, *overrider.function, *function)});
    }
  }

  void LayoutSecondaryVTables(BaseSubobject base) {
    const StructDecl& declaration = *base.base;
    const auto& layout = GetStructLayout(context_, declaration);
    for (std::size_t index = 0; index < declaration.base_types.size(); ++index) {
      const StructDecl& base_declaration = *declaration.base_types[index]->GetDeclaration();
      if (!base_declaration.IsPolymorphic()) {
        continue;
      }
      const BaseSubobject subobject{&base_declaration, base.offset + layout.base_offsets[index]};
      // A primary base shares the vtable of its struct, but its own bases may still need one.
      if (layout.primary_base == index) {
        LayoutSecondaryVTables(subobject);
      } else {
        LayoutPrimaryAndSecondaryVTables(subobject);
      }
    }
  }

  // The function nearest to `function` that it overrides, directly or not, in the primary base
  // chain, as Clang's FindNearestOverriddenMethod.
  static const VirtualFunctionDecl* FindNearestOverriddenFunction(const VirtualFunctionDecl& function,
                                                                  const std::vector<const StructDecl*>& primary_bases) {
    std::vector<const VirtualFunctionDecl*> overridden;
    const auto collect = [&](const auto& self, const VirtualFunctionDecl& current) -> void {
      for (const VirtualFunctionDecl* base : current.overridden_virtual_functions) {
        if (std::find(overridden.begin(), overridden.end(), base) == overridden.end()) {
          overridden.push_back(base);
          self(self, *base);
        }
      }
    };
    collect(collect, function);
    for (auto primary = primary_bases.rbegin(); primary != primary_bases.rend(); ++primary) {
      for (const VirtualFunctionDecl* candidate : overridden) {
        if (&GetOwner(*candidate) == *primary) {
          return candidate;
        }
      }
    }
    return nullptr;
  }

  const ASTContext& context_;
  const StructDecl& most_derived_;
  FinalOverriders overriders_;
  VTableLayout result_;
  // The entry of each function of the primary base chain being laid out, as Clang's MethodInfoMap.
  std::unordered_map<const VirtualFunctionDecl*, std::size_t> method_indices_;
};

}  // namespace

VTableLayout layout_detail::ComputeVTableLayout(const ASTContext& context, const StructDecl& declaration) {
  BOOST_ASSERT(declaration.IsPolymorphic() && !declaration.ContainsErrors());
  return VTableBuilder(context, declaration).Build();
}

}  // namespace cw
