/// \file NamespaceContext.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <memory>
#include <string>
#include <unordered_map>
#include <utility>
#include <variant>
#include <vector>

namespace cw {

class ASTContext;
struct NamespaceDecl;
struct NamedDecl;
struct StructDecl;
struct FunctionDecl;
struct VarDecl;

struct UnboundName {
  const NamedDecl* declaration;
};

struct GlobalVariableBinding {
  const VarDecl* declaration;
  std::size_t group_index;
};

/// Persistent namespace identity and member bindings, owned by ASTContext.
class NamespaceContext {
  friend class ASTContext;

 public:
  using Functions = std::vector<FunctionDecl*>;
  using Member = std::variant<UnboundName, StructDecl*, GlobalVariableBinding, Functions, const NamespaceContext*>;

 private:
  std::string name_;
  const NamespaceContext* parent_;
  std::unordered_map<std::string, std::unique_ptr<NamespaceContext>> children_;
  std::vector<const NamespaceDecl*> declarations_;
  std::unordered_map<std::string, Member> members_;

  NamespaceContext(std::string name, const NamespaceContext* parent) : name_(std::move(name)), parent_(parent) {}

 public:
  const std::string& GetName() const { return name_; }
  const NamespaceContext* GetParent() const { return parent_; }
  const std::vector<const NamespaceDecl*>& GetDeclarations() const { return declarations_; }
  bool IsRoot() const { return parent_ == nullptr; }
  /// The unfiltered name entry, including a possible interface placeholder.
  const Member* FindMember(const std::string& name) const;
  void ReserveName(const NamedDecl& declaration);
  bool BindType(StructDecl& declaration);
  bool BindGlobal(const VarDecl& declaration, std::size_t group_index);
  /// Appends to a function group or replaces a placeholder with a new group.
  bool AddFunction(FunctionDecl& declaration);
  std::string QualifiedName() const {
    if (!parent_ || parent_->IsRoot()) return name_;
    return parent_->QualifiedName() + "::" + name_;
  }

 private:
  bool Bind(const std::string& name, Member member);
};

}  // namespace cw
