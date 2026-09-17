/// \file ASTVisitor.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "ASTVisitor.h"

namespace cw {

// Forward along the node hierarchy so overriding a base Visit handles derived nodes too.

void ASTVisitor::Visit(Node& n) { n.Traverse(*this); }
void ASTVisitor::Visit(TypeSyntax& n) { Visit(static_cast<Node&>(n)); }
void ASTVisitor::Visit(Decl& n) { Visit(static_cast<Node&>(n)); }
void ASTVisitor::Visit(Stmt& n) { Visit(static_cast<Node&>(n)); }
void ASTVisitor::Visit(Expr& n) { Visit(static_cast<Node&>(n)); }
void ASTVisitor::Visit(NamedDecl& n) { Visit(static_cast<Decl&>(n)); }
void ASTVisitor::Visit(ValueDecl& n) { Visit(static_cast<NamedDecl&>(n)); }
void ASTVisitor::Visit(FunctionDecl& n) { Visit(static_cast<ValueDecl&>(n)); }

// Concrete Type Visit methods.

void ASTVisitor::Visit(BuiltinTypeSyntax& n) { Visit(static_cast<TypeSyntax&>(n)); }
void ASTVisitor::Visit(NamedTypeSyntax& n) { Visit(static_cast<TypeSyntax&>(n)); }
void ASTVisitor::Visit(PointerTypeSyntax& n) { Visit(static_cast<TypeSyntax&>(n)); }
void ASTVisitor::Visit(FunctionTypeSyntax& n) { Visit(static_cast<TypeSyntax&>(n)); }
void ASTVisitor::Visit(VirtualSlotTypeSyntax& n) { Visit(static_cast<TypeSyntax&>(n)); }
void ASTVisitor::Visit(ConstTypeSyntax& n) { Visit(static_cast<TypeSyntax&>(n)); }
void ASTVisitor::Visit(ReferenceTypeSyntax& n) { Visit(static_cast<TypeSyntax&>(n)); }
void ASTVisitor::Visit(ArrayTypeSyntax& n) { Visit(static_cast<TypeSyntax&>(n)); }

// Concrete Decl Visit methods.

void ASTVisitor::Visit(TranslationUnitDecl& n) { Visit(static_cast<Decl&>(n)); }
void ASTVisitor::Visit(VirtualDecl& n) { Visit(static_cast<Decl&>(n)); }
void ASTVisitor::Visit(VarGroupDecl& n) { Visit(static_cast<Decl&>(n)); }
void ASTVisitor::Visit(VarDecl& n) { Visit(static_cast<ValueDecl&>(n)); }
void ASTVisitor::Visit(StructDecl& n) { Visit(static_cast<NamedDecl&>(n)); }
void ASTVisitor::Visit(ConstructorDecl& n) { Visit(static_cast<FunctionDecl&>(n)); }
void ASTVisitor::Visit(DestructorDecl& n) { Visit(static_cast<FunctionDecl&>(n)); }
void ASTVisitor::Visit(VirtualFunctionDecl& n) { Visit(static_cast<FunctionDecl&>(n)); }
void ASTVisitor::Visit(ParmVarDecl& n) { Visit(static_cast<VarDecl&>(n)); }
void ASTVisitor::Visit(ReturnVarDecl& n) { Visit(static_cast<VarDecl&>(n)); }
void ASTVisitor::Visit(FieldDecl& n) { Visit(static_cast<ValueDecl&>(n)); }

// Concrete Stmt Visit methods.

void ASTVisitor::Visit(CompoundStmt& n) { Visit(static_cast<Stmt&>(n)); }
void ASTVisitor::Visit(ExprStmt& n) { Visit(static_cast<Stmt&>(n)); }
void ASTVisitor::Visit(DeclStmt& n) { Visit(static_cast<Stmt&>(n)); }
void ASTVisitor::Visit(IfStmt& n) { Visit(static_cast<Stmt&>(n)); }
void ASTVisitor::Visit(WhileStmt& n) { Visit(static_cast<Stmt&>(n)); }
void ASTVisitor::Visit(BreakStmt& n) { Visit(static_cast<Stmt&>(n)); }
void ASTVisitor::Visit(ContinueStmt& n) { Visit(static_cast<Stmt&>(n)); }
void ASTVisitor::Visit(ReturnStmt& n) { Visit(static_cast<Stmt&>(n)); }

// Concrete Expr Visit methods.

void ASTVisitor::Visit(IntegerLiteral& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(CharacterLiteral& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(FloatLiteral& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(BoolLiteral& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(NullLiteral& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(StringLiteral& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(DeclRefExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(ThisExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(ParenExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(UnaryOperator& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(BinaryOperator& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(InitializationExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(ImplicitResultInitializationExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(ConditionalOperator& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(MemberExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(BaseSubobjectExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(SubscriptExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(ArrayValueExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(CallExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(OperatorCallExpr& n) { Visit(static_cast<CallExpr&>(n)); }
void ASTVisitor::Visit(ConstructionExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(ArrayConstructionExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(ArrayAssignmentExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(DestructorCallExpr& n) { Visit(static_cast<CallExpr&>(n)); }
void ASTVisitor::Visit(ReceiverCallExpr& n) { Visit(static_cast<CallExpr&>(n)); }
void ASTVisitor::Visit(ImplicitOverloadSetSelectionExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(ImplicitCastExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(MaterializeTemporaryExpr& n) { Visit(static_cast<Expr&>(n)); }
void ASTVisitor::Visit(RecoveryExpr& n) { Visit(static_cast<Expr&>(n)); }

}  // namespace cw
