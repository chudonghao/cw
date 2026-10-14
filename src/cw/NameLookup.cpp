/// \file NameLookup.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "NameLookup.h"

#include <boost/assert.hpp>

#include "NamespaceContext.h"
#include "SymbolTable.h"
#include "ast.h"

namespace cw {

StructDecl* LookupResult::GetType() const {
  if (!*this) return nullptr;
  const auto* value = std::get_if<StructDecl*>(&entity);
  return value ? *value : nullptr;
}

const VarDecl* LookupResult::GetVariable() const {
  if (!*this) return nullptr;
  const auto* value = std::get_if<const VarDecl*>(&entity);
  return value ? *value : nullptr;
}

const LookupResult::Functions* LookupResult::GetFunctions() const {
  return *this ? std::get_if<Functions>(&entity) : nullptr;
}

const NamespaceContext* LookupResult::GetNamespace() const {
  if (!*this) return nullptr;
  const auto* value = std::get_if<const NamespaceContext*>(&entity);
  return value ? *value : nullptr;
}

namespace {

LookupResult FindMember(const std::string& name, const NamespaceContext& from, std::size_t segment,
                        bool include_unbound, std::optional<std::size_t> visible_global_groups) {
  LookupResult result{{}, LookupFailure::NotFound, segment, &from};
  const auto* member = from.FindMember(name);
  if (!member) return result;
  if (const auto* unbound = std::get_if<UnboundName>(member)) {
    if (include_unbound) {
      result.failure = LookupFailure::Unbound;
      result.blocking_declaration = unbound->declaration;
    }
    return result;
  }
  if (const auto* variable = std::get_if<GlobalVariableBinding>(member)) {
    if (visible_global_groups && variable->group_index >= *visible_global_groups) return result;
    result.entity = variable->declaration;
  } else if (const auto* type = std::get_if<StructDecl*>(member)) {
    result.entity = *type;
  } else if (const auto* functions = std::get_if<NamespaceContext::Functions>(member)) {
    result.entity = *functions;
  } else {
    result.entity = std::get<const NamespaceContext*>(*member);
  }
  result.failure = LookupFailure::None;
  return result;
}

LookupResult Lookup(const NameSyntax& name, const LookupContext& context, bool include_unbound) {
  BOOST_ASSERT(context.from);
  if (name.empty()) return {};
  LookupResult result;
  const auto& first = name.segments.front().spelling;
  if (!name.absolute && context.locals) {
    if (const auto* variable = context.locals->LookupLocal(first)) result = {variable, LookupFailure::None};
  }
  if (!result) {
    const auto* from = context.from;
    if (name.absolute) {
      while (from->GetParent()) from = from->GetParent();
    }
    for (; from; from = from->GetParent()) {
      result = FindMember(first, *from, 0, include_unbound, context.visible_global_groups);
      if (result.failure != LookupFailure::NotFound || name.absolute) break;
    }
  }
  for (std::size_t index = 1; result && index < name.segments.size(); ++index) {
    const auto* scope = result.GetNamespace();
    if (!scope) {
      if (const auto* type = result.GetType()) result.blocking_declaration = type;
      if (const auto* variable = result.GetVariable()) result.blocking_declaration = variable;
      if (const auto* functions = result.GetFunctions()) {
        BOOST_ASSERT(!functions->empty());
        result.blocking_declaration = functions->front();
      }
      result.failure = LookupFailure::NotNamespace;
      return result;
    }
    result = FindMember(name.segments[index].spelling, *scope, index, include_unbound, context.visible_global_groups);
    if (result.failure == LookupFailure::NotFound) result.failure = LookupFailure::MissingMember;
  }
  return result;
}

}  // namespace

LookupResult LookupInterfaceName(const NameSyntax& name, const NamespaceContext& from) {
  return Lookup(name, LookupContext{&from}, true);
}

LookupResult LookupName(const NameSyntax& name, const LookupContext& context) { return Lookup(name, context, false); }

LookupResult LookupDirectName(const std::string& name, const NamespaceContext& context) {
  return FindMember(name, context, 0, false, std::nullopt);
}

}  // namespace cw
