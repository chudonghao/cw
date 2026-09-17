/// \file ast.h
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstdint>
#include <memory>
#include <string>
#include <utility>
#include <variant>
#include <vector>

#include <boost/multiprecision/cpp_int.hpp>

#include "BuiltinTypes.h"
#include "ExprGrammar.h"
#include "Source.h"

namespace cw {

/// \brief Node kind enumeration for RTTI.
enum class NodeKind {
  Invalid,
  // Type
  BuiltinTypeSyntax,
  NamedTypeSyntax,
  PointerTypeSyntax,
  FunctionTypeSyntax,
  VirtualSlotTypeSyntax,
  ConstTypeSyntax,
  ReferenceTypeSyntax,
  ArrayTypeSyntax,
  // Decl
  TranslationUnitDecl,
  VirtualDecl,
  VarGroupDecl,
  VarDecl,
  StructDecl,
  FunctionDecl,
  ConstructorDecl,
  DestructorDecl,
  VirtualFunctionDecl,
  ParmVarDecl,
  ReturnVarDecl,
  FieldDecl,
  // Stmt
  CompoundStmt,
  ExprStmt,
  DeclStmt,
  IfStmt,
  WhileStmt,
  BreakStmt,
  ContinueStmt,
  ReturnStmt,
  // Expr
  IntegerLiteral,
  CharacterLiteral,
  FloatLiteral,
  BoolLiteral,
  NullLiteral,
  StringLiteral,
  DeclRefExpr,
  ThisExpr,
  ParenExpr,
  UnaryOperator,
  BinaryOperator,
  InitializationExpr,
  ImplicitResultInitializationExpr,
  ConditionalOperator,
  MemberExpr,
  BaseSubobjectExpr,
  SubscriptExpr,
  ArrayValueExpr,
  CallExpr,
  OperatorCallExpr,
  ConstructionExpr,
  ArrayConstructionExpr,
  ArrayAssignmentExpr,
  DestructorCallExpr,
  ReceiverCallExpr,
  ImplicitOverloadSetSelectionExpr,
  ImplicitCastExpr,
  MaterializeTemporaryExpr,
  RecoveryExpr,
};

// Forward declarations.
class ASTVisitor;
class ASTContext;
class Type;
class ComptimeIntType;
class NullType;
class BuiltinType;
class StructType;
class ArrayType;
class PointerType;
class FunctionType;
class ReferenceType;
class FunctionOverloadSetType;
class AddressOfFunctionOverloadSetType;
class VirtualSlotType;

/// \brief A canonical semantic type plus qualifiers on the current object layer.
class QualType {
  const Type* type_{};  ///< Non-owning canonical unqualified type node.
  bool is_const_{};     ///< Qualifier on this type occurrence's current object layer.

 public:
  QualType() = default;
  explicit QualType(const Type* type, bool is_const = false) : type_(type), is_const_(type && is_const) {}

  /// \brief Returns the canonical unqualified type node, or null for an empty type.
  const Type* GetTypePtr() const { return type_; }

  /// \brief Returns whether the current object layer is const-qualified.
  bool IsConstQualified() const { return is_const_; }

  /// \brief Returns this type without the current layer's const qualifier.
  QualType WithoutConst() const { return QualType(type_); }

  /// \brief Returns this type with the current layer const-qualified.
  QualType WithConst() const { return QualType(type_, true); }

  explicit operator bool() const { return type_ != nullptr; }

