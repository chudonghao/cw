/// \file SymbolTable.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <memory>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

#include "Symbol.h"

namespace cw {

/// \brief Owns symbols and performs lexical scope lookup.
class SymbolTable {
  using Scope = std::unordered_map<std::string, std::unique_ptr<Symbol>>;

  std::vector<Scope> scopes_;

 public:
  /// \brief Creates a symbol table with one root scope.
  SymbolTable();
  ~SymbolTable() = default;

  SymbolTable(const SymbolTable&) = delete;
  SymbolTable& operator=(const SymbolTable&) = delete;
  SymbolTable(SymbolTable&&) = default;
  SymbolTable& operator=(SymbolTable&&) = default;

  /// \brief Pushes a new empty innermost scope.
  void PushScope();

  /// \brief Removes the innermost scope, which must not be the root.
  void PopScope();

  /// \brief Inserts \p symbol under \p name in the current scope.
  ///
  /// Returns the stored symbol and whether insertion succeeded. On a duplicate,
  /// the existing symbol is returned and the supplied symbol is destroyed.
  std::pair<Symbol*, bool> Insert(std::string name, std::unique_ptr<Symbol> symbol);

  /// \brief Looks up \p name only in the current scope.
  Symbol* LookupCurrent(const std::string& name);
  const Symbol* LookupCurrent(const std::string& name) const;

  /// \brief Looks up \p name from the current scope toward the root.
  Symbol* Lookup(const std::string& name);
  const Symbol* Lookup(const std::string& name) const;

  /// \brief Looks up \p name only in the root scope.
  Symbol* LookupRoot(const std::string& name);
  const Symbol* LookupRoot(const std::string& name) const;
};

}  // namespace cw
