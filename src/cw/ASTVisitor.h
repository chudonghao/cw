/// \file ASTVisitor.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include "ast.h"

namespace cw {

/// \brief AST visitor base class.
///
/// Provides Visit methods for all AST node types. Default implementation
/// chains to parent class Visit, ultimately calling Traverse on the node.
///
/// Usage:
/// - Override Visit(ConcreteNode&) to handle specific node types
/// - Call ASTVisitor::Visit(n) in your override to continue traversal
/// - Not calling parent Visit will stop recursion at that node
class ASTVisitor {
 public:
  virtual ~ASTVisitor() = default;

  // Base classes (called by concrete Visit methods)
  virtual void Visit(Node& n);
  virtual void Visit(TypeSyntax& n);
  virtual void Visit(Decl& n);
  virtual void Visit(Stmt& n);
  virtual void Visit(Expr& n);
  virtual void Visit(NamedDecl& n);
  virtual void Visit(ValueDecl& n);
  virtual void Visit(FunctionDecl& n);

  // Concrete Type
  virtual void Visit(BuiltinTypeSyntax& n);
  virtual void Visit(NamedTypeSyntax& n);
  virtual void Visit(PointerTypeSyntax& n);
  virtual void Visit(FunctionTypeSyntax& n);
  virtual void Visit(VirtualSlotTypeSyntax& n);
  virtual void Visit(ConstTypeSyntax& n);
  virtual void Visit(ReferenceTypeSyntax& n);
  virtual void Visit(ArrayTypeSyntax& n);

  // Concrete Decl
  virtual void Visit(TranslationUnitDecl& n);
  virtual void Visit(VirtualDecl& n);
  virtual void Visit(VarGroupDecl& n);
  virtual void Visit(VarDecl& n);
  virtual void Visit(StructDecl& n);
  virtual void Visit(ConstructorDecl& n);
  virtual void Visit(DestructorDecl& n);
  virtual void Visit(VirtualFunctionDecl& n);
  virtual void Visit(ParmVarDecl& n);
  virtual void Visit(ReturnVarDecl& n);
  virtual void Visit(FieldDecl& n);

  // Concrete Stmt (8)
  virtual void Visit(CompoundStmt& n);
  virtual void Visit(ExprStmt& n);
  virtual void Visit(DeclStmt& n);
  virtual void Visit(IfStmt& n);
  virtual void Visit(WhileStmt& n);
  virtual void Visit(BreakStmt& n);
  virtual void Visit(ContinueStmt& n);
  virtual void Visit(ReturnStmt& n);

  // Concrete Expr
  virtual void Visit(IntegerLiteral& n);
  virtual void Visit(CharacterLiteral& n);
  virtual void Visit(FloatLiteral& n);
  virtual void Visit(BoolLiteral& n);
  virtual void Visit(NullLiteral& n);
  virtual void Visit(StringLiteral& n);
  virtual void Visit(DeclRefExpr& n);
  virtual void Visit(ThisExpr& n);
  virtual void Visit(ParenExpr& n);
  virtual void Visit(UnaryOperator& n);
  virtual void Visit(BinaryOperator& n);
  virtual void Visit(InitializationExpr& n);
  virtual void Visit(ImplicitResultInitializationExpr& n);
  virtual void Visit(ConditionalOperator& n);
  virtual void Visit(MemberExpr& n);
  virtual void Visit(BaseSubobjectExpr& n);
  virtual void Visit(SubscriptExpr& n);
  virtual void Visit(ArrayValueExpr& n);
  virtual void Visit(CallExpr& n);
  virtual void Visit(OperatorCallExpr& n);
  virtual void Visit(ConstructionExpr& n);
  virtual void Visit(ArrayConstructionExpr& n);
  virtual void Visit(ArrayAssignmentExpr& n);
  virtual void Visit(DestructorCallExpr& n);
  virtual void Visit(ReceiverCallExpr& n);
  virtual void Visit(ImplicitOverloadSetSelectionExpr& n);
  virtual void Visit(ImplicitCastExpr& n);
  virtual void Visit(MaterializeTemporaryExpr& n);
  virtual void Visit(RecoveryExpr& n);
};

}  // namespace cw
