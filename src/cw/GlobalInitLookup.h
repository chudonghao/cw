/// \file GlobalInitLookup.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>

#include <boost/assert.hpp>

#include "NameLookup.h"
#include "SymbolTable.h"

namespace cw {

/// Only lives during global initialization analysis; namespace bindings live in the AST.
class GlobalInitLookup {
  SymbolTable locals_;
  std::size_t visible_group_count_{};

 public:
  SymbolTable& GetLocals() { return locals_; }
  const SymbolTable& GetLocals() const { return locals_; }
  void MakeGroupVisible(std::size_t group_index) {
    BOOST_ASSERT(group_index == visible_group_count_);
    visible_group_count_ = group_index + 1;
  }
  LookupContext GetContext(const NamespaceContext& from) const { return {&from, &locals_, visible_group_count_}; }
};
}  // namespace cw