  friend bool operator==(QualType left, QualType right) {
    return left.type_ == right.type_ && left.is_const_ == right.is_const_;
  }
  friend bool operator!=(QualType left, QualType right) { return !(left == right); }
};

/// \brief Reference permission and binding mode.
enum class ReferenceMode {
  Mut,
  Copy,
  Move,
};

/// \brief Runtime object value category carried by an expression.
enum class ValueCategory {
  None,
  LValue,
  MoveLValue,
  PureRValue,
};

/// \brief Semantic operation performed by an implicit conversion expression.
enum class ImplicitConversionKind {
  Invalid,
  Identity,
  NoOp,  ///< Same-object const access; preserves value category without a read or address adjustment.
  LValueToRValue,
  NullToPointer,
  ComptimeIntegerMaterialization,
  IntegerToInteger,
  FloatToFloat,
  IntegerToFloat,
  FloatToInteger,
  Qualification,
  DerivedToBase,
};

/// \brief Constructor entry kind used by a construction expression.
enum class ConstructionKind {
  CompleteObject,
  BaseSubobject,
  Delegating,
};

/// \brief Final semantic triviality classification of an object type.
enum class TypeTriviality {
  Unknown,
  Trivial,
  NonTrivial,
  Invalid,
};

/// \brief Returns the stable AST spelling of an implicit conversion kind.
const char* to_string(ImplicitConversionKind kind);

/// \brief Returns the stable AST spelling of a construction kind.
const char* to_string(ConstructionKind kind);

/// \brief Returns whether a stored declaration name is an operator spelling.
bool IsOperatorFunctionName(const std::string& name);

/// \brief One source-level declaration attribute.
struct Attribute {
  std::string name{};   ///< Attribute name as written in source.
  SourceRange range{};  ///< Exact source range of the attribute name.
};

/// \brief Ordered source-level declaration attributes.
using AttributeList = std::vector<Attribute>;

struct VarDecl;
struct ParmVarDecl;
struct ReturnVarDecl;
struct FunctionDecl;
struct VirtualFunctionDecl;
struct CompoundStmt;
struct Expr;

/// \brief Base class for all AST nodes.
struct Node {
  SourceRange range{};           ///< Half-open character range occupied by this syntax node.
  bool contains_errors = false;  ///< True when this node or a descendant has a fatal front-end error.

  virtual ~Node() = default;
  virtual NodeKind GetKind() const = 0;
  virtual void Accept(ASTVisitor& visitor) = 0;
  virtual void Traverse(ASTVisitor& visitor) = 0;

  /// \brief Returns true when this node or a descendant has a fatal front-end error.
  bool ContainsErrors() const { return contains_errors; }
};

/// \brief Base class for source-level type syntax.
struct TypeSyntax : Node {};

/// \brief Built-in type syntax.
struct BuiltinTypeSyntax : TypeSyntax {
  BuiltinTypeKind kind{};  ///< Built-in type kind.

