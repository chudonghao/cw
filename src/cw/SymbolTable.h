/// \file SymbolTable.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

namespace cw {

struct VarDecl;

/// A transient local scope stack. Declarations remain owned by the AST.
class SymbolTable {
  using Scope = std::unordered_map<std::string, const VarDecl*>;
  std::vector<Scope> scopes_;

 public:
  void PushScope();
  void PopScope();
  /// Inserts in the innermost scope, retaining the first declaration on conflict.
  std::pair<const VarDecl*, bool> InsertLocal(const VarDecl& declaration);
  const VarDecl* LookupLocal(const std::string& name) const;
};
}  // namespace cw
