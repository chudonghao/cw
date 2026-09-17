/// \file SymbolTable.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "SymbolTable.h"

#include <boost/assert.hpp>

namespace cw {

SymbolTable::SymbolTable() : scopes_(1) {}

void SymbolTable::PushScope() { scopes_.emplace_back(); }

void SymbolTable::PopScope() {
  BOOST_ASSERT(scopes_.size() > 1);
  scopes_.pop_back();
}

std::pair<Symbol*, bool> SymbolTable::Insert(std::string name, std::unique_ptr<Symbol> symbol) {
  BOOST_ASSERT(!name.empty());
  BOOST_ASSERT(symbol);

  const auto existing = scopes_.back().find(name);
  if (existing != scopes_.back().end()) {
    return {existing->second.get(), false};
  }

  Symbol* result = symbol.get();
  scopes_.back().emplace(std::move(name), std::move(symbol));
  return {result, true};
}

Symbol* SymbolTable::LookupCurrent(const std::string& name) {
  const auto it = scopes_.back().find(name);
  return it == scopes_.back().end() ? nullptr : it->second.get();
}

const Symbol* SymbolTable::LookupCurrent(const std::string& name) const {
  const auto it = scopes_.back().find(name);
  return it == scopes_.back().end() ? nullptr : it->second.get();
}

Symbol* SymbolTable::Lookup(const std::string& name) {
  for (auto it = scopes_.rbegin(); it != scopes_.rend(); ++it) {
    const auto symbol = it->find(name);
    if (symbol != it->end()) {
      return symbol->second.get();
    }
  }
  return nullptr;
}

const Symbol* SymbolTable::Lookup(const std::string& name) const {
  for (auto it = scopes_.rbegin(); it != scopes_.rend(); ++it) {
    const auto symbol = it->find(name);
    if (symbol != it->end()) {
      return symbol->second.get();
    }
  }
  return nullptr;
}

Symbol* SymbolTable::LookupRoot(const std::string& name) {
  const auto it = scopes_.front().find(name);
  return it == scopes_.front().end() ? nullptr : it->second.get();
}

const Symbol* SymbolTable::LookupRoot(const std::string& name) const {
  const auto it = scopes_.front().find(name);
  return it == scopes_.front().end() ? nullptr : it->second.get();
}

}  // namespace cw