  NodeKind GetKind() const override { return NodeKind::BuiltinTypeSyntax; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief User-defined type name syntax.
struct NamedTypeSyntax : TypeSyntax {
  std::string name{};  ///< Type name as written in source.

  NodeKind GetKind() const override { return NodeKind::NamedTypeSyntax; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Pointer type syntax.
struct PointerTypeSyntax : TypeSyntax {
  std::unique_ptr<TypeSyntax> Pointee{};  ///< Pointed-to type, null for a partial error node.

  NodeKind GetKind() const override { return NodeKind::PointerTypeSyntax; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Function type syntax.
struct FunctionTypeSyntax : TypeSyntax {
  std::vector<std::unique_ptr<TypeSyntax>> ParameterTypes{};  ///< Parameter types in source order.
  std::unique_ptr<TypeSyntax> ReturnType{};                   ///< Required return type, null for a partial error node.

  NodeKind GetKind() const override { return NodeKind::FunctionTypeSyntax; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Virtual slot type syntax (`virtual *func(...) R`).
struct VirtualSlotTypeSyntax : TypeSyntax {
  SourceRange virtual_range{};                         ///< Exact source range of `virtual`.
  std::unique_ptr<PointerTypeSyntax> FunctionPointer;  ///< Required direct function pointer child.

  NodeKind GetKind() const override { return NodeKind::VirtualSlotTypeSyntax; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Prefix const type syntax.
struct ConstTypeSyntax : TypeSyntax {
  std::unique_ptr<TypeSyntax> QualifiedType{};  ///< Qualified type, null for a partial error node.

  NodeKind GetKind() const override { return NodeKind::ConstTypeSyntax; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Prefix reference type syntax.
struct ReferenceTypeSyntax : TypeSyntax {
  ReferenceMode mode{};                        ///< Reference mode written by the prefix.
  std::unique_ptr<TypeSyntax> ReferentType{};  ///< Referent type, null for a partial error node.

  NodeKind GetKind() const override { return NodeKind::ReferenceTypeSyntax; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Fixed-size array type syntax (`[N] T`).
struct ArrayTypeSyntax : TypeSyntax {
  SourceRange left_bracket_range{};           ///< Exact source range of `[`.
  SourceRange right_bracket_range{};          ///< Exact source range of `]`.
  std::unique_ptr<Expr> Length{};             ///< Required length expression.
  std::unique_ptr<TypeSyntax> ElementType{};  ///< Required element type syntax.

  NodeKind GetKind() const override { return NodeKind::ArrayTypeSyntax; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Base class for declarations.
struct Decl : Node {
  bool is_invalid = false;  ///< True when Sema has explicitly made this declaration unusable.
};

/// \brief Translation unit declaration (root of AST).
struct TranslationUnitDecl : Decl {
  std::vector<std::unique_ptr<Decl>> Decls{};  ///< Top-level declarations.

  NodeKind GetKind() const override { return NodeKind::TranslationUnitDecl; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Base class for named declarations.
struct NamedDecl : Decl {
  std::string name{};        ///< Declaration name.
  SourceRange name_range{};  ///< Exact source range of the written declaration name, including an operator spelling.
};

/// \brief Base class for named declarations that produce a value.
struct ValueDecl : NamedDecl {
  QualType type{};  ///< Canonical semantic declaration type.
};

/// \brief Virtual function block declaration.
struct VirtualDecl : Decl {
  std::vector<std::unique_ptr<VirtualFunctionDecl>> Functions{};  ///< Virtual function declarations.

  NodeKind GetKind() const override { return NodeKind::VirtualDecl; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Field declaration.
struct FieldDecl : ValueDecl {
  std::unique_ptr<TypeSyntax> Type{};  ///< Field type syntax.

  NodeKind GetKind() const override { return NodeKind::FieldDecl; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Struct declaration.
struct StructDecl : NamedDecl {
  std::string base{};                                  ///< Optional base class name.
  SourceRange base_range{};                            ///< Source range of the base name.
  const StructType* base_type{};                       ///< Non-owning resolved base type.
  TypeTriviality triviality{TypeTriviality::Unknown};  ///< Final semantic triviality classification.
  bool is_declared_trivial{};                          ///< Source-level `trivial` modifier.
  bool is_abstract{};                                  ///< Whether a final virtual slot remains abstract.
  std::unique_ptr<VirtualDecl> VirtualDecl{};          ///< Virtual function block.
  std::vector<std::unique_ptr<FieldDecl>> Fields{};    ///< Field declarations.

  NodeKind GetKind() const override { return NodeKind::StructDecl; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Function declaration.
struct FunctionDecl : ValueDecl {
  std::vector<std::unique_ptr<ParmVarDecl>> ParmVars{};  ///< Parameter declarations.
  std::unique_ptr<ReturnVarDecl> ReturnVar{};            ///< Return declaration.
  std::unique_ptr<CompoundStmt> Body{};                  ///< Function body.
  VirtualFunctionDecl* virtual_declaration{};            ///< Non-owning associated virtual declaration.

  NodeKind GetKind() const override { return NodeKind::FunctionDecl; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Constructor declaration.
struct ConstructorDecl : FunctionDecl {
  const StructType* target_type{};  ///< Non-owning resolved target structure type.

  NodeKind GetKind() const override { return NodeKind::ConstructorDecl; }
  void Accept(ASTVisitor& visitor) override;
};

/// \brief Destructor declaration.
struct DestructorDecl : FunctionDecl {
  const StructType* target_type{};  ///< Non-owning resolved target structure type.

  NodeKind GetKind() const override { return NodeKind::DestructorDecl; }
  void Accept(ASTVisitor& visitor) override;
};

/// \brief Virtual function slot declaration.
struct VirtualFunctionDecl : FunctionDecl {
  bool is_abstract{};                                  ///< Whether the declaration is explicitly abstract.
  bool is_override{};                                  ///< Whether the declaration is explicitly an override.
  VirtualFunctionDecl* overridden_virtual_function{};  ///< Non-owning directly overridden declaration.
  FunctionDecl* definition{};                          ///< Non-owning associated function definition.

  NodeKind GetKind() const override { return NodeKind::VirtualFunctionDecl; }
  void Accept(ASTVisitor& visitor) override;
};

/// \brief One source-level variable declaration group.
struct VarGroupDecl : Decl {
  std::vector<std::unique_ptr<VarDecl>> Vars{};    ///< Declared variables in source order.
  std::vector<std::unique_ptr<Expr>> InitExprs{};  ///< Initialization expressions.
  std::unique_ptr<CompoundStmt> Body{};            ///< Block initialization.

  NodeKind GetKind() const override { return NodeKind::VarGroupDecl; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Declaration of one variable entity.
struct VarDecl : ValueDecl {
  std::unique_ptr<TypeSyntax> Type{};  ///< Optional explicit type syntax for this variable.
  AttributeList attributes{};          ///< Attributes applied to this variable.

  NodeKind GetKind() const override { return NodeKind::VarDecl; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Parameter variable declaration.
struct ParmVarDecl : VarDecl {
  NodeKind GetKind() const override { return NodeKind::ParmVarDecl; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Return variable declaration.
struct ReturnVarDecl : VarDecl {
  NodeKind GetKind() const override { return NodeKind::ReturnVarDecl; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Base class for statements.
struct Stmt : Node {};

/// \brief Base class for expressions.
struct Expr : Node {
  QualType type{};                                    ///< Canonical semantic expression type.
  ValueCategory value_category{ValueCategory::None};  ///< Runtime object value category.

  Expr* IgnoreParens();
  const Expr* IgnoreParens() const;
};

/// \brief Integer literal expression (123, 0x1F).
struct IntegerLiteral : Expr {
  boost::multiprecision::cpp_int value{};  ///< Exact integer value.

  NodeKind GetKind() const override { return NodeKind::IntegerLiteral; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Character literal expression ('a', '\n').
struct CharacterLiteral : Expr {
  uint8_t value{};  ///< Character byte value.

  NodeKind GetKind() const override { return NodeKind::CharacterLiteral; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Float literal expression (1.23, 3.14f).
struct FloatLiteral : Expr {
  std::variant<float, double> value{};  ///< Float value.

  NodeKind GetKind() const override { return NodeKind::FloatLiteral; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief The target-independent null literal; it does not itself form an object.
struct NullLiteral : Expr {
  NodeKind GetKind() const override { return NodeKind::NullLiteral; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Bool literal expression (true, false).
struct BoolLiteral : Expr {
  bool value{};  ///< Boolean value.

  NodeKind GetKind() const override { return NodeKind::BoolLiteral; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief An initialized static byte array, exposed as a const array lvalue by Sema.
struct StringLiteral : Expr {
  std::string value{};  ///< Decoded, concatenated bytes without an implicit terminator.

  NodeKind GetKind() const override { return NodeKind::StringLiteral; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Declaration reference expression (foo).
struct DeclRefExpr : Expr {
  std::string name{};              ///< Identifier or operator spelling.
  const ValueDecl* declaration{};  ///< Non-owning final referenced declaration.

  NodeKind GetKind() const override { return NodeKind::DeclRefExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Reserved expression naming the current object.
struct ThisExpr : Expr {
  NodeKind GetKind() const override { return NodeKind::ThisExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Explicitly parenthesized expression.
struct ParenExpr : Expr {
  SourceRange left_paren_range{};   ///< Exact source range of '('.
  SourceRange right_paren_range{};  ///< Exact source range of ')'.
  std::unique_ptr<Expr> SubExpr{};  ///< Expression enclosed by the parentheses.

  NodeKind GetKind() const override { return NodeKind::ParenExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Unary operator expression (++x, x++, -x, *x, &x, !x, ~x).
struct UnaryOperator : Expr {
  expr::ExprGrammarSymbol op{};     ///< Operator (plus, minus, star, amp, exclaim, tilde, plusplus, minusminus).
  SourceRange operator_range{};     ///< Exact source range of the operator token.
  bool is_postfix{};                ///< true for x++/x--, false for ++x/--x.
  std::unique_ptr<Expr> Operand{};  ///< Operand expression.

  NodeKind GetKind() const override { return NodeKind::UnaryOperator; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Binary operator expression (a + b, a = b, etc.).
struct BinaryOperator : Expr {
  expr::ExprGrammarSymbol op{};  ///< Operator.
  SourceRange operator_range{};  ///< Exact source range of the operator token.
  std::unique_ptr<Expr> LHS{};   ///< Left-hand side expression.
  std::unique_ptr<Expr> RHS{};   ///< Right-hand side expression.

  NodeKind GetKind() const override { return NodeKind::BinaryOperator; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
  bool IsSimpleAssignment() const { return op == expr::equal; }
};

/// \brief Explicit initialization expression (target := source).
struct InitializationExpr : Expr {
  std::unique_ptr<Expr> Target{};  ///< Source-level initialization target.
  std::unique_ptr<Expr> Source{};  ///< Source expression used to initialize the target.

  NodeKind GetKind() const override { return NodeKind::InitializationExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Implicit initialization of a result object from a source expression.
struct ImplicitResultInitializationExpr : Expr {
  const VarDecl* Target{};         ///< Non-owning result object initialized by this node.
  std::unique_ptr<Expr> Source{};  ///< Source expression used to initialize the result object.

  NodeKind GetKind() const override { return NodeKind::ImplicitResultInitializationExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Conditional expression (cond ? then : else).
struct ConditionalOperator : Expr {
  std::unique_ptr<Expr> Cond{};  ///< Condition expression.
  std::unique_ptr<Expr> Then{};  ///< Then expression.
  std::unique_ptr<Expr> Else{};  ///< Else expression.

  NodeKind GetKind() const override { return NodeKind::ConditionalOperator; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Member access expression (a.b, a->b).
struct MemberExpr : Expr {
  std::unique_ptr<Expr> Base{};    ///< Base expression.
  std::string member{};            ///< Member name.
  SourceRange member_range{};      ///< Exact source range of the member name.
  SourceRange operator_range{};    ///< Exact source range of '.' or '->'.
  expr::ExprGrammarSymbol op{};    ///< Access operator (period or arrow).
  const FieldDecl* declaration{};  ///< Non-owning final referenced field.

  NodeKind GetKind() const override { return NodeKind::MemberExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Explicit selection of a base subobject (a.Base, a->Base).
struct BaseSubobjectExpr : Expr {
  std::unique_ptr<Expr> Base{};                ///< Owning expression containing the selected base subobject.
  SourceRange operator_range{};                ///< Exact source range of '.' or '->'.
  expr::ExprGrammarSymbol op{};                ///< Access operator (period or arrow).
  std::vector<const StructDecl*> base_path{};  ///< Non-owning direct-base path to the selected subobject.

  NodeKind GetKind() const override { return NodeKind::BaseSubobjectExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;

  const StructDecl* GetDeclaration() const { return base_path.empty() ? nullptr : base_path.back(); }
};

/// \brief Array subscript expression (a[i]).
struct SubscriptExpr : Expr {
  std::unique_ptr<Expr> Base{};   ///< Base expression.
  std::unique_ptr<Expr> Index{};  ///< Index expression.

  NodeKind GetKind() const override { return NodeKind::SubscriptExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Complete fixed-array value (`[N] T { ... }`) or contextual nested array value (`{ ... }`).
struct ArrayValueExpr : Expr {
  std::unique_ptr<ArrayTypeSyntax> Type{};  ///< Explicit type for an outer value; null for a contextual nested value.
  SourceRange left_brace_range{};           ///< Exact source range of `{`.
  SourceRange right_brace_range{};          ///< Exact source range of `}`.
  std::vector<std::unique_ptr<Expr>> Elements{};  ///< Elements in source order.

  NodeKind GetKind() const override { return NodeKind::ArrayValueExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Function call expression (f(a, b)).
struct CallExpr : Expr {
  std::unique_ptr<Expr> Callee{};             ///< Callee expression.
  std::vector<std::unique_ptr<Expr>> Args{};  ///< Arguments.
  bool is_nonvirtual{};                       ///< Whether source explicitly disables virtual candidate selection.
  SourceRange nonvirtual_range{};             ///< Exact source range of the written `nonvirtual` keyword.

  NodeKind GetKind() const override { return NodeKind::CallExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Function call formed from user-defined operator syntax.
struct OperatorCallExpr : CallExpr {
  NodeKind GetKind() const override { return NodeKind::OperatorCallExpr; }
  void Accept(ASTVisitor& visitor) override;
};

/// \brief Construction of a complete object, base subobject, or delegated current object.
struct ConstructionExpr : Expr {
  ConstructionKind construction_kind{ConstructionKind::CompleteObject};
  std::string target_name{};                  ///< Constructor target name as written in source, if any.
  SourceRange target_name_range{};            ///< Exact source range of the written target name.
  const ConstructorDecl* constructor{};       ///< Selected constructor; null on successful trivial default formation.
  std::unique_ptr<Expr> TargetAddress{};      ///< Present only for explicit-address construction.
  std::vector<std::unique_ptr<Expr>> Args{};  ///< Constructor arguments in source order.

  NodeKind GetKind() const override { return NodeKind::ConstructionExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Compact whole-array copy or move construction.
struct ArrayConstructionExpr : Expr {
  const ConstructorDecl* element_constructor{};  ///< Non-owning selected final leaf constructor.
  std::unique_ptr<Expr> Source{};                ///< Whole source array expression.

  NodeKind GetKind() const override { return NodeKind::ArrayConstructionExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Compact whole-array copy or move assignment.
struct ArrayAssignmentExpr : Expr {
  SourceRange operator_range{};              ///< Exact source range of `=`.
  const FunctionDecl* element_assignment{};  ///< Non-owning selected final leaf assignment.
  std::unique_ptr<Expr> LHS{};               ///< Destination array expression.
  std::unique_ptr<Expr> RHS{};               ///< Source array expression.

  NodeKind GetKind() const override { return NodeKind::ArrayAssignmentExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Explicit destruction at a supplied target address (dtor (address) T()).
struct DestructorCallExpr : CallExpr {
  std::unique_ptr<Expr> TargetAddress{};  ///< Required address of the object to destroy.

  NodeKind GetKind() const override { return NodeKind::DestructorCallExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Receiver-form call of an ordinary function (object.f(a), pointer->f(a)).
/// Sema prepares the receiver once, then applies the ordinary first-argument conversion.
/// Formation failure preserves the prepared source; consumers never repeat an arrow dereference.
struct ReceiverCallExpr : CallExpr {
  std::unique_ptr<Expr> Receiver{};  ///< Syntax operand; Sema stores the prepared or converted first argument.
  SourceRange operator_range{};      ///< Exact source range of '.' or '->'.
  expr::ExprGrammarSymbol op{};      ///< Access operator (period or arrow).

  NodeKind GetKind() const override { return NodeKind::ReceiverCallExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Target-driven selection of one declaration from an addressed function overload set.
struct ImplicitOverloadSetSelectionExpr : Expr {
  const FunctionDecl* selected_declaration{};  ///< Non-owning uniquely selected declaration.
  std::unique_ptr<Expr> SubExpr{};             ///< Source-level addressed overload-set expression.

  NodeKind GetKind() const override { return NodeKind::ImplicitOverloadSetSelectionExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Implicit built-in value change or same-object projection inserted by semantic analysis.
/// NoOp retains object identity and value category as const access. LValueToRValue reads
/// scalar or trivial aggregate objects. DerivedToBase records a static base path.
struct ImplicitCastExpr : Expr {
  ImplicitConversionKind conversion_kind{ImplicitConversionKind::Invalid};  ///< Performed conversion.
  std::unique_ptr<Expr> SubExpr{};                                          ///< Converted source expression.
  std::vector<const StructDecl*> base_path{};  ///< Non-owning direct-base path for DerivedToBase.

  NodeKind GetKind() const override { return NodeKind::ImplicitCastExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Makes a pure result object directly referable as a temporary object.
struct MaterializeTemporaryExpr : Expr {
  std::unique_ptr<Expr> SubExpr{};  ///< Pure-rvalue result object being materialized.

  NodeKind GetKind() const override { return NodeKind::MaterializeTemporaryExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Recovery expression placeholder (always contains errors).
///
/// Created when an expression slot must hold a value but parsing failed and no
/// partial node is available, so that expression slots are never an "error
/// null". Modeled after Clang's RecoveryExpr.
struct RecoveryExpr : Expr {
  RecoveryExpr() { contains_errors = true; }
  NodeKind GetKind() const override { return NodeKind::RecoveryExpr; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Compound statement (block).
struct CompoundStmt : Stmt {
  std::vector<std::unique_ptr<Stmt>> Stmts{};      ///< Statements in the block.
  std::vector<std::unique_ptr<Expr>> TailExprs{};  ///< Tail expressions.

  NodeKind GetKind() const override { return NodeKind::CompoundStmt; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Expression statement.
struct ExprStmt : Stmt {
  std::unique_ptr<Expr> Expr{};  ///< The expression.

  NodeKind GetKind() const override { return NodeKind::ExprStmt; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Declaration statement.
struct DeclStmt : Stmt {
  std::unique_ptr<Decl> Decl{};  ///< The declaration.

  NodeKind GetKind() const override { return NodeKind::DeclStmt; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief If statement.
struct IfStmt : Stmt {
  std::unique_ptr<Expr> Cond{};          ///< Condition expression.
  std::unique_ptr<CompoundStmt> Then{};  ///< Then branch.
  std::unique_ptr<CompoundStmt> Else{};  ///< Else branch (optional).

  NodeKind GetKind() const override { return NodeKind::IfStmt; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief While statement.
struct WhileStmt : Stmt {
  std::unique_ptr<Expr> Cond{};          ///< Condition expression.
  std::unique_ptr<CompoundStmt> Body{};  ///< Loop body.

  NodeKind GetKind() const override { return NodeKind::WhileStmt; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Break statement.
struct BreakStmt : Stmt {
  NodeKind GetKind() const override { return NodeKind::BreakStmt; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Continue statement.
struct ContinueStmt : Stmt {
  NodeKind GetKind() const override { return NodeKind::ContinueStmt; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

/// \brief Return statement.
struct ReturnStmt : Stmt {
  std::unique_ptr<Expr> Expr{};  ///< Return value (optional).

  NodeKind GetKind() const override { return NodeKind::ReturnStmt; }
  void Accept(ASTVisitor& visitor) override;
  void Traverse(ASTVisitor& visitor) override;
};

// Canonical semantic types are separate from the owning syntax tree.

/// \brief Kinds of canonical semantic types.
enum class TypeKind {
  ComptimeInt,
  Null,
  FunctionOverloadSet,
  AddressOfFunctionOverloadSet,
  Builtin,
  Struct,
  Array,
  Pointer,
  VirtualSlot,
  Function,
  Reference,
};

/// \brief Base class for canonical semantic types.
class Type {
  friend class ComptimeIntType;
  friend class NullType;
  friend class FunctionOverloadSetType;
  friend class AddressOfFunctionOverloadSetType;
  friend class BuiltinType;
  friend class StructType;
  friend class ArrayType;
  friend class PointerType;
  friend class VirtualSlotType;
  friend class FunctionType;
  friend class ReferenceType;

  TypeKind kind_;  ///< Semantic type kind.

 public:
  virtual ~Type() = default;

  Type(const Type&) = delete;
  Type& operator=(const Type&) = delete;
  Type(Type&&) = delete;
  Type& operator=(Type&&) = delete;

  /// \brief Returns this type's semantic kind.
  TypeKind GetKind() const { return kind_; }

  /// \brief Returns this canonical ComptimeInt type, or null for a different kind.
  const ComptimeIntType* AsComptimeIntType() const;

  /// \brief Returns this canonical nonobject null type, or null for a different kind.
  const NullType* AsNullType() const;

  /// \brief Returns this canonical FunctionOverloadSet type, or null for a different kind.
  const FunctionOverloadSetType* AsFunctionOverloadSetType() const;

  /// \brief Returns this canonical AddressOfFunctionOverloadSet type, or null for a different kind.
  const AddressOfFunctionOverloadSetType* AsAddressOfFunctionOverloadSetType() const;

  /// \brief Returns this canonical Builtin type, or null for a different kind.
  const BuiltinType* AsBuiltinType() const;

  /// \brief Returns this canonical Struct type, or null for a different kind.
  const StructType* AsStructType() const;

  /// \brief Returns this canonical Array type, or null for a different kind.
  const ArrayType* AsArrayType() const;

  /// \brief Returns this canonical Pointer type, or null for a different kind.
  const PointerType* AsPointerType() const;

  /// \brief Returns this canonical VirtualSlot type, or null for a different kind.
  const VirtualSlotType* AsVirtualSlotType() const;

  /// \brief Returns this canonical Function type, or null for a different kind.
  const FunctionType* AsFunctionType() const;

  /// \brief Returns this canonical Reference type, or null for a different kind.
  const ReferenceType* AsReferenceType() const;

  /// \brief Returns whether this is an ordinary runtime object type.
  bool IsObject() const;

  /// \brief Returns whether this is the built-in void type.
  bool IsVoid() const;

  /// \brief Returns whether this is a runtime scalar or pointer value type.
  bool IsScalar() const;

  /// \brief Returns the completed object triviality, or Invalid for nonobjects.
  TypeTriviality GetTriviality() const;

 private:
  explicit Type(TypeKind kind) : kind_(kind) {}
};

/// \brief Canonical semantic type for exact compile-time integers.
class ComptimeIntType : public Type {
 private:
  friend class ASTContext;

  ComptimeIntType() : Type(TypeKind::ComptimeInt) {}
};

/// \brief Internal nonobject type of a null literal before target-driven conversion.
class NullType : public Type {
 private:
  friend class ASTContext;

  NullType() : Type(TypeKind::Null) {}
};

/// \brief Internal marker type for a bound function overload set.
class FunctionOverloadSetType : public Type {
 private:
  friend class ASTContext;

  FunctionOverloadSetType() : Type(TypeKind::FunctionOverloadSet) {}
};

/// \brief Internal marker type for an explicitly addressed function overload set.
class AddressOfFunctionOverloadSetType : public Type {
 private:
  friend class ASTContext;

  AddressOfFunctionOverloadSetType() : Type(TypeKind::AddressOfFunctionOverloadSet) {}
};

/// \brief Canonical built-in semantic type.
class BuiltinType : public Type {
  friend class ASTContext;

  BuiltinTypeKind builtin_type_kind_;  ///< Represented built-in type.

 public:
  /// \brief Returns the represented built-in type kind.
  BuiltinTypeKind GetBuiltinTypeKind() const { return builtin_type_kind_; }

  /// \brief Returns whether this built-in belongs to the integer family.
  bool IsInteger() const;

  /// \brief Returns whether this built-in belongs to the signed integer family.
  bool IsSignedInteger() const;

  /// \brief Returns whether this built-in belongs to the unsigned integer family.
  bool IsUnsignedInteger() const;

  /// \brief Returns whether this built-in belongs to the pointer-size integer family.
  bool IsSizeInteger() const;

  /// \brief Returns whether this built-in belongs to the floating-point family.
  bool IsFloatingPoint() const;

 private:
  explicit BuiltinType(BuiltinTypeKind kind) : Type(TypeKind::Builtin), builtin_type_kind_(kind) {}
};

/// \brief Canonical semantic type for a struct declaration.
class StructType : public Type {
  friend class ASTContext;

  const StructDecl* declaration_;  ///< Non-owning defining declaration.

 public:
  /// \brief Returns the declaration defining this type.
  const StructDecl* GetDeclaration() const { return declaration_; }

 private:
  explicit StructType(const StructDecl* declaration) : Type(TypeKind::Struct), declaration_(declaration) {}
};

using ArrayLength = std::uint64_t;

/// \brief Canonical semantic fixed-size array type.
class ArrayType : public Type {
  friend class ASTContext;

  QualType element_type_;  ///< Canonical qualified element type.
  ArrayLength length_{};   ///< Number of elements.

 public:
  QualType GetElementType() const { return element_type_; }
  ArrayLength GetLength() const { return length_; }

 private:
  ArrayType(QualType element_type, ArrayLength length)
      : Type(TypeKind::Array), element_type_(element_type), length_(length) {}
};

/// \brief Canonical semantic pointer type.
class PointerType : public Type {
  friend class ASTContext;

  QualType pointee_;  ///< Canonical qualified pointee.

 public:
  /// \brief Returns the canonical pointed-to type.
  QualType GetPointee() const { return pointee_; }

 private:
  explicit PointerType(QualType pointee) : Type(TypeKind::Pointer), pointee_(pointee) {}
};

/// \brief Canonical type of an unbound virtual interface slot value.
class VirtualSlotType : public Type {
  friend class ASTContext;

  const PointerType* entry_pointer_type_;  ///< Canonical direct pointer-to-function entry type.

 public:
  /// \brief Returns the ordinary function pointer type of the resolved entry.
  const PointerType* GetEntryPointerType() const { return entry_pointer_type_; }

 private:
  explicit VirtualSlotType(const PointerType* entry_pointer_type)
      : Type(TypeKind::VirtualSlot), entry_pointer_type_(entry_pointer_type) {}
};

/// \brief Canonical semantic function type.
class FunctionType : public Type {
  friend class ASTContext;

  std::vector<const Type*> parameter_types_;  ///< Canonical unqualified parameter types.
  const Type* return_type_;                   ///< Canonical unqualified return type.

 public:
  /// \brief Returns canonical parameter types in declaration order.
  const std::vector<const Type*>& GetParameterTypes() const { return parameter_types_; }

  /// \brief Returns the canonical return type.
  const Type* GetReturnType() const { return return_type_; }

 private:
  FunctionType(std::vector<const Type*> parameter_types, const Type* return_type)
      : Type(TypeKind::Function), parameter_types_(std::move(parameter_types)), return_type_(return_type) {}
};

/// \brief Canonical semantic reference type.
class ReferenceType : public Type {
  friend class ASTContext;

  ReferenceMode mode_;
  const Type* referent_type_;

 public:
  ReferenceMode GetMode() const { return mode_; }
  const Type* GetReferentType() const { return referent_type_; }

 private:
  ReferenceType(ReferenceMode mode, const Type* referent_type)
      : Type(TypeKind::Reference), mode_(mode), referent_type_(referent_type) {}
};

}  // namespace cw
