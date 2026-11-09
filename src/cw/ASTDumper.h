/// \file ASTDumper.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <ostream>
#include <string_view>
#include <vector>

#include "ASTVisitor.h"
#include "Source.h"

namespace cw {

/// \brief AST dumper that prints AST in tree format.
///
/// The caller names the AST stage, and the dump keeps three kinds of content apart:
/// - Syntax facts (written names, operators, literals, written base and target names, source
///   modifiers, type syntax) print identically in both stages; what the source omits is omitted.
/// - Semantic attributes (expression type and value category, declaration types, reference
///   targets, construction kinds and constructors, resolved targets of written names) print only in
///   the semantic stage, and always print there: an empty attribute prints a marker.
/// - Semantic relations and flags (virtual-declaration, overrides, implementation, a struct's
///   abstract) print only in the semantic stage, and only when present.
/// `contains-errors` prints in both stages.
///
/// Markers for empty semantic attributes:
/// - `'<error>'`, or `<error>` outside type positions: not determined because of a front-end error.
/// - `non-object`: the expression has a type but is not a runtime object.
/// - `overload-set`: the reference names an overload set rather than one declaration.
/// - `trivial`: trivial default formation selects no constructor.
///
/// Example output:
/// ```
/// TranslationUnitDecl 0x1000
/// `-StructDecl 0x1010 <test.cw:1:1, col:20> S trivial
/// ```
class ASTDumper : public ASTVisitor {
 public:
  /// \brief AST stage being dumped; the AST does not record its own stage.
  enum class Stage { Parsed, Semantic };

 private:
  std::ostream& os_;                    ///< Destination stream.
  const std::vector<Source>& sources_;  ///< Source context used to resolve file indices.
  Stage stage_;                         ///< Stage whose content is printed.
  SourceLocation previous_location_{};  ///< Last valid endpoint printed for location abbreviation.
  std::vector<bool> indent_stack_;      ///< true = last child at this level

 public:
  ASTDumper(std::ostream& os, const std::vector<Source>& sources, Stage stage);

  void Dump(Node& node);

  // Type
  void Visit(BuiltinTypeSyntax& n) override;
  void Visit(NamedTypeSyntax& n) override;
  void Visit(PointerTypeSyntax& n) override;
  void Visit(FunctionTypeSyntax& n) override;
  void Visit(VirtualSlotTypeSyntax& n) override;
  void Visit(ConstTypeSyntax& n) override;
  void Visit(ReferenceTypeSyntax& n) override;
  void Visit(ArrayTypeSyntax& n) override;

  // Decl
  void Visit(TranslationUnitDecl& n) override;
  void Visit(NamespaceDecl& n) override;
  void Visit(VirtualDecl& n) override;
  void Visit(VarGroupDecl& n) override;
  void Visit(VarDecl& n) override;
  void Visit(StructDecl& n) override;
  void Visit(FunctionDecl& n) override;
  void Visit(ConstructorDecl& n) override;
  void Visit(DestructorDecl& n) override;
  void Visit(VirtualFunctionDecl& n) override;
  void Visit(ParmVarDecl& n) override;
  void Visit(ReturnVarDecl& n) override;
  void Visit(FieldDecl& n) override;

  // Stmt
  void Visit(CompoundStmt& n) override;
  void Visit(ExprStmt& n) override;
  void Visit(ImplicitThisInitializationCompleteStmt& n) override;
  void Visit(DeclStmt& n) override;
  void Visit(IfStmt& n) override;
  void Visit(WhileStmt& n) override;
  void Visit(BreakStmt& n) override;
  void Visit(ContinueStmt& n) override;
  void Visit(ReturnStmt& n) override;

  // Expr
  void Visit(IntegerLiteral& n) override;
  void Visit(CharacterLiteral& n) override;
  void Visit(FloatLiteral& n) override;
  void Visit(BoolLiteral& n) override;
  void Visit(NullLiteral& n) override;
  void Visit(StringLiteral& n) override;
  void Visit(DeclRefExpr& n) override;
  void Visit(ThisExpr& n) override;
  void Visit(ParenExpr& n) override;
  void Visit(UnaryOperator& n) override;
  void Visit(BinaryOperator& n) override;
  void Visit(InitializationExpr& n) override;
  void Visit(ImplicitResultInitializationExpr& n) override;
  void Visit(ConditionalOperator& n) override;
  void Visit(MemberExpr& n) override;
  void Visit(BaseSubobjectExpr& n) override;
  void Visit(SubscriptExpr& n) override;
  void Visit(ArrayValueExpr& n) override;
  void Visit(BuiltinTypeExpr& n) override;
  void Visit(ScalarValueInitExpr& n) override;
  void Visit(FunctionalCastExpr& n) override;
  void Visit(CallExpr& n) override;
  void Visit(OperatorCallExpr& n) override;
  void Visit(ConstructionExpr& n) override;
  void Visit(ArrayConstructionExpr& n) override;
  void Visit(OpaqueValueExpr& n) override;
  void Visit(ArrayAssignmentExpr& n) override;
  void Visit(DestructorCallExpr& n) override;
  void Visit(ReceiverCallExpr& n) override;
  void Visit(ImplicitOverloadSetSelectionExpr& n) override;
  void Visit(ImplicitCastExpr& n) override;
  void Visit(MaterializeTemporaryExpr& n) override;
  void Visit(RecoveryExpr& n) override;

 private:
  void PrintIndent();
  void PushIndent(bool is_last);
  void PopIndent();
  void PrintAddress(const void* address);
  void PrintNodeIdentity(const char* name, const Node& n);
  void PrintNode(const char* name, const Node& n);
  void PrintSourceRange(const SourceRange& range);
  void PrintSourceLocation(const SourceLocation& location);
  void PrintEscapedString(std::string_view value);
  void PrintTypeName(QualType type);
  void PrintUnqualifiedTypeName(const Type& type);
  void PrintWrittenName(const NameSyntax& name);
  bool IsSemanticStage() const { return stage_ == Stage::Semantic; }

  // Semantic attributes and relations, printed only in the semantic stage.
  void PrintType(QualType type);
  void PrintExprType(const Expr& expression);
  void PrintDeclType(const ValueDecl& declaration);
  void PrintReferenceTarget(const ValueDecl* declaration);
  void PrintSelectedConstructor(const ConstructorDecl* constructor, const Expr& construction);
  void PrintRelation(const char* label, const ValueDecl* declaration);
  void PrintSpecialFunctionTarget(const StructType* target_type);
  void PrintBaseType(const StructType* type, bool is_last);

  void PrintDeclReference(const ValueDecl& declaration);
  void PrintStructReference(const StructDecl& declaration);
  void DumpDeclRefExpr(DeclRefExpr& n, bool print_written_name);
  bool IsPrintable(const SourceLocation& location) const;

  /// \brief Prints the " exported" marker when \p n carries the source-level `export` modifier.
  void PrintDeclModifier(const Decl& n);

  /// \brief Prints the " contains-errors" marker when \p n carries a fatal front-end error.
  void PrintErrorMark(const Node& n);

  /// \brief Visit a child node with proper indentation.
  void VisitChild(Node* child, bool is_last);
};

}  // namespace cw
