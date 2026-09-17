/// \file Symbol.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "Symbol.h"

#include <boost/assert.hpp>

#include "ast.h"

namespace cw {

TypeSymbol::TypeSymbol(StructDecl* declaration) : declaration_(declaration) { BOOST_ASSERT(declaration_); }

TypeSymbol::~TypeSymbol() = default;

SymbolKind TypeSymbol::GetKind() const { return SymbolKind::Type; }

StructDecl* TypeSymbol::GetDeclaration() const { return declaration_; }

void TypeSymbol::AddConstructor(ConstructorDecl* declaration) {
  BOOST_ASSERT(declaration);
  BOOST_ASSERT(declaration->target_type);
  BOOST_ASSERT(declaration->target_type->GetDeclaration() == declaration_);
  if (!constructor_symbol_) {
    constructor_symbol_ = std::make_unique<FunctionSymbol>(declaration);
    return;
  }
  constructor_symbol_->AddDeclaration(declaration);
}

FunctionSymbol* TypeSymbol::GetConstructorSymbol() { return constructor_symbol_.get(); }

const FunctionSymbol* TypeSymbol::GetConstructorSymbol() const { return constructor_symbol_.get(); }

std::pair<ConstructorDecl*, bool> TypeSymbol::SetCopyConstructor(ConstructorDecl* declaration) {
  BOOST_ASSERT(declaration);
  BOOST_ASSERT(declaration->target_type);
  BOOST_ASSERT(declaration->target_type->GetDeclaration() == declaration_);
  if (copy_constructor_) {
    return {copy_constructor_, false};
  }
  copy_constructor_ = declaration;
  return {copy_constructor_, true};
}

ConstructorDecl* TypeSymbol::GetCopyConstructor() { return copy_constructor_; }

const ConstructorDecl* TypeSymbol::GetCopyConstructor() const { return copy_constructor_; }

std::pair<ConstructorDecl*, bool> TypeSymbol::SetMoveConstructor(ConstructorDecl* declaration) {
  BOOST_ASSERT(declaration);
  BOOST_ASSERT(declaration->target_type);
  BOOST_ASSERT(declaration->target_type->GetDeclaration() == declaration_);
  if (move_constructor_) {
    return {move_constructor_, false};
  }
  move_constructor_ = declaration;
  return {move_constructor_, true};
}

ConstructorDecl* TypeSymbol::GetMoveConstructor() { return move_constructor_; }

const ConstructorDecl* TypeSymbol::GetMoveConstructor() const { return move_constructor_; }

std::pair<DestructorDecl*, bool> TypeSymbol::SetDestructor(DestructorDecl* declaration) {
  BOOST_ASSERT(declaration);
  BOOST_ASSERT(declaration->target_type);
  BOOST_ASSERT(declaration->target_type->GetDeclaration() == declaration_);
  if (destructor_) {
    return {destructor_, false};
  }
  destructor_ = declaration;
  return {destructor_, true};
}

DestructorDecl* TypeSymbol::GetDestructor() { return destructor_; }

const DestructorDecl* TypeSymbol::GetDestructor() const { return destructor_; }

std::pair<FunctionDecl*, bool> TypeSymbol::SetCopyAssignment(FunctionDecl* declaration) {
  BOOST_ASSERT(declaration);
  if (copy_assignment_) {
    return {copy_assignment_, false};
  }
  copy_assignment_ = declaration;
  return {copy_assignment_, true};
}

FunctionDecl* TypeSymbol::GetCopyAssignment() { return copy_assignment_; }

const FunctionDecl* TypeSymbol::GetCopyAssignment() const { return copy_assignment_; }

std::pair<FunctionDecl*, bool> TypeSymbol::SetMoveAssignment(FunctionDecl* declaration) {
  BOOST_ASSERT(declaration);
  if (move_assignment_) {
    return {move_assignment_, false};
  }
  move_assignment_ = declaration;
  return {move_assignment_, true};
}

FunctionDecl* TypeSymbol::GetMoveAssignment() { return move_assignment_; }

const FunctionDecl* TypeSymbol::GetMoveAssignment() const { return move_assignment_; }

VariableSymbol::VariableSymbol(VarDecl* declaration) : declaration_(declaration) { BOOST_ASSERT(declaration_); }

SymbolKind VariableSymbol::GetKind() const { return SymbolKind::Variable; }

VarDecl* VariableSymbol::GetDeclaration() const { return declaration_; }

FunctionSymbol::FunctionSymbol(FunctionDecl* declaration) { AddDeclaration(declaration); }

SymbolKind FunctionSymbol::GetKind() const { return SymbolKind::Function; }

void FunctionSymbol::AddDeclaration(FunctionDecl* declaration) {
  BOOST_ASSERT(declaration);
  declarations_.push_back(declaration);
}

const std::vector<FunctionDecl*>& FunctionSymbol::Declarations() const { return declarations_; }

}  // namespace cw
