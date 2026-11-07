/// \file NameLookup.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <optional>
#include <string>
#include <unordered_map>
#include <utility>
#include <variant>
#include <vector>

#include "NameSyntax.h"

namespace cw {

class NamespaceContext;
struct NamedDecl;
struct StructDecl;
struct VarDecl;
struct FunctionDecl;

/// A transient local scope stack. Declarations remain owned by the AST.
class LocalScopeStack {
  using Scope = std::unordered_map<std::string, const VarDecl*>;
  std::vector<Scope> scopes_;

 public:
  void PushScope();
  void PopScope();
  /// Inserts in the innermost scope, retaining the first declaration on conflict.
  std::pair<const VarDecl*, bool> InsertLocal(const VarDecl& declaration);
  const VarDecl* LookupLocal(const std::string& name) const;
};

enum class LookupFailure { None, NotFound, NotNamespace, MissingMember, Unbound };

/// A synchronous query borrows its scope and snapshots the global visibility bound.
struct LookupContext {
  const NamespaceContext* from;
  const LocalScopeStack* locals{};
  std::optional<std::size_t> visible_global_groups{};
};

/// Owns its function reference sequence, never the referenced AST declarations.
struct LookupResult {
  using Functions = std::vector<FunctionDecl*>;
  using Entity = std::variant<std::monostate, StructDecl*, const VarDecl*, Functions, const NamespaceContext*>;
  Entity entity{};
  LookupFailure failure{LookupFailure::NotFound};
  std::size_t segment{};                    ///< Failed segment, or the final segment on success.
  const NamespaceContext* context{};        ///< Namespace searched, when applicable.
  const NamedDecl* blocking_declaration{};  ///< Source of Unbound or NotNamespace.

  explicit operator bool() const { return failure == LookupFailure::None; }
  /// Successful entities only; failures retain their blocking entity and diagnostic facts above.
  StructDecl* GetType() const;
  const VarDecl* GetVariable() const;
  const Functions* GetFunctions() const;
  const NamespaceContext* GetNamespace() const;
};

/// Interfaces have no local scopes; an unbound name blocks lookup in outer namespaces.
LookupResult LookupInterfaceName(const NameSyntax& name, const NamespaceContext& from);
/// Execution lookup ignores placeholders and applies the global bound at every segment.
LookupResult LookupName(const NameSyntax& name, const LookupContext& context);
/// Binding checks ignore parent scopes, placeholders and visibility filtering.
LookupResult LookupDirectName(const std::string& name, const NamespaceContext& context);
}  // namespace cw
