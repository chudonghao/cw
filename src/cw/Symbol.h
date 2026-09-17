/// \file Symbol.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <memory>
#include <utility>
#include <vector>

namespace cw {

struct ConstructorDecl;
struct DestructorDecl;
struct FunctionDecl;
struct StructDecl;
struct VarDecl;

class FunctionSymbol;

/// \brief Identifies the concrete category of a symbol.
enum class SymbolKind {
  Type,
  Variable,
  Function,
};

/// \brief Base class for non-owning semantic symbol records.
class Symbol {
 public:
  virtual ~Symbol() = default;

  Symbol(const Symbol&) = delete;
  Symbol& operator=(const Symbol&) = delete;
  Symbol(Symbol&&) = delete;
  Symbol& operator=(Symbol&&) = delete;

  /// \brief Returns the concrete symbol category.
  virtual SymbolKind GetKind() const = 0;

 protected:
  Symbol() = default;
};

/// \brief Symbol for a source-level type declaration.
class TypeSymbol final : public Symbol {
  StructDecl* declaration_{};
  std::unique_ptr<FunctionSymbol> constructor_symbol_;
  ConstructorDecl* copy_constructor_{};
  ConstructorDecl* move_constructor_{};
  DestructorDecl* destructor_{};
  FunctionDecl* copy_assignment_{};
  FunctionDecl* move_assignment_{};

 public:
  /// \brief Creates a symbol referring to \p declaration.
  explicit TypeSymbol(StructDecl* declaration);
  ~TypeSymbol() override;

  SymbolKind GetKind() const override;

  /// \brief Returns the non-owning type declaration.
  StructDecl* GetDeclaration() const;

  /// \brief Appends a complete constructor declaration to its overload set.
  void AddConstructor(ConstructorDecl* declaration);

  /// \brief Returns the constructor overload set, if it is non-empty.
  FunctionSymbol* GetConstructorSymbol();
  const FunctionSymbol* GetConstructorSymbol() const;

  /// \brief Sets the unique copy-constructor declaration.
  std::pair<ConstructorDecl*, bool> SetCopyConstructor(ConstructorDecl* declaration);

  /// \brief Returns the copy-constructor declaration, if one was recorded.
  ConstructorDecl* GetCopyConstructor();
  const ConstructorDecl* GetCopyConstructor() const;

  /// \brief Sets the unique move-constructor declaration.
  std::pair<ConstructorDecl*, bool> SetMoveConstructor(ConstructorDecl* declaration);

  /// \brief Returns the move-constructor declaration, if one was recorded.
  ConstructorDecl* GetMoveConstructor();
  const ConstructorDecl* GetMoveConstructor() const;

  /// \brief Sets the unique complete destructor declaration.
  ///
  /// Returns the stored declaration and whether this call filled the slot.
  std::pair<DestructorDecl*, bool> SetDestructor(DestructorDecl* declaration);

  /// \brief Returns the complete destructor declaration, if one was recorded.
  DestructorDecl* GetDestructor();
  const DestructorDecl* GetDestructor() const;

  /// \brief Sets the unique copy-assignment declaration.
  ///
  /// Returns the stored declaration and whether this call filled the slot.
  std::pair<FunctionDecl*, bool> SetCopyAssignment(FunctionDecl* declaration);

  /// \brief Returns the copy-assignment declaration, if one was recorded.
  FunctionDecl* GetCopyAssignment();
  const FunctionDecl* GetCopyAssignment() const;

  /// \brief Sets the unique move-assignment declaration.
  ///
  /// Returns the stored declaration and whether this call filled the slot.
  std::pair<FunctionDecl*, bool> SetMoveAssignment(FunctionDecl* declaration);

  /// \brief Returns the move-assignment declaration, if one was recorded.
  FunctionDecl* GetMoveAssignment();
  const FunctionDecl* GetMoveAssignment() const;
};

/// \brief Symbol for one name declared by a variable declaration.
class VariableSymbol final : public Symbol {
  VarDecl* declaration_{};

 public:
  /// \brief Creates a symbol referring to \p declaration.
  explicit VariableSymbol(VarDecl* declaration);

  SymbolKind GetKind() const override;

  /// \brief Returns the non-owning variable declaration.
  VarDecl* GetDeclaration() const;
};

/// \brief Symbol for an overload set of function-like declarations.
class FunctionSymbol final : public Symbol {
  std::vector<FunctionDecl*> declarations_;

 public:
  /// \brief Creates an overload set containing \p declaration.
  explicit FunctionSymbol(FunctionDecl* declaration);

  SymbolKind GetKind() const override;

  /// \brief Appends \p declaration to the bound declarations.
  void AddDeclaration(FunctionDecl* declaration);

  /// \brief Returns declarations in source collection order.
  const std::vector<FunctionDecl*>& Declarations() const;
};

}  // namespace cw
