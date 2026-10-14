/// \file NamespaceContext.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "NamespaceContext.h"

#include <boost/assert.hpp>

#include "ast.h"

namespace cw {

const NamespaceContext::Member* NamespaceContext::FindMember(const std::string& name) const {
  const auto found = members_.find(name);
  return found == members_.end() ? nullptr : &found->second;
}

void NamespaceContext::ReserveName(const NamedDecl& declaration) {
  if (!declaration.name.empty()) members_.emplace(declaration.name, UnboundName{&declaration});
}

bool NamespaceContext::Bind(const std::string& name, Member member) {
  BOOST_ASSERT(!name.empty());
  const auto found = members_.find(name);
  if (found == members_.end()) {
    members_.emplace(name, std::move(member));
    return true;
  }
  if (!std::holds_alternative<UnboundName>(found->second)) return false;
  found->second = std::move(member);
  return true;
}

bool NamespaceContext::BindType(StructDecl& declaration) { return Bind(declaration.name, &declaration); }

bool NamespaceContext::BindGlobal(const VarDecl& declaration, std::size_t group_index) {
  return Bind(declaration.name, GlobalVariableBinding{&declaration, group_index});
}

bool NamespaceContext::AddFunction(FunctionDecl& declaration) {
  const auto found = members_.find(declaration.name);
  if (found != members_.end()) {
    if (auto* functions = std::get_if<Functions>(&found->second)) {
      functions->push_back(&declaration);
      return true;
    }
  }
  return Bind(declaration.name, Functions{&declaration});
}

}  // namespace cw
