/// \file SymbolTable.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "SymbolTable.h"

#include <boost/assert.hpp>

#include "ast.h"

namespace cw {

void SymbolTable::PushScope() { scopes_.emplace_back(); }

void SymbolTable::PopScope() {
  BOOST_ASSERT(!scopes_.empty());
  scopes_.pop_back();
}

std::pair<const VarDecl*, bool> SymbolTable::InsertLocal(const VarDecl& declaration) {
  BOOST_ASSERT(!scopes_.empty() && !declaration.name.empty());
  const auto [entry, inserted] = scopes_.back().emplace(declaration.name, &declaration);
  return {entry->second, inserted};
}

const VarDecl* SymbolTable::LookupLocal(const std::string& name) const {
  for (auto scope = scopes_.rbegin(); scope != scopes_.rend(); ++scope) {
    const auto found = scope->find(name);
    if (found != scope->end()) return found->second;
  }
  return nullptr;
}

}  // namespace cw
