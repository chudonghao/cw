/// \file Sema.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "Sema.h"

#include <algorithm>
#include <cstddef>
#include <filesystem>
#include <functional>
#include <limits>
#include <memory>
#include <optional>
#include <string_view>
#include <type_traits>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <variant>

#include <boost/assert.hpp>
#include <boost/multiprecision/cpp_int.hpp>
#include <fmt/format.h>

#include "ASTContext.h"
#include "ASTVisitor.h"
#include "CFGBuilder.h"
#include "DefiniteInitialization.h"
#include "SemaConstant.h"
#include "SemaConversion.h"
#include "SemaOverload.h"
#include "ast.h"

namespace cw {

namespace {

using boost::multiprecision::cpp_int;
using namespace sema_detail;

std::vector<ConversionSource> MakeConversionSources(const std::vector<const Expr*>& expressions) {
  std::vector<ConversionSource> sources;
  sources.reserve(expressions.size());
  for (const Expr* expression : expressions) {
    BOOST_ASSERT(expression);
    sources.push_back(MakeConversionSource(*expression));
  }
  return sources;
}

const std::vector<const Type*>& FunctionParameterTypes(const FunctionDecl& declaration) {
  BOOST_ASSERT(declaration.type && declaration.type.GetTypePtr()->AsFunctionType());
  return declaration.type.GetTypePtr()->AsFunctionType()->GetParameterTypes();
}

/// \brief A winner's argument whose deferred object formation could not be completed.
struct ArgumentCompletionFailure {
  std::size_t index{};
  ObjectFormationFailure failure{};
};
using CompletedArguments = std::variant<std::vector<ConversionSequence>, ArgumentCompletionFailure>;

CompletedArguments CompleteArguments(const std::vector<ConversionSource>& sources,
                                     const std::vector<const Type*>& parameter_types,
                                     std::vector<ConversionSequence> conversions, const SymbolTable& symbol_table) {
  BOOST_ASSERT(sources.size() == parameter_types.size() && sources.size() == conversions.size());
  for (std::size_t index = 0; index < sources.size(); ++index) {
    if (auto failure =
            CompleteConversion(sources[index], QualType(parameter_types[index]), conversions[index], symbol_table)) {
      return ArgumentCompletionFailure{index, failure->failure};
    }
  }
  return conversions;
}

CompletedArguments CompleteArguments(const std::vector<ConversionSource>& sources, const FunctionDecl& declaration,
                                     std::vector<ConversionSequence> conversions, const SymbolTable& symbol_table) {
  return CompleteArguments(sources, FunctionParameterTypes(declaration), std::move(conversions), symbol_table);
}

std::vector<std::unique_ptr<Expr>*> ExpressionSlots(std::vector<std::unique_ptr<Expr>>& expressions) {
  std::vector<std::unique_ptr<Expr>*> result;
  for (auto& expression : expressions) result.push_back(&expression);
  return result;
}

const FunctionType* IndirectFunctionType(QualType type) {
  if (!type) {
    return nullptr;
  }
  const PointerType* pointer = type.GetTypePtr()->AsPointerType();
  if (const auto* slot = type.GetTypePtr()->AsVirtualSlotType()) {
    pointer = slot->GetEntryPointerType();
  }
  if (!pointer) {
    return nullptr;
  }
  const QualType pointee = pointer->GetPointee();
  return pointee ? pointee.GetTypePtr()->AsFunctionType() : nullptr;
}

const char* SymbolDescription(const Symbol& symbol) {
  switch (symbol.GetKind()) {
    case SymbolKind::Type:
      return "type";
    case SymbolKind::Variable:
      return "variable";
    case SymbolKind::Function:
      return "function";
  }
  BOOST_ASSERT(false && "unsupported symbol kind");
  return "";
}

TypeSymbol* AsTypeSymbol(Symbol* symbol) {
  return symbol && symbol->GetKind() == SymbolKind::Type ? static_cast<TypeSymbol*>(symbol) : nullptr;
}

const TypeSymbol* AsTypeSymbol(const Symbol* symbol) {
  return symbol && symbol->GetKind() == SymbolKind::Type ? static_cast<const TypeSymbol*>(symbol) : nullptr;
}

const VariableSymbol* AsVariableSymbol(const Symbol* symbol) {
  return symbol && symbol->GetKind() == SymbolKind::Variable ? static_cast<const VariableSymbol*>(symbol) : nullptr;
}

FunctionSymbol* AsFunctionSymbol(Symbol* symbol) {
  return symbol && symbol->GetKind() == SymbolKind::Function ? static_cast<FunctionSymbol*>(symbol) : nullptr;
}

const FunctionSymbol* AsFunctionSymbol(const Symbol* symbol) {
  return symbol && symbol->GetKind() == SymbolKind::Function ? static_cast<const FunctionSymbol*>(symbol) : nullptr;
}

SourceRange NamedDeclarationRange(const NamedDecl& declaration) {
  return declaration.name_range.IsValid() ? declaration.name_range
                                          : SourceRange{declaration.range.begin, declaration.range.begin};
}

SourceRange SymbolDeclarationRange(const Symbol& symbol) {
  switch (symbol.GetKind()) {
    case SymbolKind::Type:
      return NamedDeclarationRange(*static_cast<const TypeSymbol&>(symbol).GetDeclaration());
    case SymbolKind::Variable:
      return NamedDeclarationRange(*static_cast<const VariableSymbol&>(symbol).GetDeclaration());
    case SymbolKind::Function: {
      const auto& declarations = static_cast<const FunctionSymbol&>(symbol).Declarations();
      BOOST_ASSERT(!declarations.empty());
      return NamedDeclarationRange(*declarations.front());
    }
  }
  BOOST_ASSERT(false && "unsupported symbol kind");
  return {};
}

bool HasCompleteParameterSignature(const FunctionDecl& declaration) {
  for (const auto& parameter : declaration.ParmVars) {
    // Errors in parameter names or attributes do not erase the type identity.
    if (!parameter || !parameter->type || (parameter->Type && parameter->Type->ContainsErrors())) {
      return false;
    }
  }
  return true;
}

bool HasSameParameterSignature(const FunctionDecl& left, const FunctionDecl& right) {
  BOOST_ASSERT(HasCompleteParameterSignature(left));
  BOOST_ASSERT(HasCompleteParameterSignature(right));

  if (left.ParmVars.size() != right.ParmVars.size()) {
    return false;
  }
  for (std::size_t index = 0; index < left.ParmVars.size(); ++index) {
    if (left.ParmVars[index]->type != right.ParmVars[index]->type) {
      return false;
    }
  }
  return true;
}

const Type* FunctionReturnType(const FunctionDecl& declaration) {
  if (!declaration.type || declaration.type.GetTypePtr()->GetKind() != TypeKind::Function) {
    return nullptr;
  }
  return static_cast<const FunctionType&>(*declaration.type.GetTypePtr()).GetReturnType();
}

bool HasSameVirtualSlot(const FunctionDecl& left, const FunctionDecl& right) {
  if (left.name != right.name || left.ParmVars.size() != right.ParmVars.size() || left.ParmVars.empty() ||
      !HasCompleteParameterSignature(left) || !HasCompleteParameterSignature(right)) {
    return false;
  }

  const Type* left_receiver_type = left.ParmVars.front()->type.GetTypePtr();
  const Type* right_receiver_type = right.ParmVars.front()->type.GetTypePtr();
  if (!left_receiver_type || !right_receiver_type || left_receiver_type->GetKind() != TypeKind::Reference ||
      right_receiver_type->GetKind() != TypeKind::Reference) {
    return false;
  }
  const auto& left_receiver = static_cast<const ReferenceType&>(*left_receiver_type);
  const auto& right_receiver = static_cast<const ReferenceType&>(*right_receiver_type);
  if (left_receiver.GetMode() != right_receiver.GetMode()) {
    return false;
  }

  for (std::size_t index = 1; index < left.ParmVars.size(); ++index) {
    if (left.ParmVars[index]->type != right.ParmVars[index]->type) {
      return false;
    }
  }
  return true;
}

std::string FunctionRedefinitionMessage(const FunctionDecl& declaration) {
  switch (declaration.GetKind()) {
    case NodeKind::FunctionDecl:
    case NodeKind::VirtualFunctionDecl:
      BOOST_ASSERT(!declaration.name.empty());
      return IsOperatorFunctionName(declaration.name) ? fmt::format("redefinition of operator '{}'", declaration.name)
                                                      : fmt::format("redefinition of function '{}'", declaration.name);
    case NodeKind::ConstructorDecl:
      return "redefinition of constructor";
    case NodeKind::DestructorDecl:
      return "redefinition of destructor";
    default:
      BOOST_ASSERT(false && "unsupported function-like declaration kind");
      return {};
  }
}

const char* ReturnValueNotAllowedMessage(const FunctionDecl& declaration) {
  switch (declaration.GetKind()) {
    case NodeKind::ConstructorDecl:
      return "constructor cannot return a value";
    case NodeKind::DestructorDecl:
      return "destructor cannot return a value";
    default:
      return "void function cannot return a value";
  }
}

bool HasValidFunctionInterface(const FunctionDecl& declaration) {
  if (!declaration.type || declaration.type.GetTypePtr()->GetKind() != TypeKind::Function) {
    return false;
  }
  for (const auto& parameter : declaration.ParmVars) {
    if (!parameter || parameter->ContainsErrors() || !parameter->type || !parameter->attributes.empty()) {
      return false;
    }
  }
  if (declaration.ReturnVar) {
    if (declaration.ReturnVar->ContainsErrors() || !declaration.ReturnVar->type ||
        !declaration.ReturnVar->attributes.empty() ||
        (!declaration.ReturnVar->name.empty() && declaration.ReturnVar->type.GetTypePtr()->IsVoid())) {
      return false;
    }
  }

  switch (declaration.GetKind()) {
    case NodeKind::FunctionDecl:
    case NodeKind::VirtualFunctionDecl:
      return !declaration.name.empty();
    case NodeKind::ConstructorDecl:
      return static_cast<const ConstructorDecl&>(declaration).target_type && declaration.Body;
    case NodeKind::DestructorDecl:
      return static_cast<const DestructorDecl&>(declaration).target_type && declaration.Body &&
             declaration.ParmVars.empty();
    default:
      return false;
  }
}

enum class ConstructorPrologueStatus { NotRequired, Valid, InvalidAttempt, Missing };

enum class ConstructorInitializationTargetKind { Other, ValidPrologue, InvalidPrologue };

ConstructorInitializationTargetKind ClassifyConstructorInitializationTarget(const ConstructorDecl& constructor,
                                                                            const Expr* target) {
  if (!target || !constructor.target_type) {
    return ConstructorInitializationTargetKind::Other;
  }

  bool contains_parentheses = false;
  const auto ignore_parentheses = [&](const Expr* expression) {
    while (expression && expression->GetKind() == NodeKind::ParenExpr) {
      contains_parentheses = true;
      expression = static_cast<const ParenExpr*>(expression)->SubExpr.get();
    }
    return expression;
  };

  target = ignore_parentheses(target);
  if (!target) {
    return ConstructorInitializationTargetKind::Other;
  }
  if (target->GetKind() == NodeKind::ThisExpr) {
    return contains_parentheses ? ConstructorInitializationTargetKind::InvalidPrologue
                                : ConstructorInitializationTargetKind::ValidPrologue;
  }

  const Expr* root = target;
  std::vector<const Expr*> path;
  while (root && (root->GetKind() == NodeKind::MemberExpr || root->GetKind() == NodeKind::BaseSubobjectExpr)) {
    path.push_back(root);
    root = root->GetKind() == NodeKind::MemberExpr ? static_cast<const MemberExpr*>(root)->Base.get()
                                                   : static_cast<const BaseSubobjectExpr*>(root)->Base.get();
    root = ignore_parentheses(root);
  }
  if (!root || root->GetKind() != NodeKind::ThisExpr || path.empty()) {
    return ConstructorInitializationTargetKind::Other;
  }
  std::reverse(path.begin(), path.end());

  const Expr* first = path.front();
  if (first->GetKind() == NodeKind::BaseSubobjectExpr) {
    const auto& base = static_cast<const BaseSubobjectExpr&>(*first);
    const StructType* required_base = constructor.target_type->GetDeclaration()->base_type;
    const bool is_valid = !contains_parentheses && path.size() == 1 && target == first && base.op == expr::period &&
                          base.base_path.size() == 1 && required_base &&
                          base.GetDeclaration() == required_base->GetDeclaration();
    return is_valid ? ConstructorInitializationTargetKind::ValidPrologue
                    : ConstructorInitializationTargetKind::InvalidPrologue;
  }

  const FieldDecl* first_field = static_cast<const MemberExpr&>(*first).declaration;
  if (!first_field) {
    return ConstructorInitializationTargetKind::InvalidPrologue;
  }
  for (const auto& field : constructor.target_type->GetDeclaration()->Fields) {
    if (field.get() == first_field) {
      return ConstructorInitializationTargetKind::Other;
    }
  }
  return ConstructorInitializationTargetKind::InvalidPrologue;
}

ConstructorPrologueStatus ClassifyConstructorPrologue(const ConstructorDecl& declaration) {
  if (!declaration.target_type || !declaration.Body) {
    return ConstructorPrologueStatus::NotRequired;
  }
  const StructType* base_type = declaration.target_type->GetDeclaration()->base_type;
  if (!base_type || base_type->GetDeclaration()->triviality != TypeTriviality::NonTrivial) {
    return ConstructorPrologueStatus::NotRequired;
  }

  for (std::size_t index = 0; index < declaration.Body->Stmts.size(); ++index) {
    const auto& statement = declaration.Body->Stmts[index];
    if (!statement || statement->GetKind() != NodeKind::ExprStmt) {
      continue;
    }
    const auto& expression_statement = static_cast<const ExprStmt&>(*statement);
    if (!expression_statement.Expr) {
      continue;
    }
    const Expr* direct_expression = expression_statement.Expr.get();
    const Expr* recovered_expression = direct_expression->IgnoreParens();
    if (!recovered_expression || recovered_expression->GetKind() != NodeKind::InitializationExpr) {
      continue;
    }
    const auto& initialization = static_cast<const InitializationExpr&>(*recovered_expression);
    const ConstructorInitializationTargetKind target_kind =
        ClassifyConstructorInitializationTarget(declaration, initialization.Target.get());
    if (direct_expression == recovered_expression && index == 0 &&
        target_kind == ConstructorInitializationTargetKind::ValidPrologue) {
      return ConstructorPrologueStatus::Valid;
    }
    if (target_kind != ConstructorInitializationTargetKind::Other) {
      return ConstructorPrologueStatus::InvalidAttempt;
    }
  }
  return ConstructorPrologueStatus::Missing;
}

bool InitializationTargetContainsParentheses(const Expr* target) {
  while (target) {
    if (target->GetKind() == NodeKind::ParenExpr) {
      return true;
    }
    if (target->GetKind() == NodeKind::MemberExpr) {
      target = static_cast<const MemberExpr*>(target)->Base.get();
      continue;
    }
    if (target->GetKind() == NodeKind::BaseSubobjectExpr) {
      target = static_cast<const BaseSubobjectExpr*>(target)->Base.get();
      continue;
    }
    return false;
  }
  return false;
}

bool InitializationTargetContainsArrayElementProjection(const Expr* target) {
  while (target) {
    switch (target->GetKind()) {
      case NodeKind::SubscriptExpr:
        return true;
      case NodeKind::ParenExpr:
        target = static_cast<const ParenExpr*>(target)->SubExpr.get();
        break;
      case NodeKind::MemberExpr: {
        const auto& member = static_cast<const MemberExpr&>(*target);
        if (member.op != expr::period) {
          return false;
        }
        target = member.Base.get();
        break;
      }
      case NodeKind::BaseSubobjectExpr: {
        const auto& base = static_cast<const BaseSubobjectExpr&>(*target);
        if (base.op != expr::period) {
          return false;
        }
        target = base.Base.get();
        break;
      }
      case NodeKind::ImplicitCastExpr:
        target = static_cast<const ImplicitCastExpr*>(target)->SubExpr.get();
        break;
      case NodeKind::MaterializeTemporaryExpr:
        target = static_cast<const MaterializeTemporaryExpr*>(target)->SubExpr.get();
        break;
      default:
        return false;
    }
  }
  return false;
}

std::string DescribeInitializationTarget(const Expr& target) {
  switch (target.GetKind()) {
    case NodeKind::DeclRefExpr: {
      const ValueDecl* declaration = static_cast<const DeclRefExpr&>(target).declaration;
      if (!declaration || declaration->name.empty()) {
        break;
      }
      switch (declaration->GetKind()) {
        case NodeKind::VarDecl:
          return fmt::format("variable '{}'", declaration->name);
        case NodeKind::ParmVarDecl:
          return fmt::format("parameter '{}'", declaration->name);
        case NodeKind::ReturnVarDecl:
          return fmt::format("result object '{}'", declaration->name);
        default:
          break;
      }
      break;
    }
    case NodeKind::ThisExpr:
      return "the current object";
    case NodeKind::MemberExpr: {
      const FieldDecl* declaration = static_cast<const MemberExpr&>(target).declaration;
      if (declaration && !declaration->name.empty()) {
        return fmt::format("field '{}'", declaration->name);
      }
      break;
    }
    case NodeKind::BaseSubobjectExpr: {
      const StructDecl* declaration = static_cast<const BaseSubobjectExpr&>(target).GetDeclaration();
      if (declaration && !declaration->name.empty()) {
        return fmt::format("base subobject '{}'", declaration->name);
      }
      break;
    }
    default:
      break;
  }
  return "target";
}

bool HasFunctionResultObject(const FunctionDecl& declaration) {
  if (declaration.GetKind() == NodeKind::ConstructorDecl || declaration.GetKind() == NodeKind::DestructorDecl ||
      !declaration.ReturnVar) {
    return false;
  }
  return !declaration.ReturnVar->type || !declaration.ReturnVar->type.GetTypePtr()->IsVoid();
}

bool FitsSignedInteger(const cpp_int& value, unsigned bit_width) {
  const cpp_int boundary = cpp_int{1} << (bit_width - 1);
  return value >= -boundary && value < boundary;
}

bool FitsUnsignedInteger(const cpp_int& value, unsigned bit_width) {
  return value >= 0 && value < (cpp_int{1} << bit_width);
}

std::optional<cpp_int> EvaluateComptimeInteger(const Expr& expression) {
  if (!expression.type || expression.type.GetTypePtr()->GetKind() != TypeKind::ComptimeInt) {
    return std::nullopt;
  }

  switch (expression.GetKind()) {
    case NodeKind::IntegerLiteral:
      return static_cast<const IntegerLiteral&>(expression).value;
    case NodeKind::UnaryOperator: {
      const auto& unary_expression = static_cast<const UnaryOperator&>(expression);
      if (!unary_expression.Operand) {
        return std::nullopt;
      }
      auto value = EvaluateComptimeInteger(*unary_expression.Operand);
      if (!value) {
        return std::nullopt;
      }
      if (unary_expression.op == expr::plus) {
        return value;
      }
      if (unary_expression.op == expr::minus) {
        *value = -*value;
        return value;
      }
      return std::nullopt;
    }
    default:
      return std::nullopt;
  }
}

const BuiltinType* DefaultIntegerType(ASTContext& ast_context, const cpp_int& value) {
  if (FitsSignedInteger(value, 32)) {
    return ast_context.GetBuiltinType(BuiltinTypeKind::I32);
  }
  if (FitsSignedInteger(value, 64)) {
    return ast_context.GetBuiltinType(BuiltinTypeKind::I64);
  }
  if (FitsUnsignedInteger(value, 64)) {
    return ast_context.GetBuiltinType(BuiltinTypeKind::U64);
  }
  return nullptr;
}

bool IsArithmeticBinaryOperator(expr::ExprGrammarSymbol op) {
  switch (op) {
    case expr::plus:
    case expr::minus:
    case expr::star:
    case expr::slash:
    case expr::percent:
      return true;
    default:
      return false;
  }
}

bool IsOrderedComparisonOperator(expr::ExprGrammarSymbol op) {
  switch (op) {
    case expr::less:
    case expr::lessequal:
    case expr::greater:
    case expr::greaterequal:
      return true;
    default:
      return false;
  }
}

bool IsEqualityOperator(expr::ExprGrammarSymbol op) { return op == expr::equalequal || op == expr::exclaimequal; }

bool IsLogicalBinaryOperator(expr::ExprGrammarSymbol op) { return op == expr::ampamp || op == expr::pipepipe; }

bool IsPointerValueType(QualType type) {
  return type && (type.GetTypePtr()->AsPointerType() || type.GetTypePtr()->AsVirtualSlotType());
}

bool IsRawPointerType(QualType type) {
  const auto* pointer = type ? type.GetTypePtr()->AsPointerType() : nullptr;
  return pointer && !pointer->GetPointee().GetTypePtr()->AsFunctionType();
}

QualType CommonPointerValueType(ASTContext& ast_context, QualType left, QualType right) {
  if (left && left.GetTypePtr()->AsNullType() && IsPointerValueType(right)) {
    return right.WithoutConst();
  }
  if (right && right.GetTypePtr()->AsNullType() && IsPointerValueType(left)) {
    return left.WithoutConst();
  }
  return QualType(CommonPointerType(ast_context, left, right));
}

bool IsOverloadableUnaryOperator(expr::ExprGrammarSymbol op) {
  return op == expr::plus || op == expr::minus || op == expr::exclaim;
}

bool IsOverloadableBinaryOperator(expr::ExprGrammarSymbol op) {
  return IsArithmeticBinaryOperator(op) || IsOrderedComparisonOperator(op) || IsEqualityOperator(op);
}

bool IsStructObjectOperand(const Expr& expression) {
  return expression.type && expression.value_category != ValueCategory::None &&
         expression.type.WithoutConst().GetTypePtr()->GetKind() == TypeKind::Struct;
}

enum class VirtualReturnCompatibilityKind {
  Exact,
  CovariantPointer,
  CovariantReference,
};

enum class VirtualReturnFailureKind {
  UnsupportedShape,
  PointerReferenceMismatch,
  NotDerived,
  DiscardsPointeeConst,
  ReferenceCategoryMismatch,
  ReferencePermissionMismatch,
};

using VirtualReturnCompatibilityResult = std::variant<VirtualReturnCompatibilityKind, VirtualReturnFailureKind>;

VirtualReturnCompatibilityResult ClassifyVirtualReturnCompatibility(const Type* overridden_return,
                                                                    const Type* overriding_return) {
  const auto success = [](VirtualReturnCompatibilityKind kind) -> VirtualReturnCompatibilityResult { return kind; };
  const auto failure = [](VirtualReturnFailureKind kind) -> VirtualReturnCompatibilityResult { return kind; };

  if (!overridden_return || !overriding_return) {
    return failure(VirtualReturnFailureKind::UnsupportedShape);
  }
  if (overridden_return == overriding_return) {
    return success(VirtualReturnCompatibilityKind::Exact);
  }

  const bool overridden_is_pointer = overridden_return->GetKind() == TypeKind::Pointer;
  const bool overriding_is_pointer = overriding_return->GetKind() == TypeKind::Pointer;
  const bool overridden_is_reference = overridden_return->GetKind() == TypeKind::Reference;
  const bool overriding_is_reference = overriding_return->GetKind() == TypeKind::Reference;

  if ((overridden_is_pointer && overriding_is_reference) || (overridden_is_reference && overriding_is_pointer)) {
    return failure(VirtualReturnFailureKind::PointerReferenceMismatch);
  }

  if (overridden_is_pointer && overriding_is_pointer) {
    const QualType overridden_pointee = static_cast<const PointerType*>(overridden_return)->GetPointee();
    const QualType overriding_pointee = static_cast<const PointerType*>(overriding_return)->GetPointee();
    if (!overridden_pointee || !overriding_pointee || overridden_pointee.GetTypePtr()->GetKind() != TypeKind::Struct ||
        overriding_pointee.GetTypePtr()->GetKind() != TypeKind::Struct) {
      return failure(VirtualReturnFailureKind::UnsupportedShape);
    }

    const Type* overridden_object = overridden_pointee.GetTypePtr();
    const Type* overriding_object = overriding_pointee.GetTypePtr();
    if (overriding_object != overridden_object && !FindDerivedToBasePath(overriding_object, overridden_object)) {
      return failure(VirtualReturnFailureKind::NotDerived);
    }
    if (overriding_pointee.IsConstQualified() && !overridden_pointee.IsConstQualified()) {
      return failure(VirtualReturnFailureKind::DiscardsPointeeConst);
    }
    return success(VirtualReturnCompatibilityKind::CovariantPointer);
  }

  if (overridden_is_reference && overriding_is_reference) {
    const auto& overridden_reference = static_cast<const ReferenceType&>(*overridden_return);
    const auto& overriding_reference = static_cast<const ReferenceType&>(*overriding_return);
    const Type* overridden_object = overridden_reference.GetReferentType();
    const Type* overriding_object = overriding_reference.GetReferentType();
    if (!overridden_object || !overriding_object || overridden_object->GetKind() != TypeKind::Struct ||
        overriding_object->GetKind() != TypeKind::Struct) {
      return failure(VirtualReturnFailureKind::UnsupportedShape);
    }
    if (overriding_object != overridden_object && !FindDerivedToBasePath(overriding_object, overridden_object)) {
      return failure(VirtualReturnFailureKind::NotDerived);
    }

    const ReferenceMode overridden_mode = overridden_reference.GetMode();
    const ReferenceMode overriding_mode = overriding_reference.GetMode();
    if ((overridden_mode == ReferenceMode::Move) != (overriding_mode == ReferenceMode::Move)) {
      return failure(VirtualReturnFailureKind::ReferenceCategoryMismatch);
    }
    if (overridden_mode == ReferenceMode::Mut && overriding_mode == ReferenceMode::Copy) {
      return failure(VirtualReturnFailureKind::ReferencePermissionMismatch);
    }
    return success(VirtualReturnCompatibilityKind::CovariantReference);
  }

  return failure(VirtualReturnFailureKind::UnsupportedShape);
}

enum class CallCandidateMode {
  Regular,
  NonVirtual,
};

std::vector<const FunctionDecl*> CollectFunctionCallCandidates(const FunctionSymbol& symbol, const std::string& name,
                                                               CallCandidateMode mode) {
  std::vector<const FunctionDecl*> result;
  const bool is_operator = IsOperatorFunctionName(name);
  for (const FunctionDecl* declaration : symbol.Declarations()) {
    if (!declaration || declaration->is_invalid || declaration->name != name || !declaration->type ||
        declaration->type.GetTypePtr()->GetKind() != TypeKind::Function) {
      continue;
    }

    // An explicit operator call names only ordinary user-defined operator
    // functions. It does not introduce virtual substitution or built-in
    // candidates.
    if (is_operator) {
      if (mode == CallCandidateMode::Regular && declaration->GetKind() == NodeKind::FunctionDecl) {
        result.push_back(declaration);
      }
      continue;
    }

    if (declaration->GetKind() == NodeKind::VirtualFunctionDecl) {
      if (mode == CallCandidateMode::Regular) {
        result.push_back(declaration);
      }
      continue;
    }
    if (declaration->GetKind() != NodeKind::FunctionDecl) {
      continue;
    }

    // FunctionSymbol retains the bound ordinary definition. Normal calls use
    // the associated virtual interface as their static declaration identity.
    const FunctionDecl* call_declaration = declaration;
    if (mode == CallCandidateMode::Regular && declaration->virtual_declaration) {
      call_declaration = declaration->virtual_declaration;
    }
    if (!call_declaration->is_invalid) {
      result.push_back(call_declaration);
    }
  }
  return result;
}

bool HasInvalidFunctionDeclaration(const FunctionSymbol& symbol, const std::string& name) {
  const auto& declarations = symbol.Declarations();
  return std::any_of(declarations.begin(), declarations.end(), [&](const FunctionDecl* declaration) {
    return declaration && declaration->name == name && declaration->is_invalid;
  });
}

bool HasInvalidTopLevelOperatorFunctionDeclaration(const TranslationUnitDecl& translation_unit,
                                                   const std::string& name) {
  return std::any_of(translation_unit.Decls.begin(), translation_unit.Decls.end(), [&](const auto& declaration) {
    if (!declaration || declaration->GetKind() != NodeKind::FunctionDecl) {
      return false;
    }
    const auto& function = static_cast<const FunctionDecl&>(*declaration);
    return function.name == name && function.is_invalid;
  });
}

std::vector<const FunctionDecl*> CollectCompleteFunctionCandidates(const FunctionSymbol& symbol,
                                                                   const std::string& name, NodeKind expected_kind) {
  std::vector<const FunctionDecl*> result;
  for (const FunctionDecl* declaration : symbol.Declarations()) {
    if (!declaration || declaration->is_invalid || declaration->GetKind() != expected_kind ||
        declaration->name != name || !declaration->type ||
        declaration->type.GetTypePtr()->GetKind() != TypeKind::Function) {
      continue;
    }
    result.push_back(declaration);
  }
  return result;
}

std::vector<const FunctionDecl*> CollectOperatorFunctionCandidates(const FunctionSymbol& symbol, const std::string& op,
                                                                   std::size_t arity) {
  std::vector<const FunctionDecl*> result;
  for (const FunctionDecl* declaration : symbol.Declarations()) {
    if (!declaration || declaration->is_invalid || declaration->GetKind() != NodeKind::FunctionDecl ||
        declaration->name != op || !declaration->type ||
        declaration->type.GetTypePtr()->GetKind() != TypeKind::Function) {
      continue;
    }
    const auto& function_type = static_cast<const FunctionType&>(*declaration->type.GetTypePtr());
    if (function_type.GetParameterTypes().size() == arity) {
      result.push_back(declaration);
    }
  }
  return result;
}

std::string TypeSpelling(QualType type);

std::string TypeSpelling(const Type& type) {
  switch (type.GetKind()) {
    case TypeKind::ComptimeInt:
      return "comptime_int";
    case TypeKind::Null:
      return "<null>";
    case TypeKind::FunctionOverloadSet:
    case TypeKind::AddressOfFunctionOverloadSet:
      // These expressions have no source-level type spelling.
      break;
    case TypeKind::Builtin:
      return to_string(static_cast<const BuiltinType&>(type).GetBuiltinTypeKind());
    case TypeKind::Struct:
      return static_cast<const StructType&>(type).GetDeclaration()->name;
    case TypeKind::Array: {
      const auto& array = static_cast<const ArrayType&>(type);
      return fmt::format("[{}] {}", array.GetLength(), TypeSpelling(array.GetElementType()));
    }
    case TypeKind::Pointer:
      return "*" + TypeSpelling(static_cast<const PointerType&>(type).GetPointee());
    case TypeKind::VirtualSlot:
      return "virtual " + TypeSpelling(QualType(static_cast<const VirtualSlotType&>(type).GetEntryPointerType()));
    case TypeKind::Function: {
      const auto& function_type = static_cast<const FunctionType&>(type);
      std::string result = "func (";
      const auto& parameter_types = function_type.GetParameterTypes();
      for (std::size_t index = 0; index < parameter_types.size(); ++index) {
        if (index != 0) {
          result += ", ";
        }
        result += TypeSpelling(*parameter_types[index]);
      }
      result += ") ";
      result += TypeSpelling(*function_type.GetReturnType());
      return result;
    }
    case TypeKind::Reference: {
      const auto& reference_type = static_cast<const ReferenceType&>(type);
      const char* prefix = nullptr;
      switch (reference_type.GetMode()) {
        case ReferenceMode::Mut:
          prefix = "mut ";
          break;
        case ReferenceMode::Copy:
          prefix = "copy ";
          break;
        case ReferenceMode::Move:
          prefix = "move ";
          break;
      }
      return std::string(prefix) + TypeSpelling(*reference_type.GetReferentType());
    }
  }
  BOOST_ASSERT(false && "type has no source-level spelling");
  return {};
}

std::string TypeSpelling(QualType type) {
  if (!type) {
    return "<invalid>";
  }
  std::string result = TypeSpelling(*type.GetTypePtr());
  if (type.IsConstQualified()) {
    result = "const " + result;
  }
  return result;
}

const char* FunctionExpressionDescription(QualType type) {
  if (type && type.GetTypePtr()->AsFunctionOverloadSetType()) {
    return "a function name";
  }
  if (type && type.GetTypePtr()->AsAddressOfFunctionOverloadSetType()) {
    return "a function address without a target type";
  }
  return nullptr;
}

// Keep real type spellings, but describe unresolved functions as expressions.
// The prefix applies only to a type, so diagnostics do not call a function name
// a type or an object value.
std::string DescribeExpressionType(QualType type, std::string_view type_prefix = "") {
  if (const char* description = FunctionExpressionDescription(type)) {
    return description;
  }
  return fmt::format("{}'{}'", type_prefix, TypeSpelling(type));
}

std::string DescribeOperandTypes(QualType left, QualType right, std::string_view type_prefix = "") {
  if (FunctionExpressionDescription(left) || FunctionExpressionDescription(right)) {
    return fmt::format("{} and {}", DescribeExpressionType(left, "type "), DescribeExpressionType(right, "type "));
  }
  return fmt::format("{}'{}' and '{}'", type_prefix, TypeSpelling(left), TypeSpelling(right));
}

const Type* VirtualReturnObjectType(const Type* type) {
  if (!type) {
    return nullptr;
  }
  if (type->GetKind() == TypeKind::Pointer) {
    return static_cast<const PointerType*>(type)->GetPointee().GetTypePtr();
  }
  if (type->GetKind() == TypeKind::Reference) {
    return static_cast<const ReferenceType*>(type)->GetReferentType();
  }
  return nullptr;
}

std::string FormatVirtualReturnFailure(const FunctionDecl& function, const FunctionDecl& overridden,
                                       VirtualReturnFailureKind failure) {
  const Type* overriding_return = FunctionReturnType(function);
  const Type* overridden_return = FunctionReturnType(overridden);
  BOOST_ASSERT(overriding_return);
  BOOST_ASSERT(overridden_return);

  std::string message =
      fmt::format("return type '{}' of virtual function '{}' is not covariant with overridden return type '{}'",
                  TypeSpelling(*overriding_return), function.name, TypeSpelling(*overridden_return));
  switch (failure) {
    case VirtualReturnFailureKind::UnsupportedShape:
      return message + "; only direct object pointer and reference return types may be covariant";
    case VirtualReturnFailureKind::PointerReferenceMismatch:
      return message + " because one return type is a pointer and the other is a reference";
    case VirtualReturnFailureKind::NotDerived: {
      const Type* overriding_object = VirtualReturnObjectType(overriding_return);
      const Type* overridden_object = VirtualReturnObjectType(overridden_return);
      BOOST_ASSERT(overriding_object);
      BOOST_ASSERT(overridden_object);
      return message + fmt::format(" because '{}' is not derived from '{}'", TypeSpelling(*overriding_object),
                                   TypeSpelling(*overridden_object));
    }
    case VirtualReturnFailureKind::DiscardsPointeeConst:
      return message + " because it would remove pointee 'const'";
    case VirtualReturnFailureKind::ReferenceCategoryMismatch:
      return message + " because their reference categories differ";
    case VirtualReturnFailureKind::ReferencePermissionMismatch:
      return message + " because a 'copy' return cannot satisfy the overridden 'mut' return";
  }
  BOOST_ASSERT(false && "unsupported virtual return failure kind");
  return message;
}

const char* ValueCategorySpelling(ValueCategory category) {
  switch (category) {
    case ValueCategory::LValue:
      return "lvalue";
    case ValueCategory::MoveLValue:
      return "move lvalue";
    case ValueCategory::PureRValue:
      return "pure rvalue";
    case ValueCategory::None:
      return "non-value expression";
  }
  BOOST_ASSERT(false && "unsupported value category");
  return "expression";
}

std::string FormatImplicitConversionFailure(const ImplicitConversionFailure& failure) {
  if (failure.kind == ImplicitConversionFailureKind::DiscardsConst) {
    return fmt::format("conversion from {} to '{}' would discard const", DescribeExpressionType(failure.source_type),
                       TypeSpelling(failure.target_type));
  }
  return fmt::format("no implicit conversion from {} to '{}'", DescribeExpressionType(failure.source_type),
                     TypeSpelling(failure.target_type));
}

std::string FormatReferenceBindingFailure(const ReferenceBindingFailure& failure) {
  BOOST_ASSERT(failure.target_type);
  const std::string target = TypeSpelling(*failure.target_type);
  switch (failure.kind) {
    case ReferenceBindingFailureKind::ReferentTypeMismatch:
      return fmt::format("reference type '{}' cannot bind to a value of type '{}'", target,
                         TypeSpelling(failure.source_type));
    case ReferenceBindingFailureKind::ModeMismatch:
      if (failure.source_type.IsConstQualified()) {
        return fmt::format("binding a reference of type '{}' to a value of type '{}' would discard const", target,
                           TypeSpelling(failure.source_type));
      }
      return fmt::format("reference type '{}' cannot bind to {} of type '{}'", target,
                         ValueCategorySpelling(failure.source_category), TypeSpelling(failure.source_type));
    case ReferenceBindingFailureKind::NotBindableValue:
      return fmt::format("{} does not produce a value that can bind to reference type '{}'",
                         DescribeExpressionType(failure.source_type, "expression of type "), target);
  }
  BOOST_ASSERT(false && "unsupported reference binding failure");
  return "reference binding failed";
}

std::string FormatObjectFormationFailure(const ObjectFormationFailure& failure) {
  switch (failure.kind) {
    case ObjectFormationFailureKind::CopyUnavailable:
      return fmt::format("no copy constructor is available for '{}'", TypeSpelling(failure.target_type));
    case ObjectFormationFailureKind::MoveAndCopyUnavailable:
      return fmt::format("no move or copy constructor is available for '{}'", TypeSpelling(failure.target_type));
  }
  BOOST_ASSERT(false && "unsupported object formation failure");
  return "object construction failed";
}

/// \brief The fixed same-type assignment operation.
enum class ObjectAssignmentKind {
  Builtin,
  OperatorCall,
  ArrayAssign,
};

/// \brief The already selected special assignment slot, if one is required.
struct ObjectAssignmentPlan {
  ObjectAssignmentKind kind{ObjectAssignmentKind::Builtin};
  const FunctionDecl* selected_assignment{};
};

/// \brief A reason the dedicated object assignment operation is unavailable.
enum class ObjectAssignmentFailureKind {
  InvalidObjectType,
  NotObjectValue,
  ConstArrayElement,
  CopyUnavailable,
  MoveAndCopyUnavailable,
  SelectedAssignmentNotUsable,
};

/// \brief Assignment-specific facts used by outer diagnostics.
struct ObjectAssignmentFailure {
  ObjectAssignmentFailureKind kind{ObjectAssignmentFailureKind::InvalidObjectType};
  QualType source_type{};
  QualType target_type{};
  QualType operation_type{};
  ValueCategory source_category{ValueCategory::None};
  bool is_array{};
  std::size_t parameter_index{};
  std::optional<ReferenceBindingFailure> binding_failure{};
};

using ObjectAssignmentResult = std::variant<ObjectAssignmentPlan, ObjectAssignmentFailure>;

const TypeSymbol* TypeSymbolForObjectType(QualType type, const SymbolTable& symbol_table) {
  if (!type || type.GetTypePtr()->GetKind() != TypeKind::Struct) {
    return nullptr;
  }
  const StructDecl* declaration = static_cast<const StructType*>(type.GetTypePtr())->GetDeclaration();
  if (!declaration) {
    return nullptr;
  }
  const TypeSymbol* symbol = AsTypeSymbol(symbol_table.LookupRoot(declaration->name));
  return symbol && symbol->GetDeclaration() == declaration ? symbol : nullptr;
}

/// \brief Leaf types and const restrictions for ordinary or array assignment.
struct ObjectOperationTypes {
  QualType source_leaf_type{};
  QualType target_leaf_type{};
  QualType const_target_element_type{};
  bool is_array{};
};

std::optional<ObjectOperationTypes> DecomposeObjectOperationTypes(QualType source_type, QualType target_type) {
  ObjectOperationTypes result{source_type, target_type};
  while (result.target_leaf_type && result.target_leaf_type.GetTypePtr()->GetKind() == TypeKind::Array) {
    result.is_array = true;
    if (!result.source_leaf_type || result.source_leaf_type.GetTypePtr()->GetKind() != TypeKind::Array) {
      return std::nullopt;
    }

    const auto* source_array = static_cast<const ArrayType*>(result.source_leaf_type.GetTypePtr());
    const auto* target_array = static_cast<const ArrayType*>(result.target_leaf_type.GetTypePtr());
    QualType source_element_type = source_array->GetElementType();
    if (result.source_leaf_type.IsConstQualified()) {
      source_element_type = source_element_type.WithConst();
    }
    result.source_leaf_type = source_element_type;
    result.target_leaf_type = target_array->GetElementType();
    if (!result.const_target_element_type && result.target_leaf_type.IsConstQualified()) {
      result.const_target_element_type = result.target_leaf_type;
    }
  }
  if (result.source_leaf_type && result.source_leaf_type.GetTypePtr()->GetKind() == TypeKind::Array) {
    return std::nullopt;
  }
  return result;
}

ObjectAssignmentResult ClassifyObjectAssignment(const Expr& destination, const Expr& source,
                                                const SymbolTable& symbol_table) {
  BOOST_ASSERT(destination.type && source.type);
  BOOST_ASSERT(destination.type.WithoutConst() == source.type.WithoutConst());
  BOOST_ASSERT((destination.type && destination.type.GetTypePtr()->IsObject()));

  ObjectAssignmentFailure failure;
  failure.source_type = source.type;
  failure.target_type = destination.type;
  failure.source_category = source.value_category;
  if (source.value_category != ValueCategory::LValue && source.value_category != ValueCategory::MoveLValue &&
      source.value_category != ValueCategory::PureRValue) {
    failure.kind = ObjectAssignmentFailureKind::NotObjectValue;
    return failure;
  }

  const TypeTriviality triviality = destination.type.GetTypePtr()->GetTriviality();
  if (triviality == TypeTriviality::Unknown || triviality == TypeTriviality::Invalid) {
    failure.kind = ObjectAssignmentFailureKind::InvalidObjectType;
    return failure;
  }

  const auto operation_types = DecomposeObjectOperationTypes(source.type, destination.type);
  if (!operation_types) {
    failure.kind = ObjectAssignmentFailureKind::InvalidObjectType;
    return failure;
  }
  failure.is_array = operation_types->is_array;
  if (operation_types->const_target_element_type) {
    failure.kind = ObjectAssignmentFailureKind::ConstArrayElement;
    failure.operation_type = operation_types->const_target_element_type;
    return failure;
  }

  if (triviality == TypeTriviality::Trivial) {
    return ObjectAssignmentPlan{};
  }
  if (!operation_types->target_leaf_type ||
      operation_types->target_leaf_type.GetTypePtr()->GetKind() != TypeKind::Struct) {
    failure.kind = ObjectAssignmentFailureKind::InvalidObjectType;
    return failure;
  }
  failure.operation_type = operation_types->target_leaf_type.WithoutConst();

  const TypeSymbol* type_symbol = TypeSymbolForObjectType(failure.operation_type, symbol_table);
  const bool prefers_move =
      !operation_types->source_leaf_type.IsConstQualified() &&
      (source.value_category == ValueCategory::MoveLValue || source.value_category == ValueCategory::PureRValue);
  const FunctionDecl* selected = type_symbol && prefers_move ? type_symbol->GetMoveAssignment() : nullptr;
  if (!selected && type_symbol) {
    selected = type_symbol->GetCopyAssignment();
  }
  if (!selected) {
    failure.kind = prefers_move ? ObjectAssignmentFailureKind::MoveAndCopyUnavailable
                                : ObjectAssignmentFailureKind::CopyUnavailable;
    return failure;
  }

  if (!selected->type || selected->type.GetTypePtr()->GetKind() != TypeKind::Function) {
    failure.kind = ObjectAssignmentFailureKind::SelectedAssignmentNotUsable;
    return failure;
  }
  const auto& parameter_types = static_cast<const FunctionType*>(selected->type.GetTypePtr())->GetParameterTypes();
  if (parameter_types.size() != 2 || !parameter_types[0] || !parameter_types[1] ||
      parameter_types[0]->GetKind() != TypeKind::Reference || parameter_types[1]->GetKind() != TypeKind::Reference) {
    failure.kind = ObjectAssignmentFailureKind::SelectedAssignmentNotUsable;
    return failure;
  }

  // Assignment slots were validated against these exact leaf types when
  // declarations were bound. Arrays use the same operation for every leaf.
  for (std::size_t index = 0; index < 2; ++index) {
    const auto* reference = parameter_types[index]->AsReferenceType();
    const QualType argument_type = index == 0 ? operation_types->target_leaf_type : operation_types->source_leaf_type;
    const auto category = index == 0 ? ValueCategory::LValue : source.value_category;
    const bool bindable = reference->GetMode() == ReferenceMode::Copy ||
                          (!argument_type.IsConstQualified() &&
                           (reference->GetMode() == ReferenceMode::Mut ? category == ValueCategory::LValue
                                                                       : category != ValueCategory::LValue));
    if (reference->GetReferentType() != argument_type.GetTypePtr() || !bindable) {
      failure.kind = ObjectAssignmentFailureKind::SelectedAssignmentNotUsable;
      failure.parameter_index = index + 1;
      failure.binding_failure = ReferenceBindingFailure{reference->GetReferentType() != argument_type.GetTypePtr()
                                                            ? ReferenceBindingFailureKind::ReferentTypeMismatch
                                                            : ReferenceBindingFailureKind::ModeMismatch,
                                                        argument_type, category, reference};
      return failure;
    }
  }
  return ObjectAssignmentPlan{failure.is_array ? ObjectAssignmentKind::ArrayAssign : ObjectAssignmentKind::OperatorCall,
                              selected};
}

std::string FormatObjectAssignmentFailure(const ObjectAssignmentFailure& failure) {
  switch (failure.kind) {
    case ObjectAssignmentFailureKind::InvalidObjectType:
      return fmt::format("cannot assign object of invalid type '{}'", TypeSpelling(failure.target_type));
    case ObjectAssignmentFailureKind::NotObjectValue:
      return fmt::format("{} does not produce an object value",
                         DescribeExpressionType(failure.source_type, "expression of type "));
    case ObjectAssignmentFailureKind::ConstArrayElement:
      return fmt::format("cannot assign an array with const-qualified element type '{}'",
                         TypeSpelling(failure.operation_type));
    case ObjectAssignmentFailureKind::CopyUnavailable:
      return fmt::format("no copy assignment declared for {} '{}'", failure.is_array ? "array element type" : "type",
                         TypeSpelling(failure.operation_type));
    case ObjectAssignmentFailureKind::MoveAndCopyUnavailable:
      return fmt::format("no copy or move assignment declared for {} '{}'",
                         failure.is_array ? "array element type" : "type", TypeSpelling(failure.operation_type));
    case ObjectAssignmentFailureKind::SelectedAssignmentNotUsable:
      if (failure.is_array) {
        return fmt::format("array element assignment for type '{}' is not usable",
                           TypeSpelling(failure.operation_type));
      }
      if (failure.binding_failure) {
        return fmt::format("cannot initialize parameter {} of assignment operator '=': {}", failure.parameter_index,
                           FormatReferenceBindingFailure(*failure.binding_failure));
      }
      return fmt::format("assignment operator '=' for type '{}' is not usable", TypeSpelling(failure.operation_type));
  }
  BOOST_ASSERT(false && "unsupported object assignment failure");
  return "object assignment failed";
}

std::string AddressedFunctionSpelling(const OverloadSetSelectionFailure& failure) {
  return IsOperatorFunctionName(failure.name) ? fmt::format("operator '{}'", failure.name)
                                              : fmt::format("function '{}'", failure.name);
}

std::string FormatOverloadSetSelectionFailure(const OverloadSetSelectionFailure& failure) {
  switch (failure.kind) {
    case OverloadSetSelectionFailureKind::MissingTarget:
      return fmt::format("address of {} requires a target function pointer type", AddressedFunctionSpelling(failure));
    case OverloadSetSelectionFailureKind::InvalidTarget:
      return fmt::format("target type '{}' is not a function pointer type", TypeSpelling(failure.target_type));
    case OverloadSetSelectionFailureKind::NoMatch:
      return IsOperatorFunctionName(failure.name) ? fmt::format("no operator '{}' has address type '{}'", failure.name,
                                                                TypeSpelling(failure.target_type))
                                                  : fmt::format("no function named '{}' has address type '{}'",
                                                                failure.name, TypeSpelling(failure.target_type));
    case OverloadSetSelectionFailureKind::Ambiguous:
      return fmt::format("address of {} is ambiguous for type '{}'", AddressedFunctionSpelling(failure),
                         TypeSpelling(failure.target_type));
  }
  BOOST_ASSERT(false && "unsupported overload-set selection failure");
  return "function address selection failed";
}

std::string FormatConversionFailure(const ConversionFailure& failure) {
  return std::visit(
      [](const auto& reason) -> std::string {
        using Failure = std::decay_t<decltype(reason)>;
        if constexpr (std::is_same_v<Failure, ImplicitConversionFailure>) {
          return FormatImplicitConversionFailure(reason);
        } else if constexpr (std::is_same_v<Failure, ReferenceBindingFailure>) {
          return FormatReferenceBindingFailure(reason);
        } else {
          return FormatOverloadSetSelectionFailure(reason);
        }
      },
      failure);
}

std::vector<const Expr*> ExpressionPointers(const std::vector<std::unique_ptr<Expr>>& expressions) {
  std::vector<const Expr*> result;
  result.reserve(expressions.size());
  for (const auto& expression : expressions) {
    BOOST_ASSERT(expression);
    result.push_back(expression.get());
  }
  return result;
}

void WrapInImplicitCast(std::unique_ptr<Expr>& expression, QualType target_type,
                        ImplicitConversionKind conversion_kind) {
  BOOST_ASSERT(expression);
  BOOST_ASSERT(target_type);
  BOOST_ASSERT(conversion_kind != ImplicitConversionKind::Invalid);
  BOOST_ASSERT(conversion_kind != ImplicitConversionKind::Identity);

  auto cast = std::make_unique<ImplicitCastExpr>();
  cast->range = expression->range;
  cast->type = target_type.WithoutConst();
  cast->value_category = ValueCategory::PureRValue;
  cast->conversion_kind = conversion_kind;
  cast->SubExpr = std::move(expression);
  expression = std::move(cast);
}

void ApplyDefaultValueConversion(std::unique_ptr<Expr>& expression) {
  BOOST_ASSERT(expression);
  BOOST_ASSERT(expression->type);

  if (expression->value_category != ValueCategory::LValue && expression->value_category != ValueCategory::MoveLValue) {
    return;
  }
  if (!expression->type.GetTypePtr()->IsScalar()) {
    return;
  }

  WrapInImplicitCast(expression, expression->type.WithoutConst(), ImplicitConversionKind::LValueToRValue);
}

void MaterializeObject(std::unique_ptr<Expr>& expression) {
  BOOST_ASSERT(expression && expression->value_category == ValueCategory::PureRValue);
  auto materialization = std::make_unique<MaterializeTemporaryExpr>();
  materialization->range = expression->range;
  materialization->type = expression->type;
  materialization->value_category = ValueCategory::MoveLValue;
  materialization->SubExpr = std::move(expression);
  expression = std::move(materialization);
}

void InheritErrors(Node& parent, const Node* child) {
  if (child) {
    parent.contains_errors |= child->ContainsErrors();
  }
}

class ContainsErrorPropagationVisitor final : public ASTVisitor {
  std::vector<Node*> stack_;

 public:
  void Visit(Node& node) override {
    Node* parent = stack_.empty() ? nullptr : stack_.back();
    stack_.push_back(&node);
    node.Traverse(*this);
    stack_.pop_back();
    if (parent) {
      InheritErrors(*parent, &node);
    }
  }
};

/// Closes the aggregate contains-errors metadata over the owning AST subtree.
///
/// Recursive Sema normally propagates errors while returning from a child.
/// Analyses that report findings after that traversal need this monotonic
/// postorder finalization before the Semantic AST is consumed.
void PropagateContainsErrors(Node& root) {
  ContainsErrorPropagationVisitor visitor;
  root.Accept(visitor);
}

std::string DefiniteInitializationMessage(const DefiniteInitializationFinding& finding) {
  BOOST_ASSERT(finding.declaration || finding.this_owner);
  const std::string name = finding.declaration ? finding.declaration->name : std::string("this");
  switch (finding.kind) {
    case DefiniteInitializationFindingKind::UninitializedRead:
      return fmt::format("use of uninitialized variable '{}'", name);
    case DefiniteInitializationFindingKind::RepeatedInitialization:
      return fmt::format("repeated initialization of variable '{}'", name);
    case DefiniteInitializationFindingKind::OutOfOrderInitialization:
      return fmt::format("cannot initialize before preceding variable '{}' is fully initialized", name);
    case DefiniteInitializationFindingKind::OutOfOrderSubobjectInitialization:
      return fmt::format("cannot initialize subobject of '{}' before preceding subobjects are fully initialized", name);
    case DefiniteInitializationFindingKind::ConflictingStates:
      return fmt::format("initialization state of variable '{}' differs across control-flow paths", name);
    case DefiniteInitializationFindingKind::UninitializedResult:
      if (!finding.declaration) {
        return "object 'this' is not fully initialized on this path";
      }
      if (finding.declaration->GetKind() == NodeKind::ReturnVarDecl) {
        return name.empty() ? "function return object is not initialized on this path"
                            : fmt::format("return object '{}' is not initialized on this path", name);
      }
      return fmt::format("variable '{}' is not initialized when its initializer block exits", name);
  }
  BOOST_ASSERT(false && "unsupported definite-initialization finding");
  return {};
}

}  // namespace

void Sema::SetDiagnosticEngine(DiagnosticEngine* diagnostic_engine) { diagnostic_engine_ = diagnostic_engine; }

void Sema::SetSources(const std::vector<Source>* sources) { sources_ = sources; }

void Sema::SetASTContext(ASTContext* ast_context) { ast_context_ = ast_context; }

void Sema::ResetRunState() {
  symbol_table_ = SymbolTable{};
  global_variables_.clear();
  loop_depth_ = 0;
  current_function_ = nullptr;
}

void Sema::operator()() {
  BOOST_ASSERT(diagnostic_engine_);
  BOOST_ASSERT(sources_);
  BOOST_ASSERT(ast_context_);

  TranslationUnitDecl* translation_unit = ast_context_->GetTranslationUnitDecl();
  BOOST_ASSERT(translation_unit);

  // Establish type identities and callable interfaces before analyzing any body.
  ResetRunState();
  ResolveTypeStructures(*translation_unit);
  InheritedVirtualSlots inherited_virtual_slots = CompleteTypeSemantics(*translation_unit);
  CompleteCallableInterfaces(*translation_unit, inherited_virtual_slots);
  AnalyzeDeclarationBodies(*translation_unit);

  // Cross-body and control-flow findings must feed the final subtree error aggregation.
  FinalizeTranslationUnitSemantics(*translation_unit);
}

Sema::InheritedVirtualSlots Sema::CompleteTypeSemantics(TranslationUnitDecl& translation_unit) {
  ValidateVirtualDeclarationInterfaces(translation_unit);
  InheritedVirtualSlots inherited_virtual_slots = ValidateVirtualHierarchy(translation_unit);
  ValidateTypeDeclarationAbstractUses(translation_unit);
  LifecycleDeclarations lifecycle_declarations = ResolveLifecycleDeclarationInterfaces(translation_unit);
  BindLifecycleDeclarations(translation_unit);
  ComputeStructTriviality(translation_unit, lifecycle_declarations);
  ValidateLifecycleRequirements(translation_unit, lifecycle_declarations);
  return inherited_virtual_slots;
}

void Sema::CompleteCallableInterfaces(TranslationUnitDecl& translation_unit,
                                      const InheritedVirtualSlots& inherited_slots) {
  ResolveCallableInterfaces(translation_unit);
  BindCallableDeclarations(translation_unit);
  AssociateVirtualDefinitions(translation_unit);
  ValidateRequiredOverrideDeclarations(translation_unit, inherited_slots);
}

void Sema::FinalizeTranslationUnitSemantics(TranslationUnitDecl& translation_unit) {
  ValidateDelegatingConstructorCycles(translation_unit);
  AnalyzeDefiniteInitialization(translation_unit);
  PropagateContainsErrors(translation_unit);
}

void Sema::DiagnoseFunctionAddressFailure(Node& owner, const SourceRange& range,
                                          const OverloadSetSelectionFailure& failure) {
  Diagnose(owner, kErrorDiagnostic, range, FormatOverloadSetSelectionFailure(failure));
  if (failure.kind != OverloadSetSelectionFailureKind::NoMatch &&
      failure.kind != OverloadSetSelectionFailureKind::Ambiguous) {
    return;
  }
  for (const AddressCandidate& candidate : failure.candidates) {
    if (failure.kind == OverloadSetSelectionFailureKind::Ambiguous && candidate.result_type != failure.target_type) {
      continue;
    }
    EmitDiagnostic(kNoteDiagnostic, NamedDeclarationRange(*candidate.declaration),
                   fmt::format("candidate has address type '{}'", TypeSpelling(candidate.result_type)));
  }
}

bool Sema::SelectAssignmentFunctionAddress(std::unique_ptr<Expr>& expression, QualType target, Node& owner) {
  if (!expression->type.GetTypePtr()->AsAddressOfFunctionOverloadSetType()) {
    return true;
  }
  const auto result = SelectFunctionAddress(MakeConversionSource(*expression), target, *ast_context_, symbol_table_);
  if (const auto* failure = std::get_if<OverloadSetSelectionFailure>(&result)) {
    expression->contains_errors = true;
    DiagnoseFunctionAddressFailure(owner, expression->range, *failure);
    return false;
  }
  ConversionSequence sequence;
  sequence.transitions.push_back(
      {std::get<FunctionAddressSelection>(result), {target.WithoutConst(), ValueCategory::PureRValue}});
  expression = CommitConversion(std::move(expression), target, sequence, ConstructionKind::CompleteObject);
  return true;
}

void Sema::DiagnoseConversionRisks(Node& owner, const Expr& source, QualType target,
                                   const ConversionSequence& conversion) {
  for (const auto& fact : CollectConversionRisks(MakeConversionSource(source), target, conversion, *ast_context_)) {
    DiagnoseImplicitConversionRisk(owner, source.range, fact.source_type, fact.target_type, fact.kind, fact.risk);
  }
}

bool Sema::ConvertExpression(std::unique_ptr<Expr>& expression, QualType target, Node& owner,
                             const std::string& failure_prefix, ConstructionKind result_kind) {
  const auto source = MakeConversionSource(*expression);
  auto result = BuildConversion(source, target, *ast_context_, symbol_table_);
  if (const auto* failure = std::get_if<ConversionFailure>(&result)) {
    if (const auto* selection = std::get_if<OverloadSetSelectionFailure>(failure)) {
      expression->contains_errors = true;
      DiagnoseFunctionAddressFailure(owner, expression->range, *selection);
    } else {
      Diagnose(owner, kErrorDiagnostic, expression->range, failure_prefix + FormatConversionFailure(*failure));
    }
    return false;
  }
  // Complete deferred object formation before emitting warnings or replacing the source AST.
  auto& conversion = std::get<ConversionSequence>(result);
  if (const auto failure = CompleteConversion(source, target, conversion, symbol_table_)) {
    Diagnose(owner, kErrorDiagnostic, expression->range,
             failure_prefix + FormatObjectFormationFailure(failure->failure));
    return false;
  }
  DiagnoseConversionRisks(owner, *expression, target, conversion);
  expression = CommitConversion(std::move(expression), target, conversion, result_kind);
  return true;
}

void Sema::CommitArgumentConversions(const std::vector<std::unique_ptr<Expr>*>& arguments,
                                     const std::vector<const Type*>& targets,
                                     const std::vector<ConversionSequence>& conversions) {
  BOOST_ASSERT(arguments.size() == targets.size() && arguments.size() == conversions.size());
  // All argument formations have completed before any warning or AST commit.
  for (std::size_t index = 0; index < arguments.size(); ++index) {
    DiagnoseConversionRisks(**arguments[index], **arguments[index], QualType(targets[index]), conversions[index]);
  }
  for (std::size_t index = 0; index < arguments.size(); ++index) {
    auto& argument = *arguments[index];
    argument = CommitConversion(std::move(argument), QualType(targets[index]), conversions[index],
                                ConstructionKind::CompleteObject);
  }
}

void Sema::ResolveTypeStructures(TranslationUnitDecl& translation_unit) {
  // Collect every type name first so fields and bases may refer to later declarations.
  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::StructDecl) {
      continue;
    }
    BindTypeName(static_cast<StructDecl&>(*declaration));
    InheritErrors(translation_unit, declaration.get());
  }

  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::StructDecl) {
      continue;
    }
    ResolveStructDeclarationTypes(static_cast<StructDecl&>(*declaration));
    InheritErrors(translation_unit, declaration.get());
  }

  // Reject cyclic layouts before recursive triviality and virtual-slot analysis.
  ValidateStructInheritance(translation_unit);
  ValidateObjectContainment(translation_unit);
  for (const auto& declaration : translation_unit.Decls) {
    if (declaration && declaration->GetKind() == NodeKind::StructDecl) {
      InheritErrors(translation_unit, declaration.get());
    }
  }
}

void Sema::BindTypeName(StructDecl& declaration) {
  if (declaration.name.empty()) {
    return;
  }

  if (const Symbol* symbol = symbol_table_.LookupCurrent(declaration.name)) {
    BOOST_ASSERT(symbol->GetKind() == SymbolKind::Type);
    DiagnoseConflict(declaration, NamedDeclarationRange(declaration),
                     fmt::format("redefinition of type '{}'", declaration.name), SymbolDeclarationRange(*symbol),
                     "previous declaration is here");
    return;
  }

  symbol_table_.Insert(declaration.name, std::make_unique<TypeSymbol>(&declaration));
}

Sema::LifecycleDeclarations Sema::ResolveLifecycleDeclarationInterfaces(TranslationUnitDecl& translation_unit) {
  LifecycleDeclarations lifecycle_declarations;

  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration) {
      continue;
    }

    switch (declaration->GetKind()) {
      case NodeKind::ConstructorDecl: {
        auto& constructor = static_cast<ConstructorDecl&>(*declaration);
        ResolveConstructorTarget(constructor);
        if (constructor.target_type) {
          lifecycle_declarations.constructors[constructor.target_type->GetDeclaration()].push_back(&constructor);
        }
        ResolveFunctionDeclarationTypes(constructor);
        break;
      }
      case NodeKind::DestructorDecl: {
        auto& destructor = static_cast<DestructorDecl&>(*declaration);
        ResolveDestructorTarget(destructor);
        if (destructor.target_type) {
          lifecycle_declarations.destructors[destructor.target_type->GetDeclaration()].push_back(&destructor);
        }
        ResolveFunctionDeclarationTypes(destructor);
        break;
      }
      default:
        break;
    }
    InheritErrors(translation_unit, declaration.get());
  }

  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration) {
      continue;
    }

    switch (declaration->GetKind()) {
      case NodeKind::ConstructorDecl: {
        auto& constructor = static_cast<ConstructorDecl&>(*declaration);
        CheckConstructorDeclaration(constructor);
        const bool valid_abstract_uses = ValidateAbstractFunctionTypeUses(constructor);
        if (!constructor.target_type || !valid_abstract_uses || !HasValidFunctionInterface(constructor)) {
          constructor.is_invalid = true;
        }
        break;
      }
      case NodeKind::DestructorDecl: {
        auto& destructor = static_cast<DestructorDecl&>(*declaration);
        CheckDestructorDeclaration(destructor);
        const bool valid_abstract_uses = ValidateAbstractFunctionTypeUses(destructor);
        if (!destructor.target_type || !valid_abstract_uses || !HasValidFunctionInterface(destructor)) {
          destructor.is_invalid = true;
        }
        break;
      }
      default:
        break;
    }
    InheritErrors(translation_unit, declaration.get());
  }

  return lifecycle_declarations;
}

void Sema::ResolveCallableInterfaces(TranslationUnitDecl& translation_unit) {
  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration) {
      continue;
    }

    switch (declaration->GetKind()) {
      case NodeKind::FunctionDecl:
        ResolveFunctionDeclarationTypes(static_cast<FunctionDecl&>(*declaration));
        break;
      default:
        break;
    }
    InheritErrors(translation_unit, declaration.get());
  }

  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration) {
      continue;
    }

    switch (declaration->GetKind()) {
      case NodeKind::FunctionDecl: {
        auto& function = static_cast<FunctionDecl&>(*declaration);
        CheckFunctionOperatorAndReturnDeclaration(function);
        CheckFunctionDeclaration(function);
        const bool valid_operator =
            !IsOperatorFunctionName(function.name) || ValidateOperatorFunctionInterface(function);
        const bool valid_abstract_uses = ValidateAbstractFunctionTypeUses(function);
        if (!valid_operator || !valid_abstract_uses || !HasValidFunctionInterface(function)) {
          function.is_invalid = true;
        }
        break;
      }
      default:
        break;
    }
    InheritErrors(translation_unit, declaration.get());
  }
}

void Sema::ValidateVirtualDeclarationInterfaces(TranslationUnitDecl& translation_unit) {
  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::StructDecl) {
      continue;
    }

    auto& structure = static_cast<StructDecl&>(*declaration);
    if (!structure.VirtualDecl) {
      continue;
    }

    for (const auto& function : structure.VirtualDecl->Functions) {
      if (!function) {
        continue;
      }
      CheckFunctionOperatorAndReturnDeclaration(*function);
      CheckFunctionDeclaration(*function);
      if (!HasValidFunctionInterface(*function) || function->name == ":=") {
        function->is_invalid = true;
      }
      InheritErrors(*structure.VirtualDecl, function.get());
    }
    InheritErrors(structure, structure.VirtualDecl.get());
    InheritErrors(translation_unit, declaration.get());
  }
}

Sema::InheritedVirtualSlots Sema::ValidateVirtualHierarchy(TranslationUnitDecl& translation_unit) {
  std::vector<StructDecl*> structures;
  InheritedVirtualSlots inherited_slots;
  std::unordered_map<const StructDecl*, std::vector<VirtualFunctionDecl*>> final_slots;
  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::StructDecl) {
      continue;
    }
    structures.push_back(static_cast<StructDecl*>(declaration.get()));
  }

  // First validate facts local to each virtual block. Invalid declarations do
  // not enter the inherited-slot calculation or consume a definition.
  for (StructDecl* structure : structures) {
    if (!structure->VirtualDecl) {
      continue;
    }
    std::vector<VirtualFunctionDecl*> local_functions;
    for (const auto& function_owner : structure->VirtualDecl->Functions) {
      VirtualFunctionDecl* function = function_owner.get();
      if (!function || function->is_invalid) {
        continue;
      }

      const QualType receiver_declaration_type =
          !function->ParmVars.empty() && function->ParmVars.front() ? function->ParmVars.front()->type : QualType{};
      const ReferenceType* receiver =
          receiver_declaration_type ? receiver_declaration_type.GetTypePtr()->AsReferenceType() : nullptr;
      if (!receiver) {
        Diagnose(*function, kErrorDiagnostic, NamedDeclarationRange(*function),
                 fmt::format("virtual function '{}' must declare a first receiver parameter of type 'mut {}', "
                             "'copy {}', or 'move {}'",
                             function->name, structure->name, structure->name, structure->name));
        function->is_invalid = true;
        continue;
      }
      const StructType* receiver_type = receiver->GetReferentType()->GetKind() == TypeKind::Struct
                                            ? static_cast<const StructType*>(receiver->GetReferentType())
                                            : nullptr;
      if (!receiver_type || receiver_type->GetDeclaration() != structure) {
        const SourceRange range = function->ParmVars.front()->Type ? function->ParmVars.front()->Type->range
                                                                   : function->ParmVars.front()->range;
        Diagnose(*function, kErrorDiagnostic, range,
                 fmt::format("receiver parameter of virtual function '{}' must refer to enclosing type '{}'",
                             function->name, structure->name));
        function->is_invalid = true;
        continue;
      }

      VirtualFunctionDecl* duplicate = nullptr;
      for (VirtualFunctionDecl* previous : local_functions) {
        if (previous->name == function->name && HasSameParameterSignature(*previous, *function)) {
          duplicate = previous;
          break;
        }
      }
      if (duplicate) {
        DiagnoseConflict(*function, NamedDeclarationRange(*function), FunctionRedefinitionMessage(*function),
                         NamedDeclarationRange(*duplicate), "previous declaration is here");
        function->is_invalid = true;
        continue;
      }

      local_functions.push_back(function);
    }
  }

  enum class VirtualVisitState { Unvisited, Visiting, Complete };
  std::unordered_map<const StructDecl*, VirtualVisitState> states;
  for (StructDecl* structure : structures) states.emplace(structure, VirtualVisitState::Unvisited);

  // Process bases before derived structures while keeping the final slot table
  // temporary; only direct override links and abstractness persist in the AST.
  const auto establish_overrides = [&](const auto& self, StructDecl& structure) -> void {
    VirtualVisitState& state = states[&structure];
    if (state == VirtualVisitState::Complete || state == VirtualVisitState::Visiting) {
      return;
    }
    state = VirtualVisitState::Visiting;

    std::vector<VirtualFunctionDecl*> slots;
    if (structure.base_type) {
      auto* base = const_cast<StructDecl*>(structure.base_type->GetDeclaration());
      self(self, *base);
      if (states[base] == VirtualVisitState::Complete) {
        slots = final_slots[base];
      }
    }
    inherited_slots[&structure] = slots;

    if (structure.VirtualDecl) {
      for (const auto& function_owner : structure.VirtualDecl->Functions) {
        VirtualFunctionDecl* function = function_owner.get();
        if (!function || function->is_invalid) {
          continue;
        }

        std::vector<std::size_t> matches;
        for (std::size_t index = 0; index < inherited_slots[&structure].size(); ++index) {
          if (HasSameVirtualSlot(*function, *inherited_slots[&structure][index])) {
            matches.push_back(index);
          }
        }

        if (!function->is_override) {
          if (!matches.empty()) {
            VirtualFunctionDecl* inherited = inherited_slots[&structure][matches.front()];
            Diagnose(*function, kErrorDiagnostic, NamedDeclarationRange(*function),
                     fmt::format("virtual function '{}' overrides an inherited virtual function but is not marked "
                                 "'override'",
                                 function->name));
            EmitDiagnostic(kNoteDiagnostic, NamedDeclarationRange(*inherited),
                           "inherited virtual function is declared here");
            function->is_invalid = true;
            continue;
          }
          slots.push_back(function);
          continue;
        }

        if (matches.empty()) {
          Diagnose(*function, kErrorDiagnostic, NamedDeclarationRange(*function),
                   fmt::format("virtual function '{}' marked 'override' does not override an inherited virtual "
                               "function",
                               function->name));
          function->is_invalid = true;
          continue;
        }
        if (matches.size() != 1) {
          Diagnose(
              *function, kErrorDiagnostic, NamedDeclarationRange(*function),
              fmt::format("virtual function '{}' matches more than one inherited virtual function", function->name));
          function->is_invalid = true;
          continue;
        }

        VirtualFunctionDecl* overridden = inherited_slots[&structure][matches.front()];
        const VirtualReturnCompatibilityResult return_compatibility =
            ClassifyVirtualReturnCompatibility(FunctionReturnType(*overridden), FunctionReturnType(*function));
        if (const auto* failure = std::get_if<VirtualReturnFailureKind>(&return_compatibility)) {
          Diagnose(*function, kErrorDiagnostic,
                   function->ReturnVar ? function->ReturnVar->range : NamedDeclarationRange(*function),
                   FormatVirtualReturnFailure(*function, *overridden, *failure));
          EmitDiagnostic(kNoteDiagnostic,
                         overridden->ReturnVar ? overridden->ReturnVar->range : NamedDeclarationRange(*overridden),
                         "overridden virtual function is declared here");
          function->is_invalid = true;
          continue;
        }

        function->overridden_virtual_function = overridden;
        auto position = std::find(slots.begin(), slots.end(), overridden);
        BOOST_ASSERT(position != slots.end());
        *position = function;
      }
    }

    final_slots[&structure] = std::move(slots);
    state = VirtualVisitState::Complete;
  };

  for (StructDecl* structure : structures) establish_overrides(establish_overrides, *structure);

  for (StructDecl* structure : structures) {
    const auto slots = final_slots.find(structure);
    structure->is_abstract = slots != final_slots.end() &&
                             std::any_of(slots->second.begin(), slots->second.end(),
                                         [](const VirtualFunctionDecl* function) { return function->is_abstract; });
  }

  for (StructDecl* structure : structures) {
    if (structure->VirtualDecl) {
      InheritErrors(*structure, structure->VirtualDecl.get());
    }
    InheritErrors(translation_unit, structure);
  }

  return inherited_slots;
}

void Sema::ValidateTypeDeclarationAbstractUses(TranslationUnitDecl& translation_unit) {
  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::StructDecl) {
      continue;
    }

    auto& structure = static_cast<StructDecl&>(*declaration);
    if (structure.VirtualDecl) {
      for (const auto& function : structure.VirtualDecl->Functions) {
        if (!function || function->is_invalid) {
          continue;
        }
        if (!ValidateAbstractFunctionTypeUses(*function)) {
          function->is_invalid = true;
        }
        InheritErrors(*structure.VirtualDecl, function.get());
      }
      InheritErrors(structure, structure.VirtualDecl.get());
    }
    for (const auto& field : structure.Fields) {
      if (!field || !field->Type || !field->type) {
        continue;
      }
      ValidateAbstractTypeUse(*field->Type, field->type, TypeUseKind::Field);
      InheritErrors(*field, field->Type.get());
      InheritErrors(structure, field.get());
    }
    InheritErrors(translation_unit, declaration.get());
  }
}

bool Sema::ValidateAbstractFunctionTypeUses(FunctionDecl& declaration) {
  bool valid = true;
  for (const auto& parameter : declaration.ParmVars) {
    if (!parameter || !parameter->Type || !parameter->type) {
      continue;
    }
    if (!ValidateAbstractTypeUse(*parameter->Type, parameter->type, TypeUseKind::Parameter)) {
      valid = false;
    }
    InheritErrors(*parameter, parameter->Type.get());
    InheritErrors(declaration, parameter.get());
  }
  if (declaration.ReturnVar && declaration.ReturnVar->Type && declaration.ReturnVar->type) {
    if (!ValidateAbstractTypeUse(*declaration.ReturnVar->Type, declaration.ReturnVar->type, TypeUseKind::Return)) {
      valid = false;
    }
    InheritErrors(*declaration.ReturnVar, declaration.ReturnVar->Type.get());
    InheritErrors(declaration, declaration.ReturnVar.get());
  }
  return valid;
}

void Sema::BindLifecycleDeclarations(TranslationUnitDecl& translation_unit) {
  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration) {
      continue;
    }
    switch (declaration->GetKind()) {
      case NodeKind::ConstructorDecl:
        RegisterConstructor(static_cast<ConstructorDecl&>(*declaration));
        break;
      case NodeKind::DestructorDecl:
        RegisterDestructor(static_cast<DestructorDecl&>(*declaration));
        break;
      default:
        break;
    }
    InheritErrors(translation_unit, declaration.get());
  }
}

void Sema::BindCallableDeclarations(TranslationUnitDecl& translation_unit) {
  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration) {
      continue;
    }
    switch (declaration->GetKind()) {
      case NodeKind::FunctionDecl:
        BindFunctionDeclaration(static_cast<FunctionDecl&>(*declaration));
        break;
      default:
        break;
    }
    InheritErrors(translation_unit, declaration.get());
  }
}

void Sema::BindFunctionDeclaration(FunctionDecl& declaration) {
  if (declaration.name.empty()) {
    return;
  }
  if (IsOperatorFunctionName(declaration.name)) {
    if (declaration.is_invalid) {
      return;
    }
    if (declaration.name == "=" && !RegisterSpecialAssignment(declaration)) {
      declaration.is_invalid = true;
      return;
    }
    AddFunctionDeclaration(declaration.name, declaration);
    return;
  }
  AddFunctionDeclaration(declaration.name, declaration);
}

void Sema::AssociateVirtualDefinitions(TranslationUnitDecl& translation_unit) {
  for (const auto& declaration_owner : translation_unit.Decls) {
    if (!declaration_owner || declaration_owner->GetKind() != NodeKind::StructDecl) {
      continue;
    }
    auto* structure = static_cast<StructDecl*>(declaration_owner.get());
    if (!structure->VirtualDecl) {
      continue;
    }
    for (const auto& function_owner : structure->VirtualDecl->Functions) {
      VirtualFunctionDecl* function = function_owner.get();
      if (!function || function->is_invalid) {
        continue;
      }

      Symbol* symbol = symbol_table_.LookupRoot(function->name);
      if (!symbol) {
        if (!function->is_abstract) {
          Diagnose(*function, kErrorDiagnostic, NamedDeclarationRange(*function),
                   fmt::format("virtual function '{}' requires a definition", function->name));
        }
        symbol_table_.Insert(function->name, std::make_unique<FunctionSymbol>(function));
        continue;
      }

      FunctionSymbol* functions = AsFunctionSymbol(symbol);
      if (!functions) {
        DiagnoseConflict(*function, NamedDeclarationRange(*function),
                         fmt::format("declaration of function '{}' conflicts with {} declaration", function->name,
                                     SymbolDescription(*symbol)),
                         SymbolDeclarationRange(*symbol), "conflicting declaration is here");
        function->is_invalid = true;
        continue;
      }

      // Parameter identity finds the definition; return compatibility is checked separately.
      FunctionDecl* definition = nullptr;
      for (FunctionDecl* declaration : functions->Declarations()) {
        if (!declaration || declaration->GetKind() != NodeKind::FunctionDecl || declaration->name != function->name ||
            !HasCompleteParameterSignature(*declaration) || !HasSameParameterSignature(*declaration, *function)) {
          continue;
        }
        BOOST_ASSERT(!definition);
        definition = declaration;
      }

      if (!definition) {
        if (!function->is_abstract) {
          Diagnose(*function, kErrorDiagnostic, NamedDeclarationRange(*function),
                   fmt::format("virtual function '{}' requires a definition", function->name));
        }
        functions->AddDeclaration(function);
        continue;
      }

      if (definition->is_invalid) {
        // The ordinary declaration still reserves this signature, but only the
        // interface remains usable as a recovery call declaration.
        functions->AddDeclaration(function);
        continue;
      }

      const Type* interface_return = FunctionReturnType(*function);
      const Type* definition_return = FunctionReturnType(*definition);
      BOOST_ASSERT(interface_return);
      BOOST_ASSERT(definition_return);
      if (definition_return != interface_return) {
        Diagnose(*definition, kErrorDiagnostic,
                 definition->ReturnVar ? definition->ReturnVar->range : NamedDeclarationRange(*definition),
                 fmt::format("return type '{}' of matching function definition does not match return type '{}' of "
                             "virtual function '{}'",
                             TypeSpelling(QualType(definition_return)), TypeSpelling(QualType(interface_return)),
                             function->name));
        EmitDiagnostic(kNoteDiagnostic, NamedDeclarationRange(*function), "virtual function is declared here");
        definition->is_invalid = true;
        functions->AddDeclaration(function);
        continue;
      }

      BOOST_ASSERT(!function->definition);
      BOOST_ASSERT(!definition->virtual_declaration);
      function->definition = definition;
      definition->virtual_declaration = function;
    }
  }
}

void Sema::ValidateRequiredOverrideDeclarations(TranslationUnitDecl& translation_unit,
                                                const InheritedVirtualSlots& inherited_slots) {
  std::unordered_map<const StructDecl*, std::unordered_set<const VirtualFunctionDecl*>> diagnosed;
  for (const auto& declaration_owner : translation_unit.Decls) {
    if (!declaration_owner || declaration_owner->GetKind() != NodeKind::FunctionDecl) {
      continue;
    }

    auto* function = static_cast<FunctionDecl*>(declaration_owner.get());
    if (function->is_invalid || function->virtual_declaration || function->name.empty() || function->ParmVars.empty() ||
        !function->ParmVars.front()) {
      continue;
    }

    const FunctionSymbol* functions = AsFunctionSymbol(symbol_table_.LookupRoot(function->name));
    if (!functions || std::find(functions->Declarations().begin(), functions->Declarations().end(), function) ==
                          functions->Declarations().end()) {
      continue;
    }

    const QualType receiver_type = function->ParmVars.front()->type;
    const ReferenceType* receiver = receiver_type ? receiver_type.GetTypePtr()->AsReferenceType() : nullptr;
    if (!receiver || receiver->GetReferentType()->GetKind() != TypeKind::Struct) {
      continue;
    }
    auto* structure =
        const_cast<StructDecl*>(static_cast<const StructType*>(receiver->GetReferentType())->GetDeclaration());

    const auto inherited = inherited_slots.find(structure);
    if (inherited == inherited_slots.end()) {
      continue;
    }
    for (VirtualFunctionDecl* inherited_function : inherited->second) {
      if (!inherited_function || inherited_function->is_invalid) {
        continue;
      }
      if (!HasSameVirtualSlot(*function, *inherited_function)) {
        continue;
      }
      const VirtualReturnCompatibilityResult return_compatibility =
          ClassifyVirtualReturnCompatibility(FunctionReturnType(*inherited_function), FunctionReturnType(*function));
      if (std::holds_alternative<VirtualReturnFailureKind>(return_compatibility)) {
        continue;
      }

      bool has_local_declaration = false;
      if (structure->VirtualDecl) {
        for (const auto& local : structure->VirtualDecl->Functions) {
          if (local && HasSameVirtualSlot(*local, *inherited_function)) {
            has_local_declaration = true;
            break;
          }
        }
      }
      if (has_local_declaration || !diagnosed[structure].insert(inherited_function).second) {
        continue;
      }

      Diagnose(*structure, kErrorDiagnostic, NamedDeclarationRange(*structure),
               fmt::format("type '{}' is missing an explicit override declaration for virtual function '{}'",
                           structure->name, inherited_function->name));
      EmitDiagnostic(kNoteDiagnostic, NamedDeclarationRange(*function),
                     "function with a matching signature is defined here");
      EmitDiagnostic(kNoteDiagnostic, NamedDeclarationRange(*inherited_function),
                     "inherited virtual function is declared here");
    }
  }

  for (const auto& declaration_owner : translation_unit.Decls) {
    if (!declaration_owner || declaration_owner->GetKind() != NodeKind::StructDecl) {
      continue;
    }
    auto* structure = static_cast<StructDecl*>(declaration_owner.get());
    if (structure->VirtualDecl) {
      InheritErrors(*structure, structure->VirtualDecl.get());
    }
    InheritErrors(translation_unit, structure);
  }
}

bool Sema::ValidateOperatorFunctionInterface(FunctionDecl& declaration) {
  BOOST_ASSERT(IsOperatorFunctionName(declaration.name));
  if (declaration.name == "[]") {
    return true;
  }
  if (declaration.name == "()") {
    if (declaration.ParmVars.empty()) {
      Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
               "operator '()' requires a receiver parameter");
      return false;
    }

    const auto& receiver_parameter = declaration.ParmVars.front();
    if (!receiver_parameter || !receiver_parameter->type ||
        (receiver_parameter->Type && receiver_parameter->Type->ContainsErrors())) {
      return true;
    }

    const QualType receiver_type = receiver_parameter->type;
    const ReferenceType* receiver = receiver_type ? receiver_type.GetTypePtr()->AsReferenceType() : nullptr;
    if (!receiver || receiver->GetReferentType()->GetKind() != TypeKind::Struct) {
      Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
               fmt::format("first parameter of operator '()' must be a reference to a struct, not '{}'",
                           TypeSpelling(receiver_parameter->type)));
      return false;
    }
    return true;
  }

  const expr::ExprGrammarSymbol op = expr::from_string(expr::ExprGrammarSymbol{}, declaration.name.c_str());
  if (op == expr::colonequal) {
    Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
             fmt::format("operator '{}' cannot be overloaded", declaration.name));
    return false;
  }
  const std::size_t arity = declaration.ParmVars.size();
  bool valid_arity = true;
  if (op == expr::plus || op == expr::minus) {
    valid_arity = arity == 1 || arity == 2;
    if (!valid_arity) {
      Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
               fmt::format("operator '{}' requires one or two parameters", declaration.name));
    }
  } else if (op == expr::exclaim) {
    valid_arity = arity == 1;
    if (!valid_arity) {
      Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
               "operator '!' requires exactly one parameter");
    }
  } else if (IsOverloadableBinaryOperator(op) || op == expr::equal) {
    valid_arity = arity == 2;
    if (!valid_arity) {
      Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
               fmt::format("operator '{}' requires exactly two parameters", declaration.name));
    }
  } else {
    return true;
  }
  if (!valid_arity || !declaration.type || declaration.type.GetTypePtr()->GetKind() != TypeKind::Function) {
    return false;
  }

  const auto& function_type = static_cast<const FunctionType&>(*declaration.type.GetTypePtr());
  const auto& parameter_types = function_type.GetParameterTypes();
  bool has_struct_parameter = false;
  for (const Type* parameter_type : parameter_types) {
    if (!parameter_type) {
      continue;
    }
    if (parameter_type->GetKind() == TypeKind::Struct) {
      has_struct_parameter = true;
      break;
    }
    if (parameter_type->GetKind() == TypeKind::Reference &&
        static_cast<const ReferenceType*>(parameter_type)->GetReferentType()->GetKind() == TypeKind::Struct) {
      has_struct_parameter = true;
      break;
    }
  }
  if (!has_struct_parameter) {
    Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
             fmt::format("operator '{}' requires a struct or reference-to-struct parameter", declaration.name));
    return false;
  }
  if (declaration.name == "=" && parameter_types.size() == 2 && parameter_types[0]->GetKind() == TypeKind::Reference &&
      parameter_types[1]->GetKind() == TypeKind::Reference) {
    const auto& destination = static_cast<const ReferenceType&>(*parameter_types[0]);
    const auto& source = static_cast<const ReferenceType&>(*parameter_types[1]);
    if (destination.GetMode() == ReferenceMode::Mut && source.GetMode() == ReferenceMode::Mut &&
        destination.GetReferentType()->GetKind() == TypeKind::Struct &&
        source.GetReferentType() == destination.GetReferentType()) {
      Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
               "same-type assignment cannot use a 'mut' source parameter");
      return false;
    }
  }
  return true;
}

bool Sema::RegisterSpecialAssignment(FunctionDecl& declaration) {
  BOOST_ASSERT(declaration.name == "=");
  if (!declaration.type || declaration.type.GetTypePtr()->GetKind() != TypeKind::Function) {
    return false;
  }

  const auto& function_type = static_cast<const FunctionType&>(*declaration.type.GetTypePtr());
  const auto& parameter_types = function_type.GetParameterTypes();
  if (parameter_types.size() != 2) {
    return false;
  }

  if (parameter_types[0]->GetKind() != TypeKind::Reference || parameter_types[1]->GetKind() != TypeKind::Reference) {
    return true;
  }
  const auto& destination = static_cast<const ReferenceType&>(*parameter_types[0]);
  const auto& source = static_cast<const ReferenceType&>(*parameter_types[1]);
  if (destination.GetMode() != ReferenceMode::Mut || destination.GetReferentType()->GetKind() != TypeKind::Struct ||
      source.GetReferentType() != destination.GetReferentType()) {
    return true;
  }

  BOOST_ASSERT(source.GetMode() != ReferenceMode::Mut);
  if (source.GetMode() != ReferenceMode::Copy && source.GetMode() != ReferenceMode::Move) {
    return true;
  }

  const auto& target_type = static_cast<const StructType&>(*destination.GetReferentType());
  StructDecl* target_declaration = const_cast<StructDecl*>(target_type.GetDeclaration());
  BOOST_ASSERT(target_declaration);
  TypeSymbol* type_symbol = AsTypeSymbol(symbol_table_.LookupRoot(target_declaration->name));
  if (!type_symbol || type_symbol->GetDeclaration() != target_declaration) {
    return true;
  }

  const bool is_copy = source.GetMode() == ReferenceMode::Copy;
  if (target_declaration->triviality == TypeTriviality::Trivial) {
    Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
             fmt::format("{} assignment cannot be declared for trivial type '{}'", is_copy ? "copy" : "move",
                         target_declaration->name));
    return false;
  }
  if (target_declaration->triviality != TypeTriviality::NonTrivial) {
    return false;
  }

  const auto [stored, inserted] =
      is_copy ? type_symbol->SetCopyAssignment(&declaration) : type_symbol->SetMoveAssignment(&declaration);
  if (!inserted) {
    BOOST_ASSERT(stored);
    DiagnoseConflict(declaration, NamedDeclarationRange(declaration),
                     is_copy ? "redefinition of copy assignment" : "redefinition of move assignment",
                     NamedDeclarationRange(*stored), "previous declaration is here");
    return false;
  }
  return true;
}

void Sema::ResolveConstructorTarget(ConstructorDecl& declaration) {
  if (declaration.name.empty()) {
    return;
  }

  const TypeSymbol* type_symbol = AsTypeSymbol(symbol_table_.LookupCurrent(declaration.name));
  if (!type_symbol) {
    Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
             fmt::format("unknown constructor target type '{}'", declaration.name));
    return;
  }
  declaration.target_type = ast_context_->GetStructType(type_symbol->GetDeclaration());
}

void Sema::ResolveDestructorTarget(DestructorDecl& declaration) {
  if (declaration.name.empty()) {
    return;
  }

  const TypeSymbol* type_symbol = AsTypeSymbol(symbol_table_.LookupCurrent(declaration.name));
  if (!type_symbol) {
    Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
             fmt::format("unknown destructor target type '{}'", declaration.name));
    return;
  }
  declaration.target_type = ast_context_->GetStructType(type_symbol->GetDeclaration());
}

void Sema::RegisterConstructor(ConstructorDecl& declaration) {
  if (declaration.is_invalid || !declaration.target_type) {
    return;
  }

  TypeSymbol* type_symbol = AsTypeSymbol(symbol_table_.LookupCurrent(declaration.name));
  BOOST_ASSERT(type_symbol);

  if (const FunctionSymbol* constructors = type_symbol->GetConstructorSymbol()) {
    for (const FunctionDecl* candidate : constructors->Declarations()) {
      BOOST_ASSERT(candidate && candidate->GetKind() == NodeKind::ConstructorDecl);
      if (!HasSameParameterSignature(*candidate, declaration)) {
        continue;
      }
      DiagnoseConflict(declaration, NamedDeclarationRange(declaration), FunctionRedefinitionMessage(declaration),
                       NamedDeclarationRange(*candidate), "previous declaration is here");
      declaration.is_invalid = true;
      return;
    }
  }
  type_symbol->AddConstructor(&declaration);

  const auto& function_type = static_cast<const FunctionType&>(*declaration.type.GetTypePtr());
  const auto& parameter_types = function_type.GetParameterTypes();
  if (parameter_types.size() != 1 || !parameter_types.front() ||
      parameter_types.front()->GetKind() != TypeKind::Reference) {
    return;
  }
  const auto& parameter = static_cast<const ReferenceType&>(*parameter_types.front());
  if (parameter.GetReferentType() != declaration.target_type) {
    return;
  }

  if (parameter.GetMode() == ReferenceMode::Copy) {
    const auto [stored, inserted] = type_symbol->SetCopyConstructor(&declaration);
    BOOST_ASSERT(inserted && stored == &declaration);
  } else if (parameter.GetMode() == ReferenceMode::Move) {
    const auto [stored, inserted] = type_symbol->SetMoveConstructor(&declaration);
    BOOST_ASSERT(inserted && stored == &declaration);
  }
}

void Sema::RegisterDestructor(DestructorDecl& declaration) {
  if (declaration.is_invalid || !declaration.target_type) {
    return;
  }

  TypeSymbol* type_symbol = AsTypeSymbol(symbol_table_.LookupCurrent(declaration.name));
  BOOST_ASSERT(type_symbol);

  const auto [stored, inserted] = type_symbol->SetDestructor(&declaration);
  if (!inserted) {
    BOOST_ASSERT(stored);
    DiagnoseConflict(declaration, NamedDeclarationRange(declaration), FunctionRedefinitionMessage(declaration),
                     NamedDeclarationRange(*stored), "previous declaration is here");
    declaration.is_invalid = true;
  }
}

bool Sema::AddFunctionDeclaration(const std::string& name, FunctionDecl& declaration) {
  const bool has_complete_signature = HasCompleteParameterSignature(declaration);
  Symbol* symbol = symbol_table_.LookupCurrent(name);
  if (!symbol) {
    // A complete parameter signature reserves its declaration identity even
    // when another part of the interface has made the declaration invalid.
    if (!has_complete_signature) {
      return false;
    }
    symbol_table_.Insert(name, std::make_unique<FunctionSymbol>(&declaration));
    return true;
  }

  if (symbol->GetKind() != SymbolKind::Function) {
    DiagnoseConflict(
        declaration, NamedDeclarationRange(declaration),
        fmt::format("declaration of function '{}' conflicts with {} declaration", name, SymbolDescription(*symbol)),
        SymbolDeclarationRange(*symbol), "conflicting declaration is here");
    declaration.is_invalid = true;
    return false;
  }

  if (!has_complete_signature) {
    return false;
  }

  auto& function_symbol = static_cast<FunctionSymbol&>(*symbol);
  for (const FunctionDecl* candidate : function_symbol.Declarations()) {
    BOOST_ASSERT(candidate);
    if (!HasSameParameterSignature(*candidate, declaration)) {
      continue;
    }

    DiagnoseConflict(declaration, NamedDeclarationRange(declaration), FunctionRedefinitionMessage(declaration),
                     NamedDeclarationRange(*candidate), "previous declaration is here");
    declaration.is_invalid = true;
    return false;
  }

  function_symbol.AddDeclaration(&declaration);
  return true;
}

void Sema::BindGlobalVariables(VarGroupDecl& declaration) {
  for (const auto& variable : declaration.Vars) {
    if (!variable) {
      continue;
    }
    global_variables_.insert(variable.get());
    if (variable->name.empty()) {
      continue;
    }
    const std::string& name = variable->name;

    Symbol* symbol = symbol_table_.LookupCurrent(name);
    if (!symbol) {
      symbol_table_.Insert(name, std::make_unique<VariableSymbol>(variable.get()));
      continue;
    }

    if (symbol->GetKind() == SymbolKind::Variable) {
      DiagnoseConflict(*variable, NamedDeclarationRange(*variable), fmt::format("redefinition of variable '{}'", name),
                       SymbolDeclarationRange(*symbol), "previous declaration is here");
      InheritErrors(declaration, variable.get());
      continue;
    }

    DiagnoseConflict(
        *variable, NamedDeclarationRange(*variable),
        fmt::format("declaration of variable '{}' conflicts with {} declaration", name, SymbolDescription(*symbol)),
        SymbolDeclarationRange(*symbol), "conflicting declaration is here");
    InheritErrors(declaration, variable.get());
  }
}

void Sema::ComputeStructTriviality(TranslationUnitDecl& translation_unit,
                                   const LifecycleDeclarations& lifecycle_declarations) {
  enum class VisitState { Unvisited, Visiting, Complete };
  std::unordered_map<const StructDecl*, VisitState> states;
  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::StructDecl) {
      continue;
    }
    auto& structure = static_cast<StructDecl&>(*declaration);
    BOOST_ASSERT(structure.triviality == TypeTriviality::Unknown);
    states.emplace(&structure, VisitState::Unvisited);
  }

  std::function<TypeTriviality(const Type*)> classify_type;
  std::function<TypeTriviality(StructDecl&)> classify_structure;

  // Arrays inherit element triviality; pointers do not depend on their pointee layout.
  classify_type = [&](const Type* type) -> TypeTriviality {
    if (!type) {
      return TypeTriviality::Invalid;
    }
    switch (type->GetKind()) {
      case TypeKind::Builtin:
      case TypeKind::Pointer:
      case TypeKind::VirtualSlot:
        return TypeTriviality::Trivial;
      case TypeKind::Struct:
        return classify_structure(*const_cast<StructDecl*>(static_cast<const StructType*>(type)->GetDeclaration()));
      case TypeKind::Array:
        return classify_type(static_cast<const ArrayType*>(type)->GetElementType().GetTypePtr());
      case TypeKind::ComptimeInt:
      case TypeKind::Null:
      case TypeKind::FunctionOverloadSet:
      case TypeKind::AddressOfFunctionOverloadSet:
      case TypeKind::Function:
      case TypeKind::Reference:
        return TypeTriviality::Invalid;
    }
    BOOST_ASSERT(false && "unsupported semantic type");
    return TypeTriviality::Invalid;
  };

  classify_structure = [&](StructDecl& structure) -> TypeTriviality {
    VisitState& state = states[&structure];
    if (state == VisitState::Complete) {
      return structure.triviality;
    }
    if (state == VisitState::Visiting) {
      structure.triviality = TypeTriviality::Invalid;
      return structure.triviality;
    }
    state = VisitState::Visiting;

    bool invalid = structure.ContainsErrors();
    const auto constructors = lifecycle_declarations.constructors.find(&structure);
    const auto destructors = lifecycle_declarations.destructors.find(&structure);
    bool nontrivial = (constructors != lifecycle_declarations.constructors.end() && !constructors->second.empty()) ||
                      (destructors != lifecycle_declarations.destructors.end() && !destructors->second.empty()) ||
                      (structure.VirtualDecl && !structure.VirtualDecl->Functions.empty());

    if (!invalid && structure.is_declared_trivial && nontrivial) {
      Diagnose(
          structure, kErrorDiagnostic, structure.range,
          fmt::format("trivial struct '{}' cannot declare constructors, destructors or virtual slots", structure.name));
      invalid = true;
    }

    if (structure.base_type) {
      const TypeTriviality base = classify_structure(*const_cast<StructDecl*>(structure.base_type->GetDeclaration()));
      invalid = invalid || base == TypeTriviality::Invalid || base == TypeTriviality::Unknown;
      nontrivial = nontrivial || base == TypeTriviality::NonTrivial;
    }
    for (const auto& field : structure.Fields) {
      if (!field || field->ContainsErrors() || !field->type) {
        invalid = true;
        continue;
      }
      const TypeTriviality field_triviality = classify_type(field->type.GetTypePtr());
      invalid = invalid || field_triviality == TypeTriviality::Invalid || field_triviality == TypeTriviality::Unknown;
      nontrivial = nontrivial || field_triviality == TypeTriviality::NonTrivial;
    }

    if (!invalid && structure.is_declared_trivial && nontrivial) {
      Diagnose(structure, kErrorDiagnostic, structure.range,
               fmt::format("trivial struct '{}' requires trivial base and field types", structure.name));
      invalid = true;
    }
    structure.triviality = invalid                         ? TypeTriviality::Invalid
                           : structure.is_declared_trivial ? TypeTriviality::Trivial
                                                           : TypeTriviality::NonTrivial;
    state = VisitState::Complete;
    return structure.triviality;
  };

  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::StructDecl) {
      continue;
    }
    auto& structure = static_cast<StructDecl&>(*declaration);
    if (states[&structure] == VisitState::Unvisited) {
      classify_structure(structure);
    }
  }
}

void Sema::ValidateLifecycleRequirements(TranslationUnitDecl& translation_unit,
                                         const LifecycleDeclarations& lifecycle_declarations) {
  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::StructDecl) {
      continue;
    }
    auto& structure = static_cast<StructDecl&>(*declaration);
    if (structure.triviality == TypeTriviality::Unknown || structure.triviality == TypeTriviality::Invalid) {
      continue;
    }

    if (structure.triviality == TypeTriviality::NonTrivial) {
      const auto constructors = lifecycle_declarations.constructors.find(&structure);
      const std::size_t constructor_count =
          constructors == lifecycle_declarations.constructors.end() ? 0 : constructors->second.size();
      const auto destructors = lifecycle_declarations.destructors.find(&structure);
      const std::size_t destructor_count =
          destructors == lifecycle_declarations.destructors.end() ? 0 : destructors->second.size();
      if (constructor_count == 0) {
        Diagnose(structure, kErrorDiagnostic, structure.range,
                 fmt::format("non-trivial struct '{}' requires a constructor", structure.name));
      }
      if (destructor_count != 1) {
        Diagnose(structure, kErrorDiagnostic, structure.range,
                 fmt::format("non-trivial struct '{}' requires exactly one destructor", structure.name));
      }
    }

    if (structure.base_type && structure.triviality == TypeTriviality::NonTrivial &&
        structure.base_type->GetDeclaration()->triviality == TypeTriviality::Trivial) {
      Diagnose(structure, kErrorDiagnostic, structure.base_range,
               fmt::format("non-trivial struct '{}' cannot inherit trivial struct '{}'", structure.name,
                           structure.base_type->GetDeclaration()->name));
    }
  }
}

void Sema::AnalyzeDeclarationBodies(TranslationUnitDecl& translation_unit) {
  // Finish global type inference before functions look up the global bindings.
  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::VarGroupDecl) {
      continue;
    }
    AnalyzeVariableGroup(static_cast<VarGroupDecl&>(*declaration), TypeUseKind::GlobalVariable);
    InheritErrors(translation_unit, declaration.get());
  }

  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration) {
      continue;
    }
    switch (declaration->GetKind()) {
      case NodeKind::FunctionDecl:
      case NodeKind::ConstructorDecl:
      case NodeKind::DestructorDecl: {
        auto& function = static_cast<FunctionDecl&>(*declaration);
        if (function.Body) {
          AnalyzeFunction(function);
        }
        break;
      }
      default:
        break;
    }
    InheritErrors(translation_unit, declaration.get());
  }
}

void Sema::AnalyzeFunction(FunctionDecl& declaration) {
  BOOST_ASSERT(loop_depth_ == 0);
  BOOST_ASSERT(!current_function_);
  const FunctionResultBlockAnalysisContext result_block_context{declaration};
  current_function_ = &declaration;

  symbol_table_.PushScope();
  const auto bind_variable = [&](VarDecl& variable) {
    if (variable.name.empty()) {
      return;
    }
    // Declaration-internal conflicts were diagnosed by the interface check.
    // Insertion keeps the first binding for recovery without diagnosing again.
    symbol_table_.Insert(variable.name, std::make_unique<VariableSymbol>(&variable));
  };
  for (const auto& parameter : declaration.ParmVars) {
    if (parameter) {
      const bool is_explicit_constructor_this =
          declaration.GetKind() == NodeKind::ConstructorDecl && parameter->name == "this";
      if (!is_explicit_constructor_this) {
        bind_variable(*parameter);
      }
      InheritErrors(declaration, parameter.get());
    }
  }
  if (declaration.ReturnVar) {
    bind_variable(*declaration.ReturnVar);
    InheritErrors(declaration, declaration.ReturnVar.get());
  }
  if (declaration.Body) {
    AnalyzeCompoundStmt(*declaration.Body, false, result_block_context, true);
    InheritErrors(declaration, declaration.Body.get());
  }
  if (declaration.GetKind() == NodeKind::ConstructorDecl) {
    const auto& constructor = static_cast<const ConstructorDecl&>(declaration);
    if (ClassifyConstructorPrologue(constructor) == ConstructorPrologueStatus::Missing) {
      const StructDecl* direct_base = constructor.target_type->GetDeclaration()->base_type->GetDeclaration();
      Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
               fmt::format("constructor for '{}' must begin by delegating or by initializing direct base '{}'",
                           constructor.name, direct_base->name));
    }
  }
  symbol_table_.PopScope();
  current_function_ = nullptr;
  BOOST_ASSERT(loop_depth_ == 0);
}

void Sema::AnalyzeDefiniteInitialization(TranslationUnitDecl& translation_unit) {
  const ABIKind abi = ast_context_->GetABIKind();
  const auto global_cfg = CFGBuilder::Build(translation_unit, abi);
  for (const auto& finding : DefiniteInitializationAnalysis::Run(translation_unit, *global_cfg, abi)) {
    BOOST_ASSERT(finding.owner);
    Diagnose(*const_cast<Node*>(finding.owner), kErrorDiagnostic, finding.range,
             DefiniteInitializationMessage(finding));
  }

  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration) {
      continue;
    }
    if (declaration->GetKind() != NodeKind::FunctionDecl && declaration->GetKind() != NodeKind::ConstructorDecl &&
        declaration->GetKind() != NodeKind::DestructorDecl) {
      continue;
    }
    auto& function = static_cast<FunctionDecl&>(*declaration);
    if (!function.Body) {
      continue;
    }

    std::unique_ptr<CFG> cfg = CFGBuilder::Build(function, abi);
    BOOST_ASSERT(cfg);
    const ConstructorPrologueStatus constructor_prologue_status =
        function.GetKind() == NodeKind::ConstructorDecl
            ? ClassifyConstructorPrologue(static_cast<const ConstructorDecl&>(function))
            : ConstructorPrologueStatus::NotRequired;
    // A failed constructor prologue already explains missing or out-of-order base initialization.
    for (const DefiniteInitializationFinding& finding : DefiniteInitializationAnalysis::Run(function, *cfg, abi)) {
      if ((finding.kind == DefiniteInitializationFindingKind::UninitializedResult ||
           finding.kind == DefiniteInitializationFindingKind::OutOfOrderSubobjectInitialization) &&
          !finding.declaration &&
          (constructor_prologue_status == ConstructorPrologueStatus::InvalidAttempt ||
           constructor_prologue_status == ConstructorPrologueStatus::Missing)) {
        continue;
      }
      BOOST_ASSERT(finding.owner);
      Node& owner = *const_cast<Node*>(finding.owner);
      Diagnose(owner, kErrorDiagnostic, finding.range, DefiniteInitializationMessage(finding));
    }
  }
}

void Sema::ValidateDelegatingConstructorCycles(TranslationUnitDecl& translation_unit) {
  struct DelegationEdge {
    ConstructorDecl* source{};
    ConstructorDecl* target{};
    ConstructionExpr* construction{};
  };

  // Only a successfully resolved leading delegation contributes an edge.
  std::vector<DelegationEdge> edges;
  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::ConstructorDecl) {
      continue;
    }
    auto* constructor = static_cast<ConstructorDecl*>(declaration.get());
    if (!constructor->Body || constructor->Body->Stmts.empty() || !constructor->Body->Stmts.front() ||
        constructor->Body->Stmts.front()->GetKind() != NodeKind::ExprStmt) {
      continue;
    }
    auto& statement = static_cast<ExprStmt&>(*constructor->Body->Stmts.front());
    if (!statement.Expr || statement.Expr->GetKind() != NodeKind::InitializationExpr) {
      continue;
    }
    auto& initialization = static_cast<InitializationExpr&>(*statement.Expr);
    if (!initialization.Target || initialization.Target->GetKind() != NodeKind::ThisExpr || !initialization.Source) {
      continue;
    }
    Expr* source = initialization.Source->IgnoreParens();
    if (!source || source->GetKind() != NodeKind::ConstructionExpr) {
      continue;
    }
    auto& construction = static_cast<ConstructionExpr&>(*source);
    if (construction.construction_kind != ConstructionKind::Delegating || construction.ContainsErrors() ||
        !construction.constructor) {
      continue;
    }
    edges.push_back({constructor, const_cast<ConstructorDecl*>(construction.constructor), &construction});
  }

  // An edge back into the active DFS stack identifies exactly the constructors in a cycle.
  std::unordered_map<const ConstructorDecl*, DelegationEdge*> outgoing;
  for (auto& edge : edges) outgoing.emplace(edge.source, &edge);
  enum class VisitState { Unvisited, Visiting, Complete };
  std::unordered_map<const ConstructorDecl*, VisitState> states;
  std::vector<ConstructorDecl*> stack;
  std::unordered_map<const ConstructorDecl*, std::size_t> stack_positions;

  const auto visit = [&](const auto& self, ConstructorDecl& constructor) -> void {
    states[&constructor] = VisitState::Visiting;
    stack_positions[&constructor] = stack.size();
    stack.push_back(&constructor);

    const auto edge_it = outgoing.find(&constructor);
    if (edge_it != outgoing.end()) {
      DelegationEdge& edge = *edge_it->second;
      const VisitState target_state = states[edge.target];
      if (target_state == VisitState::Unvisited) {
        self(self, *edge.target);
      } else if (target_state == VisitState::Visiting) {
        const std::size_t cycle_begin = stack_positions[edge.target];
        ConstructorDecl& diagnostic_owner = *stack[cycle_begin];
        Diagnose(diagnostic_owner, kErrorDiagnostic, edge.construction->range,
                 fmt::format("delegating constructor cycle for type '{}'", diagnostic_owner.name));
        for (std::size_t index = cycle_begin; index < stack.size(); ++index) {
          ConstructorDecl* cycle_constructor = stack[index];
          DelegationEdge* cycle_edge = outgoing[cycle_constructor];
          BOOST_ASSERT(cycle_edge && cycle_edge->construction);
          EmitDiagnostic(kNoteDiagnostic, cycle_edge->construction->range,
                         fmt::format("constructor '{}' delegates here", cycle_constructor->name));
          cycle_constructor->contains_errors = true;
          cycle_edge->construction->contains_errors = true;
        }
      }
    }

    stack.pop_back();
    stack_positions.erase(&constructor);
    states[&constructor] = VisitState::Complete;
  };

  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::ConstructorDecl) {
      continue;
    }
    auto& constructor = static_cast<ConstructorDecl&>(*declaration);
    if (states[&constructor] == VisitState::Unvisited) {
      visit(visit, constructor);
    }
  }
}

void Sema::AnalyzeCompoundStmt(CompoundStmt& statement, bool creates_scope,
                               const ResultBlockAnalysisContext& result_block_context, bool is_result_block) {
  if (creates_scope) {
    symbol_table_.PushScope();
  }

  bool has_result_object = false;
  switch (result_block_context.GetKind()) {
    case ResultBlockKind::Function: {
      const FunctionDecl& function =
          static_cast<const FunctionResultBlockAnalysisContext&>(result_block_context).GetDeclaration();
      has_result_object = HasFunctionResultObject(function);
      break;
    }
    case ResultBlockKind::Variable:
      has_result_object =
          !static_cast<const VariableResultBlockAnalysisContext&>(result_block_context).GetDeclaration().Vars.empty();
      break;
  }

  const bool forwards_result_position = is_result_block && has_result_object && statement.TailExprs.empty() &&
                                        !statement.Stmts.empty() && statement.Stmts.back() &&
                                        statement.Stmts.back()->GetKind() == NodeKind::IfStmt;
  for (std::size_t index = 0; index < statement.Stmts.size(); ++index) {
    const auto& child = statement.Stmts[index];
    if (child) {
      const bool is_constructor_prologue = current_function_ &&
                                           current_function_->GetKind() == NodeKind::ConstructorDecl &&
                                           current_function_->Body.get() == &statement && index == 0;
      AnalyzeStmt(*child, result_block_context, forwards_result_position && index + 1 == statement.Stmts.size(),
                  is_constructor_prologue);
      InheritErrors(statement, child.get());
    }
  }
  for (auto& expression : statement.TailExprs) {
    expression = AnalyzeExpr(std::move(expression));
    InheritErrors(statement, expression.get());
  }

  if (is_result_block) {
    AnalyzeResultBlockTailExpressions(statement, result_block_context);
  } else {
    for (const auto& expression : statement.TailExprs) {
      if (expression) {
        Diagnose(statement, kErrorDiagnostic, expression->range, "tail expressions are only allowed in a result block");
      }
    }
  }
  for (const auto& expression : statement.TailExprs) {
    InheritErrors(statement, expression.get());
  }

  if (creates_scope) {
    symbol_table_.PopScope();
  }
}

void Sema::AnalyzeStmt(Stmt& statement, const ResultBlockAnalysisContext& result_block_context,
                       bool forwards_result_position, bool is_constructor_prologue) {
  switch (statement.GetKind()) {
    case NodeKind::CompoundStmt:
      AnalyzeCompoundStmt(static_cast<CompoundStmt&>(statement), true, result_block_context);
      break;
    case NodeKind::ExprStmt: {
      auto& expression_statement = static_cast<ExprStmt&>(statement);
      expression_statement.Expr = AnalyzeExpr(
          std::move(expression_statement.Expr), ComptimeIntMode::Materialize,
          is_constructor_prologue ? ExpressionUse::ConstructorPrologue : ExpressionUse::InitializationStatement);
      if (expression_statement.Expr && !expression_statement.Expr->ContainsErrors() &&
          expression_statement.Expr->type) {
        if (expression_statement.Expr->type.GetTypePtr()->AsFunctionOverloadSetType()) {
          const Expr* unwrapped = expression_statement.Expr->IgnoreParens();
          BOOST_ASSERT(unwrapped && unwrapped->GetKind() == NodeKind::DeclRefExpr);
          const auto& function_name = static_cast<const DeclRefExpr&>(*unwrapped);
          Diagnose(*expression_statement.Expr, kErrorDiagnostic, function_name.range,
                   fmt::format("function '{}' cannot be used as an object expression", function_name.name));
        } else if (expression_statement.Expr->type.GetTypePtr()->AsAddressOfFunctionOverloadSetType()) {
          ConvertExpression(expression_statement.Expr, QualType{}, expression_statement, "");
        }
      }
      InheritErrors(expression_statement, expression_statement.Expr.get());
      break;
    }
    case NodeKind::DeclStmt: {
      auto& declaration_statement = static_cast<DeclStmt&>(statement);
      if (!declaration_statement.Decl) {
        break;
      }
      BOOST_ASSERT(declaration_statement.Decl->GetKind() == NodeKind::VarGroupDecl);
      AnalyzeVariableGroup(static_cast<VarGroupDecl&>(*declaration_statement.Decl));
      InheritErrors(declaration_statement, declaration_statement.Decl.get());
      break;
    }
    case NodeKind::IfStmt: {
      auto& if_statement = static_cast<IfStmt&>(statement);
      if_statement.Cond = AnalyzeExpr(std::move(if_statement.Cond));
      InheritErrors(if_statement, if_statement.Cond.get());
      if (if_statement.Cond && !if_statement.Cond->ContainsErrors() && if_statement.Cond->type &&
          if_statement.Cond->type.WithoutConst() != QualType(ast_context_->GetBuiltinType(BuiltinTypeKind::Bool))) {
        Diagnose(if_statement, kErrorDiagnostic, if_statement.Cond->range,
                 fmt::format("condition expression must have type 'bool', not {}",
                             DescribeExpressionType(if_statement.Cond->type)));
      } else if (if_statement.Cond && !if_statement.Cond->ContainsErrors() && if_statement.Cond->type) {
        ApplyDefaultValueConversion(if_statement.Cond);
      }
      if (if_statement.Then) {
        AnalyzeCompoundStmt(*if_statement.Then, true, result_block_context, forwards_result_position);
        InheritErrors(if_statement, if_statement.Then.get());
      }
      if (if_statement.Else) {
        AnalyzeCompoundStmt(*if_statement.Else, true, result_block_context, forwards_result_position);
        InheritErrors(if_statement, if_statement.Else.get());
      }
      break;
    }
    case NodeKind::WhileStmt: {
      auto& while_statement = static_cast<WhileStmt&>(statement);
      while_statement.Cond = AnalyzeExpr(std::move(while_statement.Cond));
      InheritErrors(while_statement, while_statement.Cond.get());
      if (while_statement.Cond && !while_statement.Cond->ContainsErrors() && while_statement.Cond->type &&
          while_statement.Cond->type.WithoutConst() != QualType(ast_context_->GetBuiltinType(BuiltinTypeKind::Bool))) {
        Diagnose(while_statement, kErrorDiagnostic, while_statement.Cond->range,
                 fmt::format("condition expression must have type 'bool', not {}",
                             DescribeExpressionType(while_statement.Cond->type)));
      } else if (while_statement.Cond && !while_statement.Cond->ContainsErrors() && while_statement.Cond->type) {
        ApplyDefaultValueConversion(while_statement.Cond);
      }
      if (while_statement.Body) {
        ++loop_depth_;
        AnalyzeCompoundStmt(*while_statement.Body, true, result_block_context);
        --loop_depth_;
        InheritErrors(while_statement, while_statement.Body.get());
      }
      break;
    }
    case NodeKind::ReturnStmt: {
      AnalyzeReturnStmt(static_cast<ReturnStmt&>(statement), result_block_context);
      break;
    }
    case NodeKind::BreakStmt:
      if (loop_depth_ == 0) {
        Diagnose(statement, kErrorDiagnostic, statement.range, "break is only allowed inside a loop");
      }
      break;
    case NodeKind::ContinueStmt:
      if (loop_depth_ == 0) {
        Diagnose(statement, kErrorDiagnostic, statement.range, "continue is only allowed inside a loop");
      }
      break;
    default:
      BOOST_ASSERT(false && "unsupported statement node");
      break;
  }
}

void Sema::AnalyzeReturnStmt(ReturnStmt& statement, const ResultBlockAnalysisContext& result_block_context) {
  statement.Expr = AnalyzeExpr(std::move(statement.Expr));
  InheritErrors(statement, statement.Expr.get());

  if (result_block_context.GetKind() == ResultBlockKind::Variable) {
    Diagnose(statement, kErrorDiagnostic, {statement.range.begin, statement.range.begin},
             "return is not allowed in a variable initializer block");
    return;
  }

  BOOST_ASSERT(result_block_context.GetKind() == ResultBlockKind::Function);
  const auto& function_result_block_context =
      static_cast<const FunctionResultBlockAnalysisContext&>(result_block_context);
  FunctionDecl& function = function_result_block_context.GetDeclaration();
  if (!HasFunctionResultObject(function)) {
    if (statement.Expr) {
      Diagnose(statement, kErrorDiagnostic, {statement.range.begin, statement.range.begin},
               ReturnValueNotAllowedMessage(function));
    }
    return;
  }

  if (!statement.Expr) {
    return;
  }
  if (!function.ReturnVar) {
    statement.contains_errors = true;
    return;
  }

  FormImplicitResultInitialization(statement.Expr, *function.ReturnVar, &function);
  InheritErrors(statement, statement.Expr.get());
}

void Sema::AnalyzeResultBlockTailExpressions(CompoundStmt& statement,
                                             const ResultBlockAnalysisContext& result_block_context) {
  switch (result_block_context.GetKind()) {
    case ResultBlockKind::Function:
      AnalyzeFunctionTailExpressions(
          statement, static_cast<const FunctionResultBlockAnalysisContext&>(result_block_context).GetDeclaration());
      return;
    case ResultBlockKind::Variable:
      AnalyzeVariableTailExpressions(
          statement, static_cast<const VariableResultBlockAnalysisContext&>(result_block_context).GetDeclaration());
      return;
  }
  BOOST_ASSERT(false && "unsupported result block kind");
}

void Sema::AnalyzeFunctionTailExpressions(CompoundStmt& statement, FunctionDecl& function) {
  if (statement.TailExprs.empty()) {
    return;
  }
  if (!HasFunctionResultObject(function)) {
    for (const auto& expression : statement.TailExprs) {
      if (expression) {
        Diagnose(statement, kErrorDiagnostic, expression->range, "void function cannot have a tail expression");
      }
    }
    return;
  }

  if (statement.TailExprs.size() != 1) {
    const SourceRange range = statement.TailExprs.front() ? statement.TailExprs.front()->range : statement.range;
    Diagnose(statement, kErrorDiagnostic, range, "function result block must have exactly one tail expression");
    return;
  }

  if (!function.ReturnVar) {
    statement.contains_errors = true;
    return;
  }

  auto& expression = statement.TailExprs.front();
  FormImplicitResultInitialization(expression, *function.ReturnVar, &function);
}

void Sema::AnalyzeVariableTailExpressions(CompoundStmt& statement, VarGroupDecl& declaration) {
  if (statement.TailExprs.empty()) {
    return;
  }
  if (statement.TailExprs.size() != declaration.Vars.size()) {
    const SourceRange range = statement.TailExprs.front() ? statement.TailExprs.front()->range : statement.range;
    Diagnose(statement, kErrorDiagnostic, range,
             fmt::format("variable result block requires exactly {} tail expression{}", declaration.Vars.size(),
                         declaration.Vars.size() == 1 ? "" : "s"));
    return;
  }

  for (std::size_t index = 0; index < statement.TailExprs.size(); ++index) {
    if (!declaration.Vars[index]) {
      statement.contains_errors = true;
      continue;
    }
    FormImplicitResultInitialization(statement.TailExprs[index], *declaration.Vars[index]);
  }
}

void Sema::FormImplicitResultInitialization(std::unique_ptr<Expr>& expression, VarDecl& target,
                                            FunctionDecl* function) {
  auto initialization = std::make_unique<ImplicitResultInitializationExpr>();
  initialization->Target = &target;
  initialization->type = QualType(ast_context_->GetBuiltinType(BuiltinTypeKind::Void));
  initialization->value_category = ValueCategory::None;
  if (expression) {
    initialization->range = expression->range;
  }
  initialization->Source = std::move(expression);
  InheritErrors(*initialization, initialization->Source.get());

  if (!target.type || target.type.GetTypePtr()->IsVoid() || !initialization->Source || !initialization->Source->type) {
    initialization->contains_errors = true;
  } else if (!initialization->Source->ContainsErrors()) {
    if (function) {
      AdaptReturnExpression(initialization->Source, target.type, *initialization);
    } else {
      FinalizeVariableInitializer(
          target, initialization->Source,
          global_variables_.count(&target) ? TypeUseKind::GlobalVariable : TypeUseKind::LocalVariable);
    }
    InheritErrors(*initialization, initialization->Source.get());
  }

  expression = std::move(initialization);
}

bool Sema::AdaptReturnExpression(std::unique_ptr<Expr>& expression, QualType target_type, Node& diagnostic_owner) {
  return ConvertExpression(expression, target_type, diagnostic_owner, "cannot initialize return object: ");
}

void Sema::AnalyzeVariableGroup(VarGroupDecl& declaration, TypeUseKind use) {
  BOOST_ASSERT(use == TypeUseKind::LocalVariable || use == TypeUseKind::GlobalVariable);
  CheckVariableGroupDeclaration(declaration, use);
  ResolveVariableGroupTypes(declaration, use);

  const auto bind_variables = [&] {
    if (use == TypeUseKind::GlobalVariable) {
      BindGlobalVariables(declaration);
    } else {
      for (const auto& variable : declaration.Vars) {
        if (!variable) {
          continue;
        }
        AddLocalVariable(*variable);
        InheritErrors(declaration, variable.get());
      }
    }
  };

  // An initializer block must see its destination variables; ordinary initializers are analyzed
  // before the new group enters the symbol table.
  if (declaration.Body) {
    bind_variables();

    const VariableResultBlockAnalysisContext result_block_context{declaration};
    AnalyzeCompoundStmt(*declaration.Body, true, result_block_context, true);
    InheritErrors(declaration, declaration.Body.get());
  } else {
    for (std::size_t index = 0; index < declaration.InitExprs.size(); ++index) {
      auto& expression = declaration.InitExprs[index];
      expression = AnalyzeExpr(std::move(expression));
      if (index < declaration.Vars.size() && declaration.Vars[index] && expression) {
        FinalizeVariableInitializer(*declaration.Vars[index], expression, use);
        InheritErrors(declaration, declaration.Vars[index].get());
      }
      InheritErrors(declaration, expression.get());
    }

    bind_variables();
  }
}

std::unique_ptr<Expr> Sema::AnalyzeExpr(std::unique_ptr<Expr> expression, ComptimeIntMode mode, ExpressionUse use,
                                        const ConstructionResultContext* construction_context) {
  if (!expression) {
    return nullptr;
  }

  switch (expression->GetKind()) {
    case NodeKind::IntegerLiteral:
      expression->type = QualType(ast_context_->GetComptimeIntType());
      expression->value_category = ValueCategory::None;
      break;
    case NodeKind::CharacterLiteral:
      expression->type = QualType(ast_context_->GetBuiltinType(BuiltinTypeKind::U8));
      expression->value_category = ValueCategory::PureRValue;
      break;
    case NodeKind::FloatLiteral: {
      const auto& literal = static_cast<const FloatLiteral&>(*expression);
      expression->type = QualType(ast_context_->GetBuiltinType(
          std::holds_alternative<float>(literal.value) ? BuiltinTypeKind::F32 : BuiltinTypeKind::F64));
      expression->value_category = ValueCategory::PureRValue;
      break;
    }
    case NodeKind::NullLiteral:
      expression->type = QualType(ast_context_->GetNullType());
      expression->value_category = ValueCategory::None;
      break;
    case NodeKind::BoolLiteral:
      expression->type = QualType(ast_context_->GetBuiltinType(BuiltinTypeKind::Bool));
      expression->value_category = ValueCategory::PureRValue;
      break;
    case NodeKind::StringLiteral: {
      const auto& literal = static_cast<const StringLiteral&>(*expression);
      const QualType element_type(ast_context_->GetBuiltinType(BuiltinTypeKind::U8));
      expression->type = QualType(ast_context_->GetArrayType(element_type, literal.value.size())).WithConst();
      expression->value_category = ValueCategory::LValue;
      break;
    }
    case NodeKind::RecoveryExpr:
      break;
    case NodeKind::DeclRefExpr:
      expression = AnalyzeDeclRefExpr(std::move(expression), DeclRefRole::Object);
      break;
    case NodeKind::ThisExpr:
      AnalyzeThisExpr(static_cast<ThisExpr&>(*expression));
      break;
    case NodeKind::ParenExpr: {
      auto& parentheses = static_cast<ParenExpr&>(*expression);
      parentheses.SubExpr = AnalyzeExpr(std::move(parentheses.SubExpr), ComptimeIntMode::Preserve,
                                        ExpressionUse::General, construction_context);
      InheritErrors(parentheses, parentheses.SubExpr.get());
      if (parentheses.SubExpr) {
        parentheses.type = parentheses.SubExpr->type;
        parentheses.value_category = parentheses.SubExpr->value_category;
      } else {
        parentheses.contains_errors = true;
      }
      break;
    }
    case NodeKind::UnaryOperator: {
      auto& unary_expression = static_cast<UnaryOperator&>(*expression);
      const ComptimeIntMode operand_mode = unary_expression.op == expr::plus || unary_expression.op == expr::minus
                                               ? ComptimeIntMode::Preserve
                                               : ComptimeIntMode::Materialize;
      unary_expression.Operand = AnalyzeExpr(std::move(unary_expression.Operand), operand_mode);
      InheritErrors(unary_expression, unary_expression.Operand.get());
      expression = AnalyzeUnaryOperator(std::move(expression));
      break;
    }
    case NodeKind::BinaryOperator: {
      auto& binary_expression = static_cast<BinaryOperator&>(*expression);
      if (binary_expression.IsSimpleAssignment()) {
        binary_expression.RHS = AnalyzeExpr(std::move(binary_expression.RHS));
        binary_expression.LHS = AnalyzeExpr(std::move(binary_expression.LHS));
        InheritErrors(binary_expression, binary_expression.RHS.get());
        InheritErrors(binary_expression, binary_expression.LHS.get());
        expression = AnalyzeSimpleAssignment(std::move(expression));
      } else {
        binary_expression.LHS = AnalyzeExpr(std::move(binary_expression.LHS));
        binary_expression.RHS = AnalyzeExpr(std::move(binary_expression.RHS));
        InheritErrors(binary_expression, binary_expression.LHS.get());
        InheritErrors(binary_expression, binary_expression.RHS.get());
        expression = AnalyzeBinaryOperator(std::move(expression));
      }
      break;
    }
    case NodeKind::InitializationExpr: {
      auto& initialization_expression = static_cast<InitializationExpr&>(*expression);
      AnalyzeInitializationExpr(initialization_expression, use);
      break;
    }
    case NodeKind::ImplicitResultInitializationExpr:
      break;
    case NodeKind::ConditionalOperator: {
      auto& conditional_expression = static_cast<ConditionalOperator&>(*expression);
      conditional_expression.Cond = AnalyzeExpr(std::move(conditional_expression.Cond));
      conditional_expression.Then = AnalyzeExpr(std::move(conditional_expression.Then), ComptimeIntMode::Materialize,
                                                ExpressionUse::General, construction_context);
      conditional_expression.Else = AnalyzeExpr(std::move(conditional_expression.Else), ComptimeIntMode::Materialize,
                                                ExpressionUse::General, construction_context);
      InheritErrors(conditional_expression, conditional_expression.Cond.get());
      InheritErrors(conditional_expression, conditional_expression.Then.get());
      InheritErrors(conditional_expression, conditional_expression.Else.get());
      AnalyzeConditionalOperator(conditional_expression, construction_context);
      break;
    }
    case NodeKind::MemberExpr: {
      auto& member_expression = static_cast<MemberExpr&>(*expression);
      member_expression.Base = AnalyzeExpr(std::move(member_expression.Base));
      InheritErrors(member_expression, member_expression.Base.get());
      expression = AnalyzeMemberExpr(std::move(expression));
      break;
    }
    case NodeKind::BaseSubobjectExpr:
      break;
    case NodeKind::SubscriptExpr: {
      auto& subscript_expression = static_cast<SubscriptExpr&>(*expression);
      subscript_expression.Base = AnalyzeExpr(std::move(subscript_expression.Base));
      subscript_expression.Index = AnalyzeExpr(std::move(subscript_expression.Index));
      InheritErrors(subscript_expression, subscript_expression.Base.get());
      InheritErrors(subscript_expression, subscript_expression.Index.get());
      AnalyzeSubscriptExpr(subscript_expression);
      break;
    }
    case NodeKind::ArrayValueExpr: {
      AnalyzeArrayValueExpr(static_cast<ArrayValueExpr&>(*expression));
      break;
    }
    case NodeKind::CallExpr: {
      auto& call_expression = static_cast<CallExpr&>(*expression);
      call_expression.Callee = AnalyzeCalleeExpr(std::move(call_expression.Callee));
      InheritErrors(call_expression, call_expression.Callee.get());
      for (auto& argument : call_expression.Args) {
        argument = AnalyzeExpr(std::move(argument));
        InheritErrors(call_expression, argument.get());
      }
      if (!call_expression.is_nonvirtual && call_expression.Callee && !call_expression.Callee->ContainsErrors() &&
          IsStructObjectOperand(*call_expression.Callee)) {
        expression = AnalyzeCallableObjectCall(std::move(expression));
        break;
      }
      AnalyzeCallExpr(call_expression, construction_context);
      if (!call_expression.ContainsErrors() && call_expression.type &&
          call_expression.value_category == ValueCategory::PureRValue && call_expression.Callee &&
          call_expression.Callee->GetKind() == NodeKind::DeclRefExpr) {
        auto& callee = static_cast<DeclRefExpr&>(*call_expression.Callee);
        const auto* constructor = callee.declaration && callee.declaration->GetKind() == NodeKind::ConstructorDecl
                                      ? static_cast<const ConstructorDecl*>(callee.declaration)
                                      : nullptr;
        // A successful type call with no selected function is trivial default formation.
        const bool trivial_default = !callee.declaration && call_expression.Args.empty() &&
                                     call_expression.type.GetTypePtr()->GetKind() == TypeKind::Struct &&
                                     call_expression.type.GetTypePtr()->GetTriviality() == TypeTriviality::Trivial;
        if (constructor || trivial_default) {
          auto construction = std::make_unique<ConstructionExpr>();
          construction->range = call_expression.range;
          construction->construction_kind =
              construction_context && call_expression.type.WithoutConst() == construction_context->target_type
                  ? construction_context->construction_kind
                  : ConstructionKind::CompleteObject;
          construction->target_name = callee.name;
          construction->target_name_range = callee.range;
          construction->constructor = constructor;
          construction->Args = std::move(call_expression.Args);
          construction->type = call_expression.type;
          construction->value_category = call_expression.value_category;
          expression = std::move(construction);
        }
      }
      break;
    }
    case NodeKind::ConstructionExpr: {
      auto& construction = static_cast<ConstructionExpr&>(*expression);
      construction.TargetAddress = AnalyzeExpr(std::move(construction.TargetAddress));
      InheritErrors(construction, construction.TargetAddress.get());
      for (auto& argument : construction.Args) {
        argument = AnalyzeExpr(std::move(argument));
        InheritErrors(construction, argument.get());
      }
      AnalyzeConstructionExpr(construction);
      break;
    }
    case NodeKind::ArrayConstructionExpr:
    case NodeKind::ArrayAssignmentExpr:
      break;
    case NodeKind::DestructorCallExpr: {
      auto& call_expression = static_cast<DestructorCallExpr&>(*expression);
      call_expression.TargetAddress = AnalyzeExpr(std::move(call_expression.TargetAddress));
      InheritErrors(call_expression, call_expression.TargetAddress.get());
      if (!call_expression.Callee || call_expression.Callee->GetKind() != NodeKind::DeclRefExpr) {
        call_expression.Callee = AnalyzeExpr(std::move(call_expression.Callee));
      }
      InheritErrors(call_expression, call_expression.Callee.get());
      for (auto& argument : call_expression.Args) {
        argument = AnalyzeExpr(std::move(argument));
        InheritErrors(call_expression, argument.get());
      }
      AnalyzeDestructorCallExpr(call_expression);
      break;
    }
    case NodeKind::ReceiverCallExpr: {
      auto& call_expression = static_cast<ReceiverCallExpr&>(*expression);
      call_expression.Receiver = AnalyzeExpr(std::move(call_expression.Receiver));
      InheritErrors(call_expression, call_expression.Receiver.get());
      call_expression.Callee = AnalyzeCalleeExpr(std::move(call_expression.Callee));
      InheritErrors(call_expression, call_expression.Callee.get());
      for (auto& argument : call_expression.Args) {
        argument = AnalyzeExpr(std::move(argument));
        InheritErrors(call_expression, argument.get());
      }
      AnalyzeReceiverCallExpr(call_expression);
      break;
    }
    case NodeKind::ImplicitOverloadSetSelectionExpr:
    case NodeKind::ImplicitCastExpr:
    case NodeKind::MaterializeTemporaryExpr:
      break;
    default:
      BOOST_ASSERT(false && "unsupported expression node");
      break;
  }

  // Parentheses and unary signs preserve exact integers until the enclosing expression requests
  // a runtime type, so the complete value determines materialization.
  if (!expression->ContainsErrors() && expression->type &&
      expression->type.GetTypePtr()->GetKind() == TypeKind::ComptimeInt && mode == ComptimeIntMode::Materialize) {
    MaterializeComptimeInteger(expression);
  }
  return expression;
}

std::unique_ptr<Expr> Sema::AnalyzeCalleeExpr(std::unique_ptr<Expr> expression) {
  if (!expression || expression->GetKind() != NodeKind::DeclRefExpr) {
    return AnalyzeExpr(std::move(expression));
  }

  return AnalyzeDeclRefExpr(std::move(expression), DeclRefRole::Callee);
}

std::unique_ptr<Expr> Sema::AnalyzeUnaryOperator(std::unique_ptr<Expr> expression) {
  BOOST_ASSERT(expression && expression->GetKind() == NodeKind::UnaryOperator);
  auto& unary = static_cast<UnaryOperator&>(*expression);
  if (IsOverloadableUnaryOperator(unary.op) && unary.Operand && !unary.Operand->ContainsErrors() &&
      unary.Operand->type && IsStructObjectOperand(*unary.Operand)) {
    return AnalyzeOverloadableOperator(std::move(expression), unary.op, unary.operator_range, {&unary.Operand});
  }
  AnalyzeBuiltinUnaryOperator(unary);
  return expression;
}

std::unique_ptr<Expr> Sema::AnalyzeBinaryOperator(std::unique_ptr<Expr> expression) {
  BOOST_ASSERT(expression && expression->GetKind() == NodeKind::BinaryOperator);
  auto& binary = static_cast<BinaryOperator&>(*expression);
  const bool has_struct_operand =
      (binary.LHS && !binary.LHS->ContainsErrors() && binary.LHS->type && IsStructObjectOperand(*binary.LHS)) ||
      (binary.RHS && !binary.RHS->ContainsErrors() && binary.RHS->type && IsStructObjectOperand(*binary.RHS));
  if (IsOverloadableBinaryOperator(binary.op) && has_struct_operand) {
    return AnalyzeOverloadableOperator(std::move(expression), binary.op, binary.operator_range,
                                       {&binary.LHS, &binary.RHS});
  }
  AnalyzeBuiltinBinaryOperator(binary);
  return expression;
}

std::unique_ptr<Expr> Sema::AnalyzeOverloadableOperator(std::unique_ptr<Expr> expression, expr::ExprGrammarSymbol op,
                                                        SourceRange operator_range,
                                                        const std::vector<std::unique_ptr<Expr>*>& operand_slots) {
  BOOST_ASSERT(expression);
  BOOST_ASSERT(!operand_slots.empty());
  expression->type = QualType{};
  expression->value_category = ValueCategory::None;

  std::vector<const Expr*> operands;
  operands.reserve(operand_slots.size());
  for (const auto* slot : operand_slots) {
    BOOST_ASSERT(slot && *slot);
    if ((*slot)->ContainsErrors() || !(*slot)->type) {
      return expression;
    }
    operands.push_back(slot->get());
  }
  const auto semantic_arguments = MakeConversionSources(operands);

  const std::string op_spelling(expr::to_string(op));
  std::vector<const FunctionDecl*> function_declarations;
  if (const FunctionSymbol* symbol = AsFunctionSymbol(symbol_table_.LookupRoot(op_spelling))) {
    function_declarations = CollectOperatorFunctionCandidates(*symbol, op_spelling, operands.size());
  }

  OverloadResult resolution = ResolveOverload(semantic_arguments, function_declarations, *ast_context_, symbol_table_);
  if (const auto* no_viable = std::get_if<NoViableOverload>(&resolution)) {
    if (function_declarations.empty()) {
      if (operands.size() == 1) {
        Diagnose(*expression, kErrorDiagnostic, expression->range,
                 fmt::format("unary operator '{}' cannot be applied to {}", op_spelling,
                             DescribeExpressionType(operands.front()->type, "type ")));
      } else {
        Diagnose(*expression, kErrorDiagnostic, expression->range,
                 fmt::format("binary operator '{}' cannot be applied to {}", op_spelling,
                             DescribeOperandTypes(operands[0]->type, operands[1]->type, "types ")));
      }
      return expression;
    }

    Diagnose(*expression, kErrorDiagnostic, expression->range,
             fmt::format("no matching overloaded operator '{}'", op_spelling));
    for (const auto& candidate : no_viable->candidates) {
      BOOST_ASSERT(candidate.target);
      const auto* argument = std::get_if<CandidateArgumentFailure>(&candidate.failure);
      if (!argument) {
        continue;
      }
      EmitDiagnostic(kNoteDiagnostic, {candidate.target->range.begin, candidate.target->range.begin},
                     fmt::format("candidate function is not viable: {} for operand {}",
                                 FormatConversionFailure(argument->failure), argument->index + 1));
    }
    return expression;
  }

  if (const auto* ambiguous = std::get_if<AmbiguousOverload>(&resolution)) {
    Diagnose(*expression, kErrorDiagnostic, expression->range,
             fmt::format("use of overloaded operator '{}' is ambiguous", op_spelling));
    for (const FunctionDecl* declaration : ambiguous->candidates) {
      EmitDiagnostic(kNoteDiagnostic, {declaration->range.begin, declaration->range.begin}, "candidate function");
    }
    return expression;
  }

  const auto& selected = std::get<SelectedOverload>(resolution);
  const FunctionDecl* declaration = selected.target;
  BOOST_ASSERT(declaration);
  const auto& function_type = static_cast<const FunctionType&>(*declaration->type.GetTypePtr());
  const auto& parameter_types = function_type.GetParameterTypes();
  auto formation = CompleteArguments(semantic_arguments, *declaration, selected.conversions, symbol_table_);

  auto call = std::make_unique<OperatorCallExpr>();
  call->range = expression->range;
  call->Args.reserve(operand_slots.size());
  for (auto* slot : operand_slots) call->Args.push_back(std::move(*slot));

  auto callee = std::make_unique<DeclRefExpr>();
  callee->range = operator_range;
  callee->name = op_spelling;
  callee->declaration = declaration;
  callee->type = declaration->type;
  call->Callee = std::move(callee);

  if (const auto* failure = std::get_if<ArgumentCompletionFailure>(&formation)) {
    BOOST_ASSERT(failure->index < call->Args.size());
    Diagnose(*call, kErrorDiagnostic, call->Args[failure->index]->range,
             fmt::format("cannot initialize parameter {} of operator '{}': {}", failure->index + 1, op_spelling,
                         FormatObjectFormationFailure(failure->failure)));
    return call;
  }

  const auto& plans = std::get<std::vector<ConversionSequence>>(formation);
  BOOST_ASSERT(plans.size() == call->Args.size());
  CommitArgumentConversions(ExpressionSlots(call->Args), parameter_types, plans);
  FormCallResult(*call, function_type);
  return call;
}

void Sema::AnalyzeBuiltinUnaryOperator(UnaryOperator& expression) {
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;
  if (!expression.Operand || expression.Operand->ContainsErrors() || !expression.Operand->type) {
    return;
  }

  const QualType operand_type = expression.Operand->type;
  if (expression.op == expr::amp) {
    if (operand_type.GetTypePtr()->GetKind() == TypeKind::FunctionOverloadSet) {
      expression.type = QualType(ast_context_->GetAddressOfFunctionOverloadSetType());
      expression.value_category = ValueCategory::None;
      return;
    }
    if (!operand_type.GetTypePtr()->IsObject() || expression.Operand->value_category != ValueCategory::LValue) {
      Diagnose(expression, kErrorDiagnostic, expression.range, "unary operator '&' requires an object lvalue operand");
      return;
    }

    expression.type = QualType(ast_context_->GetPointerType(operand_type));
    expression.value_category = ValueCategory::PureRValue;
    return;
  }

  if (expression.op == expr::star) {
    if (operand_type.GetTypePtr()->GetKind() != TypeKind::Pointer) {
      Diagnose(
          expression, kErrorDiagnostic, expression.range,
          fmt::format("unary operator '*' requires a pointer operand, not {}", DescribeExpressionType(operand_type)));
      return;
    }

    const QualType pointee_type = static_cast<const PointerType*>(operand_type.GetTypePtr())->GetPointee();
    if (!(pointee_type && pointee_type.GetTypePtr()->IsObject())) {
      Diagnose(expression, kErrorDiagnostic, expression.range,
               fmt::format("unary operator '*' requires a pointer to an object, not '{}'", TypeSpelling(operand_type)));
      return;
    }

    ApplyDefaultValueConversion(expression.Operand);
    expression.type = pointee_type;
    expression.value_category = ValueCategory::LValue;
    return;
  }

  if (expression.op == expr::move_) {
    if (expression.Operand->value_category == ValueCategory::LValue &&
        (operand_type && operand_type.GetTypePtr()->IsObject())) {
      expression.type = operand_type;
      expression.value_category = ValueCategory::MoveLValue;
      return;
    }
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("'move' requires an lvalue of object type, not {}", DescribeExpressionType(operand_type)));
    return;
  }

  if (expression.op == expr::exclaim) {
    if (operand_type.WithoutConst() == QualType(ast_context_->GetBuiltinType(BuiltinTypeKind::Bool))) {
      ApplyDefaultValueConversion(expression.Operand);
      expression.type = operand_type.WithoutConst();
      expression.value_category = ValueCategory::PureRValue;
      return;
    }
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("unary operator '!' cannot be applied to {}", DescribeExpressionType(operand_type, "type ")));
    return;
  }

  if (expression.op != expr::plus && expression.op != expr::minus) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("unary operator '{}' is not supported", expr::to_string(expression.op)));
    return;
  }

  if (operand_type.GetTypePtr()->GetKind() == TypeKind::ComptimeInt) {
    expression.type = QualType(ast_context_->GetComptimeIntType());
    return;
  }

  const BuiltinType* builtin_type = operand_type.GetTypePtr()->AsBuiltinType();
  if (builtin_type && builtin_type->IsFloatingPoint()) {
    ApplyDefaultValueConversion(expression.Operand);
    expression.type = operand_type.WithoutConst();
    expression.value_category = ValueCategory::PureRValue;
    return;
  }

  const BuiltinType* integer_type = builtin_type && builtin_type->IsInteger() ? builtin_type : nullptr;
  if (!integer_type) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("unary operator '{}' cannot be applied to {}", expr::to_string(expression.op),
                         DescribeExpressionType(operand_type, "type ")));
    return;
  }

  if (expression.op == expr::plus || integer_type->IsSignedInteger()) {
    ApplyDefaultValueConversion(expression.Operand);
    expression.type = operand_type.WithoutConst();
    expression.value_category = ValueCategory::PureRValue;
    return;
  }

  if (integer_type->IsUnsignedInteger()) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("unary '-' cannot be applied to unsigned integer type '{}'",
                         to_string(integer_type->GetBuiltinTypeKind())));
  }
}

void Sema::AnalyzeBuiltinBinaryOperator(BinaryOperator& expression) {
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;
  if (!expression.LHS || !expression.RHS || expression.LHS->ContainsErrors() || expression.RHS->ContainsErrors() ||
      !expression.LHS->type || !expression.RHS->type) {
    return;
  }

  const bool is_arithmetic = IsArithmeticBinaryOperator(expression.op);
  const bool is_ordered_comparison = IsOrderedComparisonOperator(expression.op);
  const bool is_equality = IsEqualityOperator(expression.op);
  const bool is_logical = IsLogicalBinaryOperator(expression.op);
  if (!is_arithmetic && !is_ordered_comparison && !is_equality && !is_logical) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("binary operator '{}' is not supported", expr::to_string(expression.op)));
    return;
  }

  const QualType bool_type(ast_context_->GetBuiltinType(BuiltinTypeKind::Bool));
  if (is_logical) {
    if (expression.LHS->type.WithoutConst() == bool_type && expression.RHS->type.WithoutConst() == bool_type) {
      ApplyDefaultValueConversion(expression.LHS);
      ApplyDefaultValueConversion(expression.RHS);
      expression.type = bool_type;
      expression.value_category = ValueCategory::PureRValue;
      return;
    }
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("binary operator '{}' cannot be applied to {}", expr::to_string(expression.op),
                         DescribeOperandTypes(expression.LHS->type, expression.RHS->type, "types ")));
    return;
  }

  if (is_equality && expression.LHS->type.WithoutConst() == bool_type &&
      expression.RHS->type.WithoutConst() == bool_type) {
    ApplyDefaultValueConversion(expression.LHS);
    ApplyDefaultValueConversion(expression.RHS);
    expression.type = bool_type;
    expression.value_category = ValueCategory::PureRValue;
    return;
  }

  const bool left_null = expression.LHS->type.GetTypePtr()->AsNullType();
  const bool right_null = expression.RHS->type.GetTypePtr()->AsNullType();
  if (is_equality && left_null && right_null) {
    expression.type = bool_type;
    expression.value_category = ValueCategory::PureRValue;
    return;
  }

  const auto* left_builtin = expression.LHS->type.GetTypePtr()->AsBuiltinType();
  const auto* right_builtin = expression.RHS->type.GetTypePtr()->AsBuiltinType();
  const bool invalid_remainder_operands =
      expression.op == expr::percent &&
      (!left_builtin || !left_builtin->IsInteger() || !right_builtin || !right_builtin->IsInteger());
  QualType common_type(invalid_remainder_operands
                           ? nullptr
                           : CommonNumericType(*ast_context_, expression.LHS->type, expression.RHS->type));
  // Function and virtual interface pointers support null checks only. Raw
  // pointer equality additionally permits two compatible concrete pointers.
  const bool pointer_equality =
      is_equality && ((left_null && IsPointerValueType(expression.RHS->type)) ||
                      (right_null && IsPointerValueType(expression.LHS->type)) ||
                      (IsRawPointerType(expression.LHS->type) && IsRawPointerType(expression.RHS->type)));
  if (pointer_equality) {
    common_type = CommonPointerValueType(*ast_context_, expression.LHS->type, expression.RHS->type);
  }
  if (!common_type) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("binary operator '{}' cannot be applied to {}", expr::to_string(expression.op),
                         DescribeOperandTypes(expression.LHS->type, expression.RHS->type, "types ")));
    return;
  }

  auto lhs_result = BuildValueConversion(MakeConversionSource(*expression.LHS).state, common_type, *ast_context_);
  auto rhs_result = BuildValueConversion(MakeConversionSource(*expression.RHS).state, common_type, *ast_context_);
  const auto* lhs_plan = std::get_if<ConversionSequence>(&lhs_result);
  const auto* rhs_plan = std::get_if<ConversionSequence>(&rhs_result);
  BOOST_ASSERT(lhs_plan && rhs_plan);
  if (!lhs_plan || !rhs_plan) {
    return;
  }
  expression.LHS =
      CommitConversion(std::move(expression.LHS), common_type, *lhs_plan, ConstructionKind::CompleteObject);
  expression.RHS =
      CommitConversion(std::move(expression.RHS), common_type, *rhs_plan, ConstructionKind::CompleteObject);
  expression.type = is_arithmetic ? common_type : bool_type;
  expression.value_category = ValueCategory::PureRValue;
}

void Sema::AnalyzeSubscriptExpr(SubscriptExpr& expression) {
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;
  if (!expression.Base || !expression.Index || expression.Base->ContainsErrors() ||
      expression.Index->ContainsErrors() || !expression.Base->type || !expression.Index->type) {
    return;
  }

  if (expression.Base->type.GetTypePtr()->GetKind() != TypeKind::Array) {
    Diagnose(expression, kErrorDiagnostic, expression.Base->range,
             fmt::format("subscripted expression must have array type, not {}",
                         DescribeExpressionType(expression.Base->type)));
    return;
  }

  const QualType usize_type(ast_context_->GetBuiltinType(BuiltinTypeKind::USize));
  if (expression.Index->type.WithoutConst() != usize_type) {
    Diagnose(
        expression, kErrorDiagnostic, expression.Index->range,
        fmt::format("array subscript must have type 'usize', not {}", DescribeExpressionType(expression.Index->type)));
    return;
  }
  ApplyDefaultValueConversion(expression.Index);

  if (expression.Base->value_category == ValueCategory::PureRValue) {
    auto materialization = std::make_unique<MaterializeTemporaryExpr>();
    materialization->range = expression.Base->range;
    materialization->type = expression.Base->type;
    materialization->value_category = ValueCategory::MoveLValue;
    materialization->SubExpr = std::move(expression.Base);
    expression.Base = std::move(materialization);
  }
  if (expression.Base->value_category != ValueCategory::LValue &&
      expression.Base->value_category != ValueCategory::MoveLValue) {
    Diagnose(expression, kErrorDiagnostic, expression.Base->range, "array subscript requires an array object value");
    return;
  }

  const auto* array_type = static_cast<const ArrayType*>(expression.Base->type.GetTypePtr());
  QualType element_type = array_type->GetElementType();
  if (expression.Base->type.IsConstQualified()) {
    element_type = element_type.WithConst();
  }
  expression.type = element_type;
  expression.value_category = expression.Base->value_category;
}

void Sema::AnalyzeArrayValueExpr(ArrayValueExpr& expression, QualType contextual_type) {
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;

  // Nested brace initializers obtain their array shape from the enclosing element type.
  QualType array_qual_type;
  if (expression.Type) {
    array_qual_type = ResolveType(*expression.Type);
    InheritErrors(expression, expression.Type.get());
    if (array_qual_type) {
      ValidateAbstractTypeUse(*expression.Type, array_qual_type, TypeUseKind::ArrayElement);
      InheritErrors(expression, expression.Type.get());
    }
  } else {
    array_qual_type = contextual_type.WithoutConst();
    if (!array_qual_type || array_qual_type.GetTypePtr()->GetKind() != TypeKind::Array) {
      Diagnose(expression, kErrorDiagnostic, expression.range,
               "nested array initializer requires an array element type");
      return;
    }
  }
  if (!array_qual_type || array_qual_type.GetTypePtr()->GetKind() != TypeKind::Array) {
    return;
  }

  expression.type = array_qual_type.WithoutConst();
  const auto* array_type = static_cast<const ArrayType*>(array_qual_type.GetTypePtr());
  const QualType element_type = array_type->GetElementType();
  const ArrayLength expected_count = array_type->GetLength();
  bool valid = !expression.ContainsErrors();

  if (expression.Elements.size() != expected_count) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("array value requires exactly {} element{}, but {} {} provided", expected_count,
                         expected_count == 1 ? "" : "s", expression.Elements.size(),
                         expression.Elements.size() == 1 ? "was" : "were"));
    valid = false;
  }

  // Analyze surplus elements for their own errors without assigning them a nonexistent target.
  const std::size_t corresponding_count = expected_count < expression.Elements.size()
                                              ? static_cast<std::size_t>(expected_count)
                                              : expression.Elements.size();
  for (std::size_t index = 0; index < expression.Elements.size(); ++index) {
    auto& element = expression.Elements[index];
    if (!element) {
      valid = false;
      continue;
    }
    if (element->GetKind() == NodeKind::ArrayValueExpr && !static_cast<ArrayValueExpr&>(*element).Type) {
      if (index < corresponding_count) {
        AnalyzeArrayValueExpr(static_cast<ArrayValueExpr&>(*element), element_type);
      } else {
        AnalyzeArrayValueElementsForRecovery(static_cast<ArrayValueExpr&>(*element));
      }
    } else {
      ConstructionResultContext element_context;
      const ConstructionResultContext* context = nullptr;
      if (index < corresponding_count) {
        element_context.target_type = element_type.WithoutConst();
        context = &element_context;
      }
      element = AnalyzeExpr(std::move(element), ComptimeIntMode::Materialize, ExpressionUse::General, context);
    }
    InheritErrors(expression, element.get());
    if (!element || element->ContainsErrors() || !element->type) {
      valid = false;
    }
  }

  // Prepare every element conversion before committing any of the array's conversions.
  std::vector<ConversionSequence> plans;
  plans.reserve(corresponding_count);
  for (std::size_t index = 0; index < corresponding_count; ++index) {
    const auto& element = expression.Elements[index];
    if (!element || element->ContainsErrors() || !element->type) {
      valid = false;
      continue;
    }
    const auto source = MakeConversionSource(*element);
    auto result = BuildConversion(source, element_type, *ast_context_, symbol_table_);
    if (const auto* failure = std::get_if<ConversionFailure>(&result)) {
      Diagnose(expression, kErrorDiagnostic, element->range,
               fmt::format("cannot initialize array element {}: {}", index, FormatConversionFailure(*failure)));
      valid = false;
      continue;
    }
    auto conversion = std::get<ConversionSequence>(std::move(result));
    if (const auto failure = CompleteConversion(source, element_type, conversion, symbol_table_)) {
      Diagnose(
          expression, kErrorDiagnostic, element->range,
          fmt::format("cannot initialize array element {}: {}", index, FormatObjectFormationFailure(failure->failure)));
      valid = false;
      continue;
    }
    plans.push_back(std::move(conversion));
  }
  if (!valid || plans.size() != corresponding_count || corresponding_count != expression.Elements.size()) {
    return;
  }
  for (std::size_t index = 0; index < expression.Elements.size(); ++index) {
    DiagnoseConversionRisks(*expression.Elements[index], *expression.Elements[index], element_type, plans[index]);
  }
  for (std::size_t index = 0; index < expression.Elements.size(); ++index) {
    auto& element = expression.Elements[index];
    element = CommitConversion(std::move(element), element_type, plans[index], ConstructionKind::CompleteObject);
  }
  expression.value_category = ValueCategory::PureRValue;
}

void Sema::AnalyzeArrayValueElementsForRecovery(ArrayValueExpr& expression) {
  expression.contains_errors = true;
  for (auto& element : expression.Elements) {
    if (!element) {
      continue;
    }
    if (element->GetKind() == NodeKind::ArrayValueExpr && !static_cast<ArrayValueExpr&>(*element).Type) {
      AnalyzeArrayValueElementsForRecovery(static_cast<ArrayValueExpr&>(*element));
    } else {
      element = AnalyzeExpr(std::move(element));
    }
    InheritErrors(expression, element.get());
  }
}

std::unique_ptr<Expr> Sema::AnalyzeSimpleAssignment(std::unique_ptr<Expr> expression_node) {
  BOOST_ASSERT(expression_node && expression_node->GetKind() == NodeKind::BinaryOperator);
  auto& expression = static_cast<BinaryOperator&>(*expression_node);
  BOOST_ASSERT(expression.IsSimpleAssignment());
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;

  if (!expression.LHS) {
    expression.contains_errors = true;
    return expression_node;
  }
  if (expression.LHS->ContainsErrors()) {
    return expression_node;
  }
  if (!expression.LHS->type) {
    expression.contains_errors = true;
    return expression_node;
  }

  const QualType target_type = expression.LHS->type;
  if (expression.LHS->value_category != ValueCategory::LValue || target_type.IsConstQualified() ||
      !(target_type && target_type.GetTypePtr()->IsObject())) {
    Diagnose(expression, kErrorDiagnostic, expression.LHS->range,
             fmt::format("assignment target must be a modifiable lvalue, not {}", DescribeExpressionType(target_type)));
    return expression_node;
  }

  if (!expression.RHS) {
    expression.contains_errors = true;
    return expression_node;
  }
  if (expression.RHS->ContainsErrors()) {
    return expression_node;
  }
  if (!expression.RHS->type) {
    expression.contains_errors = true;
    return expression_node;
  }

  if (!SelectAssignmentFunctionAddress(expression.RHS, target_type, expression)) {
    return expression_node;
  }

  const QualType source_type = expression.RHS->type;
  const SourceRange source_range = expression.RHS->range;
  if (target_type.WithoutConst() == source_type.WithoutConst()) {
    auto assignment_result = ClassifyObjectAssignment(*expression.LHS, *expression.RHS, symbol_table_);
    if (const auto* failure = std::get_if<ObjectAssignmentFailure>(&assignment_result)) {
      const SourceRange range =
          failure->kind == ObjectAssignmentFailureKind::ConstArrayElement ? expression.LHS->range : expression.range;
      Diagnose(expression, kErrorDiagnostic, range, FormatObjectAssignmentFailure(*failure));
      return expression_node;
    }

    const auto& assignment_plan = std::get<ObjectAssignmentPlan>(assignment_result);
    switch (assignment_plan.kind) {
      case ObjectAssignmentKind::Builtin:
        break;
      case ObjectAssignmentKind::OperatorCall: {
        BOOST_ASSERT(assignment_plan.selected_assignment);
        auto call = std::make_unique<OperatorCallExpr>();
        call->range = expression.range;
        call->Args.reserve(2);
        call->Args.push_back(std::move(expression.LHS));
        call->Args.push_back(std::move(expression.RHS));
        const auto& parameters = FunctionParameterTypes(*assignment_plan.selected_assignment);
        const auto sources = MakeConversionSources(ExpressionPointers(call->Args));
        auto matched = MatchArguments(sources, parameters, *ast_context_, symbol_table_);
        auto* conversions = std::get_if<std::vector<ConversionSequence>>(&matched);
        BOOST_ASSERT(conversions);
        if (!conversions) {
          call->contains_errors = true;
          return call;
        }
        // Both fixed-slot operands bind references, so no formation is pending.
        auto completed = CompleteArguments(sources, parameters, std::move(*conversions), symbol_table_);
        BOOST_ASSERT(std::holds_alternative<std::vector<ConversionSequence>>(completed));
        CommitArgumentConversions(ExpressionSlots(call->Args), parameters,
                                  std::get<std::vector<ConversionSequence>>(completed));

        auto callee = std::make_unique<DeclRefExpr>();
        callee->range = expression.operator_range;
        callee->name = "=";
        call->Callee = std::move(callee);
        FormDirectCallResult(*call, static_cast<DeclRefExpr&>(*call->Callee), *assignment_plan.selected_assignment);
        return call;
      }
      case ObjectAssignmentKind::ArrayAssign: {
        BOOST_ASSERT(assignment_plan.selected_assignment);
        auto assignment = std::make_unique<ArrayAssignmentExpr>();
        assignment->range = expression.range;
        assignment->operator_range = expression.operator_range;
        assignment->element_assignment = assignment_plan.selected_assignment;
        assignment->type = target_type;
        assignment->value_category = ValueCategory::LValue;
        assignment->LHS = std::move(expression.LHS);
        assignment->RHS = std::move(expression.RHS);
        return assignment;
      }
    }
  }

  // Ordinary assignment does not perform derived-to-base value slicing or
  // initialize an object through a constructor.
  const bool same_type = source_type.WithoutConst() == target_type.WithoutConst();
  if (!same_type && ((!source_type.GetTypePtr()->IsScalar() && !source_type.GetTypePtr()->AsNullType()) ||
                     !target_type.GetTypePtr()->IsScalar())) {
    Diagnose(expression, kErrorDiagnostic, source_range,
             fmt::format("cannot assign to target: {}",
                         FormatImplicitConversionFailure({ImplicitConversionFailureKind::NoConversion,
                                                          source_type.WithoutConst(), target_type.WithoutConst()})));
    return expression_node;
  }
  auto result = BuildValueConversion(MakeConversionSource(*expression.RHS).state, target_type, *ast_context_);
  if (const auto* failure = std::get_if<ImplicitConversionFailure>(&result)) {
    Diagnose(expression, kErrorDiagnostic, source_range,
             fmt::format("cannot assign to target: {}", FormatImplicitConversionFailure(*failure)));
    return expression_node;
  }
  const auto& conversion = std::get<ConversionSequence>(result);
  DiagnoseConversionRisks(expression, *expression.RHS, target_type, conversion);
  expression.RHS =
      CommitConversion(std::move(expression.RHS), target_type, conversion, ConstructionKind::CompleteObject);
  expression.type = target_type;
  expression.value_category = ValueCategory::LValue;
  return expression_node;
}

void Sema::AnalyzeInitializationExpr(InitializationExpr& expression, ExpressionUse use) {
  expression.type = QualType(ast_context_->GetBuiltinType(BuiltinTypeKind::Void));
  expression.value_category = ValueCategory::None;

  if (!expression.Target) {
    expression.contains_errors = true;
  } else {
    expression.Target = AnalyzeExpr(std::move(expression.Target));
    InheritErrors(expression, expression.Target.get());
  }

  // Check statement placement and target spelling before resolving which object may be initialized.
  bool target_is_valid = expression.Target && !expression.Target->ContainsErrors();
  const bool is_initialization_statement =
      use == ExpressionUse::InitializationStatement || use == ExpressionUse::ConstructorPrologue;
  if (!is_initialization_statement) {
    if (expression.Target) {
      Diagnose(*expression.Target, kErrorDiagnostic, expression.range,
               "initialization expression must be used directly as an expression statement");
    } else {
      expression.contains_errors = true;
    }
    target_is_valid = false;
  }

  if (InitializationTargetContainsParentheses(expression.Target.get())) {
    if (target_is_valid && is_initialization_statement) {
      Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
               "initialization target must not contain grouping parentheses");
    }
    target_is_valid = false;
  }

  if (InitializationTargetContainsArrayElementProjection(expression.Target.get())) {
    if (target_is_valid && is_initialization_statement) {
      Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
               "cannot initialize an array element or its subobject separately");
    }
    target_is_valid = false;
  }

  // Walk projections back to their root. A constructor base path is checked as a whole below,
  // so crossing its nontrivial base does not fail the ordinary subobject restriction here.
  const Expr* root = expression.Target.get();
  std::vector<const Expr*> path;
  const Expr* preliminary_root = root;
  const Expr* first_projection = nullptr;
  while (preliminary_root && (preliminary_root->GetKind() == NodeKind::MemberExpr ||
                              preliminary_root->GetKind() == NodeKind::BaseSubobjectExpr)) {
    first_projection = preliminary_root;
    preliminary_root = preliminary_root->GetKind() == NodeKind::MemberExpr
                           ? static_cast<const MemberExpr*>(preliminary_root)->Base.get()
                           : static_cast<const BaseSubobjectExpr*>(preliminary_root)->Base.get();
  }
  const bool targets_constructor_base_path =
      current_function_ && current_function_->GetKind() == NodeKind::ConstructorDecl && preliminary_root &&
      preliminary_root->GetKind() == NodeKind::ThisExpr && first_projection &&
      first_projection->GetKind() == NodeKind::BaseSubobjectExpr;
  while (root && (root->GetKind() == NodeKind::MemberExpr || root->GetKind() == NodeKind::BaseSubobjectExpr)) {
    path.push_back(root);
    const Expr* base = nullptr;
    expr::ExprGrammarSymbol access_operator{};
    bool has_declaration = false;
    if (root->GetKind() == NodeKind::MemberExpr) {
      const auto& member = static_cast<const MemberExpr&>(*root);
      base = member.Base.get();
      access_operator = member.op;
      has_declaration = member.declaration;
    } else {
      const auto& base_subobject = static_cast<const BaseSubobjectExpr&>(*root);
      base = base_subobject.Base.get();
      access_operator = base_subobject.op;
      has_declaration = base_subobject.GetDeclaration();
    }
    if (access_operator == expr::arrow || !has_declaration || !base || !base->type) {
      if (target_is_valid) {
        Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
                 "initialization target must name an object directly or through '.'");
      }
      target_is_valid = false;
      break;
    }
    if (base->type.GetTypePtr()->GetKind() == TypeKind::Struct) {
      const StructDecl* base_structure = static_cast<const StructType*>(base->type.GetTypePtr())->GetDeclaration();
      const bool is_current_constructor_object = base->GetKind() == NodeKind::ThisExpr && current_function_ &&
                                                 current_function_->GetKind() == NodeKind::ConstructorDecl;
      if (base_structure->triviality == TypeTriviality::NonTrivial && !is_current_constructor_object &&
          !targets_constructor_base_path) {
        Diagnose(*expression.Target, kErrorDiagnostic, base->range,
                 fmt::format("cannot initialize a subobject of type '{}' separately", base_structure->name));
        target_is_valid = false;
        break;
      }
    }
    root = base;
  }
  std::reverse(path.begin(), path.end());

  if (!root || (root->GetKind() != NodeKind::DeclRefExpr && root->GetKind() != NodeKind::ThisExpr) ||
      (root->GetKind() == NodeKind::ThisExpr && !current_function_)) {
    if (target_is_valid) {
      Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
               "initialization target must be rooted in a local object, result object, or the constructor's current "
               "object");
    }
    target_is_valid = false;
  }

  // Constructors may delegate to the whole object or initialize their direct base and own fields.
  // Delegation and direct-base initialization must occupy the constructor prologue.
  const bool targets_current_this = root && root->GetKind() == NodeKind::ThisExpr && current_function_ &&
                                    current_function_->GetKind() == NodeKind::ConstructorDecl;
  bool is_delegating_target = false;
  if (root && root->GetKind() == NodeKind::ThisExpr && !targets_current_this) {
    if (target_is_valid) {
      Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
               "only a constructor can initialize the current object");
    }
    target_is_valid = false;
  } else if (targets_current_this && path.empty()) {
    if (target_is_valid) {
      is_delegating_target = true;
      if (use != ExpressionUse::ConstructorPrologue) {
        Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
                 "constructor delegation must be the first complete statement in the constructor body");
        target_is_valid = false;
      }
    }
  } else if (targets_current_this && !path.empty() && target_is_valid) {
    const auto& constructor = static_cast<const ConstructorDecl&>(*current_function_);
    const Expr* first = path.front();
    if (first->GetKind() == NodeKind::BaseSubobjectExpr) {
      const auto& selected_base = static_cast<const BaseSubobjectExpr&>(*first);
      const StructDecl* required_base = constructor.target_type && constructor.target_type->GetDeclaration()->base_type
                                            ? constructor.target_type->GetDeclaration()->base_type->GetDeclaration()
                                            : nullptr;
      const bool targets_whole_base = path.size() == 1 && expression.Target.get() == first;
      const bool targets_required_base =
          selected_base.base_path.size() == 1 && required_base && selected_base.GetDeclaration() == required_base;
      if (!targets_whole_base) {
        if (required_base) {
          Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
                   fmt::format("constructor for '{}' must initialize direct base '{}' as a whole", constructor.name,
                               required_base->name));
        } else {
          expression.Target->contains_errors = true;
        }
        target_is_valid = false;
      } else if (!targets_required_base) {
        if (required_base && selected_base.GetDeclaration()) {
          Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
                   fmt::format("constructor for '{}' must initialize direct base '{}', not indirect base '{}'",
                               constructor.name, required_base->name, selected_base.GetDeclaration()->name));
        } else {
          expression.Target->contains_errors = true;
        }
        target_is_valid = false;
      } else if (use != ExpressionUse::ConstructorPrologue) {
        Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
                 fmt::format("direct base '{}' must be initialized by the first complete statement of constructor "
                             "'{}'",
                             required_base->name, constructor.name));
        target_is_valid = false;
      }
    } else {
      const FieldDecl* first_field = static_cast<const MemberExpr&>(*first).declaration;
      bool is_direct_field = false;
      if (constructor.target_type && first_field) {
        for (const auto& field : constructor.target_type->GetDeclaration()->Fields) {
          if (field.get() == first_field) {
            is_direct_field = true;
            break;
          }
        }
      }
      if (!is_direct_field) {
        const StructDecl* direct_base = constructor.target_type && constructor.target_type->GetDeclaration()->base_type
                                            ? constructor.target_type->GetDeclaration()->base_type->GetDeclaration()
                                            : nullptr;
        if (first_field && direct_base) {
          Diagnose(*expression.Target, kErrorDiagnostic, first->range,
                   fmt::format("constructor for '{}' cannot initialize inherited field '{}' directly; initialize "
                               "direct base '{}' instead",
                               constructor.name, first_field->name, direct_base->name));
        } else {
          expression.Target->contains_errors = true;
        }
        target_is_valid = false;
      }
    }
  }

  // Named targets must denote variables; a reference cannot grant access to unformed subobjects.
  const ValueDecl* value_declaration = nullptr;
  if (root && root->GetKind() == NodeKind::DeclRefExpr) {
    value_declaration = static_cast<const DeclRefExpr*>(root)->declaration;
    if (!value_declaration) {
      if (target_is_valid) {
        Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
                 "initialization target must name an object");
      }
      target_is_valid = false;
    }
  }
  const VarDecl* target_declaration = nullptr;
  if (value_declaration) {
    switch (value_declaration->GetKind()) {
      case NodeKind::VarDecl:
      case NodeKind::ParmVarDecl:
      case NodeKind::ReturnVarDecl:
        target_declaration = static_cast<const VarDecl*>(value_declaration);
        break;
      default:
        break;
    }
  }
  if (value_declaration && !target_declaration) {
    Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
             "initialization target must name an object");
    target_is_valid = false;
  }
  if (target_declaration && current_function_ &&
      global_variables_.find(target_declaration) != global_variables_.end()) {
    Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
             "initializing a global variable from a function is not supported");
    target_is_valid = false;
  }
  if (value_declaration && !path.empty() && value_declaration->type &&
      value_declaration->type.GetTypePtr()->AsReferenceType()) {
    Diagnose(*expression.Target, kErrorDiagnostic, expression.Target->range,
             "cannot initialize a subobject through a reference");
    target_is_valid = false;
  }
  if (!expression.Target || !expression.Target->type || expression.Target->type.GetTypePtr()->IsVoid()) {
    expression.contains_errors = true;
    target_is_valid = false;
  }

  InheritErrors(expression, expression.Target.get());

  // Carry the final destination kind into source analysis so base and delegating construction
  // are distinguished from forming an independent complete object.
  ConstructionResultContext construction_context;
  if (expression.Target && expression.Target->type) {
    construction_context.target_type = expression.Target->type.WithoutConst();
    if (is_delegating_target) {
      construction_context.construction_kind = ConstructionKind::Delegating;
    } else if (expression.Target->GetKind() == NodeKind::BaseSubobjectExpr) {
      construction_context.construction_kind = ConstructionKind::BaseSubobject;
    }
  }

  // Delegation requires a direct call to the current type, even when parentheses wrap that call.
  bool has_direct_delegating_source = true;
  if (is_delegating_target && expression.Source) {
    has_direct_delegating_source = false;
    const Expr* source = expression.Source->IgnoreParens();
    if (source && source->GetKind() == NodeKind::CallExpr) {
      const auto& call = static_cast<const CallExpr&>(*source);
      if (call.Callee && call.Callee->GetKind() == NodeKind::DeclRefExpr) {
        const auto& callee = static_cast<const DeclRefExpr&>(*call.Callee);
        const auto& constructor = static_cast<const ConstructorDecl&>(*current_function_);
        has_direct_delegating_source = callee.name == constructor.name;
      }
    }
    if (!has_direct_delegating_source) {
      Diagnose(*expression.Source, kErrorDiagnostic, expression.Source->range,
               fmt::format("constructor delegation must directly construct the current type '{}'",
                           static_cast<const ConstructorDecl&>(*current_function_).name));
    }
  }

  // Still analyze the source after target errors, but supply context only for a valid destination.
  if (!expression.Source) {
    expression.contains_errors = true;
  } else {
    const ConstructionResultContext* source_context =
        target_is_valid && has_direct_delegating_source ? &construction_context : nullptr;
    expression.Source =
        AnalyzeExpr(std::move(expression.Source), ComptimeIntMode::Materialize, ExpressionUse::General, source_context);
    InheritErrors(expression, expression.Source.get());
  }

  if (!target_is_valid || !expression.Source || expression.Source->ContainsErrors()) {
    return;
  }
  if (!expression.Source->type) {
    expression.contains_errors = true;
    return;
  }

  // Reference expressions expose the referent type; binding still needs the declared reference mode.
  const bool initializes_reference = target_declaration && path.empty() && target_declaration->type &&
                                     target_declaration->type.GetTypePtr()->AsReferenceType();
  const QualType target_type = initializes_reference ? target_declaration->type : expression.Target->type;
  ConvertExpression(expression.Source, target_type, expression,
                    fmt::format("cannot initialize {}: ", DescribeInitializationTarget(*expression.Target)),
                    construction_context.construction_kind);
}

void Sema::AnalyzeConditionalOperator(ConditionalOperator& expression,
                                      const ConstructionResultContext* construction_context) {
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;

  const QualType bool_type(ast_context_->GetBuiltinType(BuiltinTypeKind::Bool));
  bool condition_is_valid = false;
  if (expression.Cond && !expression.Cond->ContainsErrors() && expression.Cond->type) {
    condition_is_valid = expression.Cond->type.WithoutConst() == bool_type;
    if (!condition_is_valid) {
      Diagnose(expression, kErrorDiagnostic, expression.Cond->range,
               fmt::format("condition expression must have type 'bool', not {}",
                           DescribeExpressionType(expression.Cond->type)));
    } else {
      ApplyDefaultValueConversion(expression.Cond);
    }
  }

  // Matching glvalue categories of the same unqualified object type preserve identity; other branches need a value
  // type.
  QualType common_type;
  ValueCategory result_category = ValueCategory::None;
  ConversionSequence then_conversion;
  ConversionSequence else_conversion;
  bool branches_are_valid = false;

  if (expression.Then && expression.Else && !expression.Then->ContainsErrors() && !expression.Else->ContainsErrors() &&
      expression.Then->type && expression.Else->type) {
    const QualType then_type = expression.Then->type;
    const QualType else_type = expression.Else->type;
    const bool both_void = then_type.GetTypePtr()->IsVoid() && else_type.GetTypePtr()->IsVoid();
    const bool both_objects = then_type.GetTypePtr()->IsObject() && else_type.GetTypePtr()->IsObject() &&
                              expression.Then->value_category != ValueCategory::None &&
                              expression.Else->value_category != ValueCategory::None;
    const bool same_object_type = then_type.WithoutConst() == else_type.WithoutConst();
    const QualType common_pointer = CommonPointerValueType(*ast_context_, then_type, else_type);

    if (both_void) {
      common_type = then_type.WithoutConst();
      result_category = ValueCategory::None;
      branches_are_valid = true;
    } else if (same_object_type && expression.Then->value_category == ValueCategory::LValue &&
               expression.Else->value_category == ValueCategory::LValue) {
      common_type = then_type.WithoutConst();
      if (then_type.IsConstQualified() || else_type.IsConstQualified()) {
        common_type = common_type.WithConst();
      }
      result_category = ValueCategory::LValue;
      branches_are_valid = true;
    } else if (same_object_type && expression.Then->value_category == ValueCategory::MoveLValue &&
               expression.Else->value_category == ValueCategory::MoveLValue) {
      common_type = then_type.WithoutConst();
      if (then_type.IsConstQualified() || else_type.IsConstQualified()) {
        common_type = common_type.WithConst();
      }
      result_category = ValueCategory::MoveLValue;
      branches_are_valid = true;
    } else if (both_objects || common_pointer) {
      if (same_object_type && !(then_type && then_type.GetTypePtr()->IsVoid())) {
        common_type = then_type.WithoutConst();
      } else if (const BuiltinType* common_numeric = CommonNumericType(*ast_context_, then_type, else_type)) {
        common_type = QualType(common_numeric);
      } else {
        common_type = common_pointer;
      }
      if (common_type) {
        const auto build_branch = [&](const Expr& branch, ConversionSequence& conversion, const char* name) {
          const auto source = MakeConversionSource(branch);
          auto result = BuildConversion(source, common_type, *ast_context_, symbol_table_);
          if (const auto* failure = std::get_if<ConversionFailure>(&result)) {
            Diagnose(expression, kErrorDiagnostic, branch.range,
                     fmt::format("cannot form conditional result from {} branch: {}", name,
                                 FormatConversionFailure(*failure)));
            return false;
          }
          conversion = std::get<ConversionSequence>(std::move(result));
          if (const auto failure = CompleteConversion(source, common_type, conversion, symbol_table_)) {
            Diagnose(expression, kErrorDiagnostic, branch.range,
                     fmt::format("cannot form conditional result from {} branch: {}", name,
                                 FormatObjectFormationFailure(failure->failure)));
            return false;
          }
          return true;
        };
        branches_are_valid = build_branch(*expression.Then, then_conversion, "then") &&
                             build_branch(*expression.Else, else_conversion, "else");
        result_category = ValueCategory::PureRValue;
      }
    }
    if (!branches_are_valid) {
      if (!common_type) {
        const SourceRange branches_range{expression.Then->range.begin, expression.Else->range.end};
        if (then_type.WithoutConst() == else_type.WithoutConst()) {
          Diagnose(expression, kErrorDiagnostic, branches_range,
                   fmt::format("{} cannot be used as a conditional value result",
                               DescribeExpressionType(then_type, "type ")));
        } else {
          Diagnose(expression, kErrorDiagnostic, branches_range,
                   fmt::format("conditional expression has no common result type for {}",
                               DescribeOperandTypes(then_type, else_type)));
        }
      }
    }
  }

  // Commit both branch plans only after the condition and common result are valid.
  if (!condition_is_valid || !branches_are_valid) {
    return;
  }

  expression.type = common_type;
  expression.value_category = result_category;
  if (result_category != ValueCategory::PureRValue) {
    return;
  }

  const ConstructionKind construction_kind =
      construction_context && common_type.WithoutConst() == construction_context->target_type
          ? construction_context->construction_kind
          : ConstructionKind::CompleteObject;
  DiagnoseConversionRisks(expression, *expression.Then, common_type, then_conversion);
  DiagnoseConversionRisks(expression, *expression.Else, common_type, else_conversion);
  expression.Then = CommitConversion(std::move(expression.Then), common_type, then_conversion, construction_kind);
  expression.Else = CommitConversion(std::move(expression.Else), common_type, else_conversion, construction_kind);
}

void Sema::AnalyzeThisExpr(ThisExpr& expression) {
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;
  if (!current_function_ || (current_function_->GetKind() != NodeKind::ConstructorDecl &&
                             current_function_->GetKind() != NodeKind::DestructorDecl)) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             "'this' is only allowed in a constructor or destructor body");
    return;
  }

  const StructType* target_type = current_function_->GetKind() == NodeKind::ConstructorDecl
                                      ? static_cast<const ConstructorDecl*>(current_function_)->target_type
                                      : static_cast<const DestructorDecl*>(current_function_)->target_type;
  if (!target_type) {
    expression.contains_errors = true;
    return;
  }
  expression.type = QualType(target_type);
  expression.value_category = ValueCategory::LValue;
}

std::unique_ptr<Expr> Sema::AnalyzeDeclRefExpr(std::unique_ptr<Expr> expression, DeclRefRole role) {
  BOOST_ASSERT(expression && expression->GetKind() == NodeKind::DeclRefExpr);
  auto& declaration_reference = static_cast<DeclRefExpr&>(*expression);
  if (declaration_reference.name == "this" && current_function_ &&
      (current_function_->GetKind() == NodeKind::ConstructorDecl ||
       current_function_->GetKind() == NodeKind::DestructorDecl)) {
    auto this_expression = std::make_unique<ThisExpr>();
    this_expression->range = declaration_reference.range;
    AnalyzeThisExpr(*this_expression);
    return this_expression;
  }

  BOOST_ASSERT(!declaration_reference.declaration);
  if (declaration_reference.name.empty()) {
    return expression;
  }

  const bool is_operator = IsOperatorFunctionName(declaration_reference.name);
  const Symbol* symbol = symbol_table_.Lookup(declaration_reference.name);
  if (!symbol) {
    if (role == DeclRefRole::Callee && is_operator &&
        HasInvalidTopLevelOperatorFunctionDeclaration(*ast_context_->GetTranslationUnitDecl(),
                                                      declaration_reference.name)) {
      declaration_reference.contains_errors = true;
      return expression;
    }
    Diagnose(declaration_reference, kErrorDiagnostic, declaration_reference.range,
             is_operator ? fmt::format("use of undeclared operator '{}'", declaration_reference.name)
                         : fmt::format("use of undeclared identifier '{}'", declaration_reference.name));
    return expression;
  }

  if (!is_operator) {
    if (const VariableSymbol* variable_symbol = AsVariableSymbol(symbol)) {
      declaration_reference.declaration = variable_symbol->GetDeclaration();
      if (declaration_reference.declaration->ContainsErrors()) {
        declaration_reference.contains_errors = true;
        return expression;
      }
      const QualType declaration_type = declaration_reference.declaration->type;
      const ReferenceType* reference_type =
          declaration_type ? declaration_type.GetTypePtr()->AsReferenceType() : nullptr;
      if (reference_type) {
        declaration_reference.type = QualType(reference_type->GetReferentType());
        if (reference_type->GetMode() == ReferenceMode::Copy) {
          declaration_reference.type = declaration_reference.type.WithConst();
        }
      } else {
        declaration_reference.type = declaration_type;
      }
      if (declaration_reference.type && declaration_reference.type.GetTypePtr()->IsObject()) {
        declaration_reference.value_category = ValueCategory::LValue;
      }
      return expression;
    }
  }

  if (const FunctionSymbol* function_symbol = AsFunctionSymbol(symbol)) {
    declaration_reference.type = QualType(ast_context_->GetFunctionOverloadSetType());
    declaration_reference.value_category = ValueCategory::None;
    const bool has_valid_interface =
        std::any_of(function_symbol->Declarations().begin(), function_symbol->Declarations().end(),
                    [](const FunctionDecl* declaration) {
                      return declaration && !declaration->is_invalid && HasValidFunctionInterface(*declaration);
                    });
    if (!has_valid_interface) {
      declaration_reference.contains_errors = true;
    }
    return expression;
  }

  if (role == DeclRefRole::Object) {
    if (AsTypeSymbol(symbol)) {
      Diagnose(declaration_reference, kErrorDiagnostic, declaration_reference.range,
               fmt::format("type '{}' cannot be used as an object expression", declaration_reference.name));
    } else {
      Diagnose(declaration_reference, kErrorDiagnostic, declaration_reference.range,
               fmt::format("'{}' cannot be used as an object expression", declaration_reference.name));
    }
  }
  return expression;
}

std::unique_ptr<Expr> Sema::AnalyzeMemberExpr(std::unique_ptr<Expr> expression_node) {
  BOOST_ASSERT(expression_node && expression_node->GetKind() == NodeKind::MemberExpr);
  auto& expression = static_cast<MemberExpr&>(*expression_node);
  BOOST_ASSERT(expression.op == expr::period || expression.op == expr::arrow);
  expression.declaration = nullptr;
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;
  if (!expression.Base || expression.Base->ContainsErrors() || !expression.Base->type) {
    return expression_node;
  }

  const StructDecl* structure = nullptr;
  bool result_is_const = false;
  ValueCategory result_category = ValueCategory::None;
  if (expression.op == expr::period) {
    const QualType base_type = expression.Base->type;
    if (base_type.GetTypePtr()->GetKind() != TypeKind::Struct ||
        expression.Base->value_category == ValueCategory::None) {
      Diagnose(
          expression, kErrorDiagnostic, expression.range,
          fmt::format("member access with '.' requires a struct object, not {}", DescribeExpressionType(base_type)));
      return expression_node;
    }
    structure = static_cast<const StructType*>(base_type.GetTypePtr())->GetDeclaration();
    result_is_const = base_type.IsConstQualified();
    result_category =
        expression.Base->value_category == ValueCategory::LValue ? ValueCategory::LValue : ValueCategory::MoveLValue;
  } else {
    const QualType pointer_type = expression.Base->type;
    if (pointer_type.GetTypePtr()->GetKind() != TypeKind::Pointer) {
      Diagnose(expression, kErrorDiagnostic, expression.range,
               fmt::format("member access with '->' requires a pointer to a struct, not {}",
                           DescribeExpressionType(pointer_type)));
      return expression_node;
    }
    const QualType pointee_type = static_cast<const PointerType*>(pointer_type.GetTypePtr())->GetPointee();
    if (!pointee_type || pointee_type.GetTypePtr()->GetKind() != TypeKind::Struct) {
      Diagnose(
          expression, kErrorDiagnostic, expression.range,
          fmt::format("member access with '->' requires a pointer to a struct, not '{}'", TypeSpelling(pointer_type)));
      return expression_node;
    }
    ApplyDefaultValueConversion(expression.Base);
    structure = static_cast<const StructType*>(pointee_type.GetTypePtr())->GetDeclaration();
    result_is_const = pointee_type.IsConstQualified();
    result_category = ValueCategory::LValue;
  }

  BOOST_ASSERT(structure);
  std::unordered_set<const StructDecl*> visited;
  const StructDecl* current = structure;
  const FieldDecl* selected_field = nullptr;
  const StructType* selected_base_type = nullptr;
  std::vector<const StructDecl*> base_path;
  while (current) {
    if (!visited.insert(current).second) {
      expression.contains_errors = true;
      return expression_node;
    }

    const StructType* direct_base_type = current->base_type;
    const StructDecl* direct_base = direct_base_type ? direct_base_type->GetDeclaration() : nullptr;
    // Preserve an already resolved base relation when unrelated declaration errors made the structure invalid.
    if (direct_base && direct_base->name == expression.member) {
      base_path.push_back(direct_base);
      selected_base_type = direct_base_type;
      break;
    }
    if (current->triviality == TypeTriviality::Unknown || current->triviality == TypeTriviality::Invalid) {
      expression.contains_errors = true;
      return expression_node;
    }

    for (const auto& field : current->Fields) {
      if (field && field->name == expression.member) {
        selected_field = field.get();
        break;
      }
    }
    if (selected_field) {
      break;
    }

    if (!direct_base) {
      break;
    }
    base_path.push_back(direct_base);
    current = direct_base;
  }

  if (selected_base_type) {
    if (expression.op == expr::period && expression.Base->value_category == ValueCategory::PureRValue) {
      MaterializeObject(expression.Base);
    }

    auto base_subobject = std::make_unique<BaseSubobjectExpr>();
    base_subobject->range = expression.range;
    base_subobject->Base = std::move(expression.Base);
    base_subobject->operator_range = expression.operator_range;
    base_subobject->op = expression.op;
    base_subobject->base_path = std::move(base_path);
    base_subobject->type = QualType(selected_base_type);
    if (result_is_const) {
      base_subobject->type = base_subobject->type.WithConst();
    }
    base_subobject->value_category = result_category;
    return base_subobject;
  }

  if (!selected_field) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("no field or base named '{}' in struct '{}'", expression.member, structure->name));
    return expression_node;
  }
  if (selected_field->ContainsErrors() || !selected_field->type || !selected_field->type.GetTypePtr()->IsObject()) {
    expression.contains_errors = true;
    return expression_node;
  }

  if (expression.op == expr::period && expression.Base->value_category == ValueCategory::PureRValue) {
    MaterializeObject(expression.Base);
  }

  expression.declaration = selected_field;
  expression.type = selected_field->type;
  if (result_is_const) {
    expression.type = expression.type.WithConst();
  }
  expression.value_category = result_category;
  return expression_node;
}

std::unique_ptr<Expr> Sema::AnalyzeCallableObjectCall(std::unique_ptr<Expr> expression_node) {
  BOOST_ASSERT(expression_node && expression_node->GetKind() == NodeKind::CallExpr);
  auto& expression = static_cast<CallExpr&>(*expression_node);
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;

  if (!expression.Callee || expression.Callee->ContainsErrors() || !IsStructObjectOperand(*expression.Callee) ||
      expression.ContainsErrors()) {
    return expression_node;
  }

  std::vector<const Expr*> arguments;
  arguments.reserve(expression.Args.size() + 1);
  arguments.push_back(expression.Callee.get());
  for (const auto& argument : expression.Args) {
    if (!argument || argument->ContainsErrors() || !argument->type) {
      expression.contains_errors = true;
      return expression_node;
    }
    arguments.push_back(argument.get());
  }

  std::vector<ConversionSource> semantic_arguments;
  semantic_arguments.reserve(arguments.size());
  semantic_arguments.push_back(MakeConversionSource(*expression.Callee));
  for (std::size_t index = 1; index < arguments.size(); ++index) {
    semantic_arguments.push_back(MakeConversionSource(*arguments[index]));
  }

  constexpr const char* kCallOperatorName = "()";
  const bool has_invalid_declaration =
      HasInvalidTopLevelOperatorFunctionDeclaration(*ast_context_->GetTranslationUnitDecl(), kCallOperatorName);
  const FunctionSymbol* functions = AsFunctionSymbol(symbol_table_.LookupRoot(kCallOperatorName));
  if (!functions) {
    if (has_invalid_declaration) {
      expression.contains_errors = true;
    } else {
      Diagnose(
          expression, kErrorDiagnostic, expression.range,
          fmt::format("{} is not callable", DescribeExpressionType(expression.Callee->type, "expression of type ")));
    }
    return expression_node;
  }

  const std::vector<const FunctionDecl*> complete_candidates =
      CollectFunctionCallCandidates(*functions, kCallOperatorName, CallCandidateMode::Regular);
  if (complete_candidates.empty()) {
    if (has_invalid_declaration) {
      expression.contains_errors = true;
    } else {
      Diagnose(
          expression, kErrorDiagnostic, expression.range,
          fmt::format("{} is not callable", DescribeExpressionType(expression.Callee->type, "expression of type ")));
    }
    return expression_node;
  }

  OverloadResult resolution = ResolveOverload(semantic_arguments, complete_candidates, *ast_context_, symbol_table_);
  if (const auto* no_viable = std::get_if<NoViableOverload>(&resolution)) {
    Diagnose(
        expression, kErrorDiagnostic, expression.range,
        fmt::format("no matching function for call to object of type '{}'", TypeSpelling(expression.Callee->type)));
    for (const auto& candidate : no_viable->candidates) {
      BOOST_ASSERT(candidate.target);
      const SourceRange candidate_range{candidate.target->range.begin, candidate.target->range.begin};
      if (const auto* arity = std::get_if<CandidateArityFailure>(&candidate.failure)) {
        BOOST_ASSERT(arity->required > 0 && arity->provided > 0);
        const std::size_t required = arity->required - 1;
        const std::size_t provided = arity->provided - 1;
        EmitDiagnostic(kNoteDiagnostic, candidate_range,
                       fmt::format("candidate function requires {} explicit {}, but {} {} provided", required,
                                   required == 1 ? "argument" : "arguments", provided, provided == 1 ? "was" : "were"));
        continue;
      }

      const auto* argument = std::get_if<CandidateArgumentFailure>(&candidate.failure);
      if (!argument) {
        continue;
      }
      if (argument->index == 0) {
        EmitDiagnostic(kNoteDiagnostic, candidate_range,
                       fmt::format("candidate function is not viable: {} for receiver",
                                   FormatConversionFailure(argument->failure)));
      } else {
        EmitDiagnostic(kNoteDiagnostic, candidate_range,
                       fmt::format("candidate function is not viable: {} for argument {}",
                                   FormatConversionFailure(argument->failure), argument->index));
      }
    }
    return expression_node;
  }

  if (const auto* ambiguous = std::get_if<AmbiguousOverload>(&resolution)) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("call to object of type '{}' is ambiguous", TypeSpelling(expression.Callee->type)));
    for (const FunctionDecl* declaration : ambiguous->candidates) {
      EmitDiagnostic(kNoteDiagnostic, {declaration->range.begin, declaration->range.begin}, "candidate function");
    }
    return expression_node;
  }

  const auto& selected = std::get<SelectedOverload>(resolution);
  const FunctionDecl* declaration = selected.target;
  BOOST_ASSERT(declaration);
  const auto& function_type = static_cast<const FunctionType&>(*declaration->type.GetTypePtr());
  const auto& parameter_types = function_type.GetParameterTypes();
  auto formation = CompleteArguments(semantic_arguments, *declaration, selected.conversions, symbol_table_);
  if (const auto* failure = std::get_if<ArgumentCompletionFailure>(&formation)) {
    BOOST_ASSERT(failure->index < arguments.size());
    Diagnose(expression, kErrorDiagnostic, arguments[failure->index]->range,
             fmt::format("cannot initialize parameter {} of operator '()': {}", failure->index + 1,
                         FormatObjectFormationFailure(failure->failure)));
    return expression_node;
  }

  const auto& plans = std::get<std::vector<ConversionSequence>>(formation);
  BOOST_ASSERT(plans.size() == arguments.size());

  auto call = std::make_unique<OperatorCallExpr>();
  call->range = expression.range;
  call->Args.reserve(arguments.size());
  call->Args.push_back(std::move(expression.Callee));
  for (auto& argument : expression.Args) call->Args.push_back(std::move(argument));

  auto callee = std::make_unique<DeclRefExpr>();
  callee->range = {call->Args.front()->range.end, call->Args.front()->range.end};
  callee->name = kCallOperatorName;
  callee->declaration = declaration;
  callee->type = declaration->type;
  call->Callee = std::move(callee);

  CommitArgumentConversions(ExpressionSlots(call->Args), parameter_types, plans);
  FormCallResult(*call, function_type);
  return call;
}

void Sema::AnalyzeCallExpr(CallExpr& expression, const ConstructionResultContext* construction_context) {
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;
  if (!expression.Callee || expression.Callee->ContainsErrors()) {
    return;
  }

  // Non-overload-set callees must provide a callable signature for indirect calls.
  if (expression.Callee->type && expression.Callee->type.GetTypePtr()->GetKind() != TypeKind::FunctionOverloadSet) {
    if (expression.is_nonvirtual) {
      Diagnose(expression, kErrorDiagnostic, expression.nonvirtual_range,
               "'nonvirtual' cannot be used with an indirect function call");
      return;
    }
    const FunctionType* function_type = IndirectFunctionType(expression.Callee->type);
    if (!function_type) {
      Diagnose(
          expression, kErrorDiagnostic, expression.range,
          fmt::format("{} is not callable", DescribeExpressionType(expression.Callee->type, "expression of type ")));
      return;
    }
    AnalyzeIndirectCallExpr(expression, *function_type);
    return;
  }

  for (const auto& argument : expression.Args) {
    if (!argument || argument->ContainsErrors()) {
      return;
    }
    if (!argument->type) {
      expression.contains_errors = true;
      return;
    }
  }

  if (expression.Callee->GetKind() != NodeKind::DeclRefExpr) {
    if (expression.Callee->type && expression.Callee->type.GetTypePtr()->GetKind() == TypeKind::FunctionOverloadSet) {
      const Expr* unwrapped = expression.Callee->IgnoreParens();
      if (unwrapped && unwrapped->GetKind() == NodeKind::DeclRefExpr) {
        const auto& function_name = static_cast<const DeclRefExpr&>(*unwrapped);
        if (!function_name.name.empty()) {
          Diagnose(*expression.Callee, kErrorDiagnostic, function_name.range,
                   fmt::format("function '{}' cannot be used as an object expression", function_name.name));
          expression.contains_errors = true;
        }
      }
    }
    return;
  }

  auto& callee = static_cast<DeclRefExpr&>(*expression.Callee);
  if (callee.name.empty()) {
    return;
  }
  if (callee.declaration) {
    return;
  }
  const bool is_operator = IsOperatorFunctionName(callee.name);

  const Symbol* symbol = symbol_table_.Lookup(callee.name);
  if (!symbol) {
    return;
  }

  if (const FunctionSymbol* functions = AsFunctionSymbol(symbol)) {
    const CallCandidateMode mode =
        expression.is_nonvirtual ? CallCandidateMode::NonVirtual : CallCandidateMode::Regular;
    const std::vector<const FunctionDecl*> complete_candidates =
        CollectFunctionCallCandidates(*functions, callee.name, mode);
    if (complete_candidates.empty()) {
      callee.contains_errors = true;
      expression.contains_errors = true;
      if (is_operator && !HasInvalidFunctionDeclaration(*functions, callee.name)) {
        Diagnose(expression, kErrorDiagnostic, expression.range,
                 fmt::format("no matching function for call to operator '{}'", callee.name));
      } else if (expression.is_nonvirtual && !HasInvalidFunctionDeclaration(*functions, callee.name)) {
        Diagnose(expression, kErrorDiagnostic, expression.range,
                 fmt::format("no matching function for nonvirtual call to '{}'", callee.name));
      }
      return;
    }

    // Rank conversion matches before forming parameter objects or rewriting any arguments.
    const auto arguments = ExpressionPointers(expression.Args);
    const auto semantic_arguments = MakeConversionSources(arguments);
    OverloadResult resolution = ResolveOverload(semantic_arguments, complete_candidates, *ast_context_, symbol_table_);
    if (const auto* no_viable = std::get_if<NoViableOverload>(&resolution)) {
      Diagnose(expression, kErrorDiagnostic, expression.range,
               is_operator                ? fmt::format("no matching function for call to operator '{}'", callee.name)
               : expression.is_nonvirtual ? fmt::format("no matching function for nonvirtual call to '{}'", callee.name)
                                          : fmt::format("no matching function for call to '{}'", callee.name));
      callee.contains_errors = true;
      for (const auto& candidate : no_viable->candidates) {
        BOOST_ASSERT(candidate.target);
        const SourceRange candidate_range{candidate.target->range.begin, candidate.target->range.begin};
        if (const auto* arity = std::get_if<CandidateArityFailure>(&candidate.failure)) {
          EmitDiagnostic(kNoteDiagnostic, candidate_range,
                         fmt::format("candidate function requires {} {}, but {} {} provided", arity->required,
                                     arity->required == 1 ? "argument" : "arguments", arity->provided,
                                     arity->provided == 1 ? "was" : "were"));
        } else if (const auto* argument = std::get_if<CandidateArgumentFailure>(&candidate.failure)) {
          EmitDiagnostic(kNoteDiagnostic, candidate_range,
                         fmt::format("candidate function is not viable: {} for argument {}",
                                     FormatConversionFailure(argument->failure), argument->index + 1));
        }
      }
      return;
    }
    if (const auto* ambiguous = std::get_if<AmbiguousOverload>(&resolution)) {
      Diagnose(expression, kErrorDiagnostic, expression.range,
               is_operator ? fmt::format("call to operator '{}' is ambiguous", callee.name)
                           : fmt::format("call to '{}' is ambiguous", callee.name));
      callee.contains_errors = true;
      for (const FunctionDecl* declaration : ambiguous->candidates) {
        EmitDiagnostic(kNoteDiagnostic, {declaration->range.begin, declaration->range.begin}, "candidate function");
      }
      return;
    }

    // Complete only the winning candidate. A formation failure does not reopen overload resolution;
    // retain the selected declaration for recovery while leaving argument conversions uncommitted.
    const auto& selected = std::get<SelectedOverload>(resolution);
    const FunctionDecl* declaration = selected.target;
    BOOST_ASSERT(declaration);
    const auto& function_type = static_cast<const FunctionType&>(*declaration->type.GetTypePtr());
    const auto& parameter_types = function_type.GetParameterTypes();
    auto formation = CompleteArguments(semantic_arguments, *declaration, selected.conversions, symbol_table_);
    callee.declaration = declaration;
    callee.type = declaration->type;
    if (const auto* failure = std::get_if<ArgumentCompletionFailure>(&formation)) {
      const std::string callee_spelling =
          is_operator ? fmt::format("operator '{}'", callee.name) : fmt::format("function '{}'", callee.name);
      Diagnose(expression, kErrorDiagnostic, expression.Args[failure->index]->range,
               fmt::format("cannot initialize parameter {} of {}: {}", failure->index + 1, callee_spelling,
                           FormatObjectFormationFailure(failure->failure)));
      return;
    }
    // Once every parameter can be formed, commit the argument plans and expose the call result.
    const auto& plans = std::get<std::vector<ConversionSequence>>(formation);
    CommitArgumentConversions(ExpressionSlots(expression.Args), parameter_types, plans);
    FormDirectCallResult(expression, callee, *declaration);
    return;
  }

  if (is_operator) {
    return;
  }

  // Calling a type name performs construction, including trivial default formation.
  const TypeSymbol* type_symbol = AsTypeSymbol(symbol);
  if (!type_symbol) {
    return;
  }
  if (expression.is_nonvirtual) {
    Diagnose(expression, kErrorDiagnostic, expression.nonvirtual_range,
             "'nonvirtual' cannot be used with a constructor call");
    return;
  }

  const StructType* target_type = ast_context_->GetStructType(type_symbol->GetDeclaration());
  if (target_type->GetDeclaration()->triviality == TypeTriviality::Invalid) {
    expression.contains_errors = true;
    return;
  }
  if (target_type->GetDeclaration()->triviality == TypeTriviality::Trivial && expression.Args.empty()) {
    expression.type = QualType(target_type);
    expression.value_category = ValueCategory::PureRValue;
    return;
  }
  // An abstract type is constructible here only as the matching base or delegating destination.
  const bool constructs_abstract_subobject =
      construction_context && construction_context->target_type == QualType(target_type) &&
      construction_context->construction_kind != ConstructionKind::CompleteObject;
  if (target_type->GetDeclaration()->is_abstract && !constructs_abstract_subobject) {
    callee.contains_errors = true;
    expression.contains_errors = true;
    Diagnose(expression, kErrorDiagnostic, callee.range,
             fmt::format("cannot construct an object of abstract type '{}'", callee.name));
    return;
  }
  const FunctionSymbol* constructors = type_symbol->GetConstructorSymbol();
  if (!constructors) {
    callee.contains_errors = true;
    expression.contains_errors = true;
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("no constructor declared for type '{}'", callee.name));
    return;
  }

  const std::vector<const FunctionDecl*> complete_candidates =
      CollectCompleteFunctionCandidates(*constructors, callee.name, NodeKind::ConstructorDecl);
  if (complete_candidates.empty()) {
    callee.contains_errors = true;
    expression.contains_errors = true;
    return;
  }

  // Constructor candidates use the same match, rank, and deferred-formation sequence as functions.
  const auto arguments = ExpressionPointers(expression.Args);
  const auto semantic_arguments = MakeConversionSources(arguments);
  OverloadResult resolution = ResolveOverload(semantic_arguments, complete_candidates, *ast_context_, symbol_table_);
  if (const auto* no_viable = std::get_if<NoViableOverload>(&resolution)) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("no matching constructor for type '{}'", callee.name));
    callee.contains_errors = true;
    for (const auto& candidate : no_viable->candidates) {
      BOOST_ASSERT(candidate.target);
      const SourceRange candidate_range{candidate.target->range.begin, candidate.target->range.begin};
      if (const auto* arity = std::get_if<CandidateArityFailure>(&candidate.failure)) {
        EmitDiagnostic(kNoteDiagnostic, candidate_range,
                       fmt::format("candidate constructor requires {} {}, but {} {} provided", arity->required,
                                   arity->required == 1 ? "argument" : "arguments", arity->provided,
                                   arity->provided == 1 ? "was" : "were"));
      } else if (const auto* argument = std::get_if<CandidateArgumentFailure>(&candidate.failure)) {
        EmitDiagnostic(kNoteDiagnostic, candidate_range,
                       fmt::format("candidate constructor is not viable: {} for argument {}",
                                   FormatConversionFailure(argument->failure), argument->index + 1));
      }
    }
    return;
  }
  if (const auto* ambiguous = std::get_if<AmbiguousOverload>(&resolution)) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("construction of '{}' is ambiguous", callee.name));
    callee.contains_errors = true;
    for (const FunctionDecl* declaration : ambiguous->candidates) {
      EmitDiagnostic(kNoteDiagnostic, {declaration->range.begin, declaration->range.begin}, "candidate constructor");
    }
    return;
  }

  // Bind the selected constructor before reporting formation errors, but commit no partial argument plan.
  const auto& selected = std::get<SelectedOverload>(resolution);
  BOOST_ASSERT(selected.target && selected.target->GetKind() == NodeKind::ConstructorDecl);
  const auto& declaration = static_cast<const ConstructorDecl&>(*selected.target);
  const auto& function_type = static_cast<const FunctionType&>(*declaration.type.GetTypePtr());
  const auto& parameter_types = function_type.GetParameterTypes();
  auto formation = CompleteArguments(semantic_arguments, declaration, selected.conversions, symbol_table_);
  callee.declaration = &declaration;
  callee.type = declaration.type;
  if (const auto* failure = std::get_if<ArgumentCompletionFailure>(&formation)) {
    Diagnose(expression, kErrorDiagnostic, expression.Args[failure->index]->range,
             fmt::format("cannot initialize parameter {} of constructor '{}': {}", failure->index + 1, callee.name,
                         FormatObjectFormationFailure(failure->failure)));
    return;
  }
  const auto& plans = std::get<std::vector<ConversionSequence>>(formation);
  CommitArgumentConversions(ExpressionSlots(expression.Args), parameter_types, plans);
  BOOST_ASSERT(declaration.target_type == target_type);
  expression.type = QualType(declaration.target_type);
  expression.value_category = ValueCategory::PureRValue;
}

void Sema::AnalyzeIndirectCallExpr(CallExpr& expression, const FunctionType& function_type) {
  const auto& parameter_types = function_type.GetParameterTypes();
  if (parameter_types.size() != expression.Args.size()) {
    const std::size_t required = parameter_types.size();
    const std::size_t provided = expression.Args.size();
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("indirect function call requires {} {}, but {} {} provided", required,
                         required == 1 ? "argument" : "arguments", provided, provided == 1 ? "was" : "were"));
    return;
  }

  const auto arguments = ExpressionPointers(expression.Args);
  for (const Expr* argument : arguments) {
    if (!argument || argument->ContainsErrors() || !argument->type) {
      expression.contains_errors = true;
      return;
    }
  }
  const auto semantic_arguments = MakeConversionSources(arguments);
  MatchArgumentsResult evaluation = MatchArguments(semantic_arguments, parameter_types, *ast_context_, symbol_table_);
  if (const auto* failure = std::get_if<CandidateFailure>(&evaluation)) {
    const auto* argument = std::get_if<CandidateArgumentFailure>(failure);
    BOOST_ASSERT(argument);
    if (!argument) {
      expression.contains_errors = true;
      return;
    }
    Diagnose(*expression.Args[argument->index], kErrorDiagnostic, expression.Args[argument->index]->range,
             fmt::format("cannot initialize parameter {} of indirect function call: {}", argument->index + 1,
                         FormatConversionFailure(argument->failure)));
    return;
  }

  // The signature is fixed, but all parameter formations must still succeed before AST conversion.
  const auto& match_plans = std::get<std::vector<ConversionSequence>>(evaluation);
  auto formation = CompleteArguments(semantic_arguments, parameter_types, match_plans, symbol_table_);
  if (const auto* failure = std::get_if<ArgumentCompletionFailure>(&formation)) {
    Diagnose(expression, kErrorDiagnostic, expression.Args[failure->index]->range,
             fmt::format("cannot initialize parameter {} of indirect function call: {}", failure->index + 1,
                         FormatObjectFormationFailure(failure->failure)));
    return;
  }

  const auto& plans = std::get<std::vector<ConversionSequence>>(formation);
  BOOST_ASSERT(plans.size() == expression.Args.size());
  ApplyDefaultValueConversion(expression.Callee);
  CommitArgumentConversions(ExpressionSlots(expression.Args), parameter_types, plans);
  FormCallResult(expression, function_type);
}

void Sema::AnalyzeConstructionExpr(ConstructionExpr& expression) {
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;
  expression.constructor = nullptr;

  if (expression.target_name.empty()) {
    expression.contains_errors = true;
    return;
  }

  const Symbol* symbol = symbol_table_.Lookup(expression.target_name);
  if (!symbol) {
    Diagnose(expression, kErrorDiagnostic, expression.target_name_range,
             fmt::format("unknown constructor target type '{}'", expression.target_name));
    return;
  }
  const TypeSymbol* type_symbol = AsTypeSymbol(symbol);
  if (!type_symbol) {
    Diagnose(expression, kErrorDiagnostic, expression.target_name_range,
             fmt::format("'{}' does not name a struct type", expression.target_name));
    return;
  }
  const StructType* target_type = ast_context_->GetStructType(type_symbol->GetDeclaration());

  // Explicit-address construction requires writable storage of the exact target type.
  bool target_is_valid = false;
  if (target_type->GetDeclaration()->is_abstract) {
    Diagnose(expression, kErrorDiagnostic, expression.target_name_range,
             fmt::format("cannot construct an object of abstract type '{}'", expression.target_name));
    return;
  }
  if (!expression.TargetAddress) {
    expression.contains_errors = true;
  } else if (!expression.TargetAddress->ContainsErrors()) {
    if (!expression.TargetAddress->type) {
      expression.contains_errors = true;
    } else {
      if (expression.TargetAddress->type.GetTypePtr()->GetKind() == TypeKind::Pointer) {
        const QualType pointee =
            static_cast<const PointerType*>(expression.TargetAddress->type.GetTypePtr())->GetPointee();
        target_is_valid = pointee.GetTypePtr() == target_type && !pointee.IsConstQualified();
      }
      if (!target_is_valid) {
        const QualType expected(ast_context_->GetPointerType(QualType(target_type)));
        Diagnose(expression, kErrorDiagnostic, expression.TargetAddress->range,
                 fmt::format("constructor target address must have type '{}', not {}", TypeSpelling(expected),
                             DescribeExpressionType(expression.TargetAddress->type)));
      }
    }
  }

  bool arguments_are_valid = true;
  for (const auto& argument : expression.Args) {
    if (!argument || argument->ContainsErrors()) {
      arguments_are_valid = false;
    } else if (!argument->type) {
      arguments_are_valid = false;
      expression.contains_errors = true;
    }
  }
  if (!target_is_valid || !arguments_are_valid || expression.ContainsErrors()) {
    return;
  }

  const FunctionSymbol* constructors = type_symbol->GetConstructorSymbol();
  if (!constructors) {
    expression.contains_errors = true;
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("no constructor declared for type '{}'", expression.target_name));
    return;
  }

  const std::vector<const FunctionDecl*> complete_candidates =
      CollectCompleteFunctionCandidates(*constructors, expression.target_name, NodeKind::ConstructorDecl);
  if (complete_candidates.empty()) {
    expression.contains_errors = true;
    return;
  }

  const auto arguments = ExpressionPointers(expression.Args);
  const auto semantic_arguments = MakeConversionSources(arguments);
  OverloadResult resolution = ResolveOverload(semantic_arguments, complete_candidates, *ast_context_, symbol_table_);
  if (const auto* no_viable = std::get_if<NoViableOverload>(&resolution)) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("no matching constructor for type '{}'", expression.target_name));
    for (const auto& candidate : no_viable->candidates) {
      BOOST_ASSERT(candidate.target);
      const SourceRange candidate_range{candidate.target->range.begin, candidate.target->range.begin};
      if (const auto* arity = std::get_if<CandidateArityFailure>(&candidate.failure)) {
        EmitDiagnostic(kNoteDiagnostic, candidate_range,
                       fmt::format("candidate constructor requires {} {}, but {} {} provided", arity->required,
                                   arity->required == 1 ? "argument" : "arguments", arity->provided,
                                   arity->provided == 1 ? "was" : "were"));
      } else if (const auto* argument = std::get_if<CandidateArgumentFailure>(&candidate.failure)) {
        EmitDiagnostic(kNoteDiagnostic, candidate_range,
                       fmt::format("candidate constructor is not viable: {} for argument {}",
                                   FormatConversionFailure(argument->failure), argument->index + 1));
      }
    }
    return;
  }
  if (const auto* ambiguous = std::get_if<AmbiguousOverload>(&resolution)) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("construction of '{}' is ambiguous", expression.target_name));
    for (const FunctionDecl* declaration : ambiguous->candidates) {
      EmitDiagnostic(kNoteDiagnostic, {declaration->range.begin, declaration->range.begin}, "candidate constructor");
    }
    return;
  }

  // Finish the winning constructor's parameter formations before converting arguments or the address.
  const auto& selected_overload = std::get<SelectedOverload>(resolution);
  const auto* selected = static_cast<const ConstructorDecl*>(selected_overload.target);
  BOOST_ASSERT(selected);
  const auto& function_type = static_cast<const FunctionType&>(*selected->type.GetTypePtr());
  const auto& parameter_types = function_type.GetParameterTypes();
  auto formation = CompleteArguments(semantic_arguments, *selected, selected_overload.conversions, symbol_table_);
  expression.constructor = selected;
  if (const auto* failure = std::get_if<ArgumentCompletionFailure>(&formation)) {
    Diagnose(expression, kErrorDiagnostic, expression.Args[failure->index]->range,
             fmt::format("cannot initialize parameter {} of constructor '{}': {}", failure->index + 1,
                         expression.target_name, FormatObjectFormationFailure(failure->failure)));
    return;
  }
  const auto& plans = std::get<std::vector<ConversionSequence>>(formation);
  CommitArgumentConversions(ExpressionSlots(expression.Args), parameter_types, plans);
  BOOST_ASSERT(selected->target_type == target_type);

  ApplyDefaultValueConversion(expression.TargetAddress);
  FormConstructionResult(expression, *selected, true);
}

void Sema::AnalyzeDestructorCallExpr(DestructorCallExpr& expression) {
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;

  if (!expression.Callee || expression.Callee->GetKind() != NodeKind::DeclRefExpr) {
    expression.contains_errors = true;
    return;
  }
  auto& callee = static_cast<DeclRefExpr&>(*expression.Callee);
  if (callee.ContainsErrors() || callee.name.empty()) {
    return;
  }

  const Symbol* symbol = symbol_table_.Lookup(callee.name);
  if (!symbol) {
    Diagnose(expression, kErrorDiagnostic, callee.range,
             fmt::format("unknown destructor target type '{}'", callee.name));
    callee.contains_errors = true;
    return;
  }
  const TypeSymbol* type_symbol = AsTypeSymbol(symbol);
  if (!type_symbol) {
    Diagnose(expression, kErrorDiagnostic, callee.range, fmt::format("'{}' does not name a struct type", callee.name));
    callee.contains_errors = true;
    return;
  }
  const StructType* target_type = ast_context_->GetStructType(type_symbol->GetDeclaration());

  bool address_is_valid = false;
  if (expression.TargetAddress && !expression.TargetAddress->ContainsErrors()) {
    if (!expression.TargetAddress->type) {
      expression.contains_errors = true;
    } else if (expression.TargetAddress->type.GetTypePtr()->GetKind() == TypeKind::Pointer) {
      const QualType pointee =
          static_cast<const PointerType*>(expression.TargetAddress->type.GetTypePtr())->GetPointee();
      address_is_valid = pointee.GetTypePtr() == target_type;
    }
    if (!address_is_valid && expression.TargetAddress->type) {
      const QualType mutable_pointer(ast_context_->GetPointerType(QualType(target_type)));
      const QualType const_pointer(ast_context_->GetPointerType(QualType(target_type, true)));
      Diagnose(
          expression, kErrorDiagnostic, expression.TargetAddress->range,
          fmt::format("destructor target address must have type '{}' or '{}', not {}", TypeSpelling(mutable_pointer),
                      TypeSpelling(const_pointer), DescribeExpressionType(expression.TargetAddress->type)));
    }
  }

  bool arguments_are_valid = expression.Args.empty();
  for (const auto& argument : expression.Args) {
    if (!argument || argument->ContainsErrors()) {
      arguments_are_valid = false;
    } else if (!argument->type) {
      arguments_are_valid = false;
      expression.contains_errors = true;
    }
  }
  if (!address_is_valid || !arguments_are_valid || expression.ContainsErrors()) {
    return;
  }

  const DestructorDecl* declaration = type_symbol->GetDestructor();
  if (!declaration) {
    callee.contains_errors = true;
    expression.contains_errors = true;
    Diagnose(expression, kErrorDiagnostic, expression.range,
             fmt::format("no destructor declared for type '{}'", callee.name));
    return;
  }
  BOOST_ASSERT(declaration->target_type == target_type);
  BOOST_ASSERT(declaration->type && declaration->type.GetTypePtr()->GetKind() == TypeKind::Function);

  ApplyDefaultValueConversion(expression.TargetAddress);
  FormDestructorCallResult(expression, callee, *declaration);
}

void Sema::AnalyzeReceiverCallExpr(ReceiverCallExpr& expression) {
  BOOST_ASSERT(expression.op == expr::period || expression.op == expr::arrow);
  expression.type = QualType{};
  expression.value_category = ValueCategory::None;

  // Normalize an arrow receiver to one dereference so matching and later conversion use the same object.
  QualType receiver_type;
  ValueCategory receiver_category = ValueCategory::None;
  bool receiver_is_valid = false;
  if (expression.Receiver && !expression.Receiver->ContainsErrors() && expression.Receiver->type) {
    if (expression.op == expr::period) {
      receiver_type = expression.Receiver->type;
      receiver_category = expression.Receiver->value_category;
      if ((receiver_type && receiver_type.GetTypePtr()->IsObject()) && receiver_category != ValueCategory::None) {
        receiver_is_valid = true;
      } else {
        Diagnose(expression, kErrorDiagnostic, expression.operator_range,
                 fmt::format("receiver call with '.' requires an object expression, not {}",
                             DescribeExpressionType(receiver_type)));
      }
    } else {
      const QualType pointer_type = expression.Receiver->type;
      if (pointer_type.GetTypePtr()->GetKind() == TypeKind::Pointer) {
        const QualType pointee_type = static_cast<const PointerType*>(pointer_type.GetTypePtr())->GetPointee();
        if ((pointee_type && pointee_type.GetTypePtr()->IsObject())) {
          ApplyDefaultValueConversion(expression.Receiver);
          auto dereference = std::make_unique<UnaryOperator>();
          dereference->range = expression.Receiver->range;
          dereference->operator_range = expression.operator_range;
          dereference->op = expr::star;
          dereference->type = pointee_type;
          dereference->value_category = ValueCategory::LValue;
          dereference->Operand = std::move(expression.Receiver);
          expression.Receiver = std::move(dereference);
          receiver_type = pointee_type;
          receiver_category = ValueCategory::LValue;
          receiver_is_valid = true;
        }
      }
      if (!receiver_is_valid) {
        Diagnose(expression, kErrorDiagnostic, expression.operator_range,
                 fmt::format("receiver call with '->' requires a pointer to an object, not {}",
                             DescribeExpressionType(pointer_type)));
      }
    }
  } else if (expression.Receiver && !expression.Receiver->ContainsErrors()) {
    expression.contains_errors = true;
  }

  DeclRefExpr* callee = nullptr;
  const FunctionSymbol* function_symbol = nullptr;
  bool callee_is_valid = false;
  if (expression.Callee && !expression.Callee->ContainsErrors() &&
      expression.Callee->GetKind() == NodeKind::DeclRefExpr) {
    callee = static_cast<DeclRefExpr*>(expression.Callee.get());
    if (!callee->name.empty() && !IsOperatorFunctionName(callee->name) && !callee->declaration && callee->type &&
        callee->type.GetTypePtr()->GetKind() == TypeKind::FunctionOverloadSet) {
      const Symbol* symbol = symbol_table_.Lookup(callee->name);
      function_symbol = AsFunctionSymbol(symbol);
      if (function_symbol) {
        callee_is_valid = true;
      } else if (symbol) {
        Diagnose(expression, kErrorDiagnostic, callee->range,
                 fmt::format("'{}' does not name an ordinary function", callee->name));
      }
    } else if (callee->declaration) {
      Diagnose(expression, kErrorDiagnostic, callee->range,
               fmt::format("'{}' does not name an ordinary function", callee->name));
    }
  }

  bool arguments_are_valid = true;
  for (const auto& argument : expression.Args) {
    if (!argument || argument->ContainsErrors() || !argument->type) {
      arguments_are_valid = false;
    }
  }
  if (!receiver_is_valid || !callee_is_valid || !arguments_are_valid || expression.ContainsErrors()) {
    return;
  }

  BOOST_ASSERT(callee);
  BOOST_ASSERT(function_symbol);
  const std::vector<const FunctionDecl*> complete_candidates = CollectFunctionCallCandidates(
      *function_symbol, callee->name,
      expression.is_nonvirtual ? CallCandidateMode::NonVirtual : CallCandidateMode::Regular);
  if (complete_candidates.empty()) {
    callee->contains_errors = true;
    expression.contains_errors = true;
    if (expression.is_nonvirtual && !HasInvalidFunctionDeclaration(*function_symbol, callee->name)) {
      Diagnose(expression, kErrorDiagnostic, expression.range,
               fmt::format("no matching receiver function for nonvirtual call to '{}'", callee->name));
    }
    return;
  }

  // The receiver is parameter zero for matching; diagnostics translate the remaining indices back
  // to the explicit argument list.
  std::vector<ConversionSource> semantic_arguments;
  semantic_arguments.reserve(expression.Args.size() + 1);
  semantic_arguments.push_back(MakeConversionSource(*expression.Receiver));
  for (const auto& argument : expression.Args) semantic_arguments.push_back(MakeConversionSource(*argument));

  OverloadResult resolution = ResolveOverload(semantic_arguments, complete_candidates, *ast_context_, symbol_table_);
  if (const auto* no_viable = std::get_if<NoViableOverload>(&resolution)) {
    Diagnose(expression, kErrorDiagnostic, expression.range,
             expression.is_nonvirtual
                 ? fmt::format("no matching receiver function for nonvirtual call to '{}'", callee->name)
                 : fmt::format("no matching receiver function for call to '{}'", callee->name));
    callee->contains_errors = true;

    for (const auto& candidate : no_viable->candidates) {
      BOOST_ASSERT(candidate.target);
      const SourceRange candidate_range{candidate.target->range.begin, candidate.target->range.begin};
      if (const auto* arity = std::get_if<CandidateArityFailure>(&candidate.failure)) {
        if (arity->required == 0) {
          EmitDiagnostic(kNoteDiagnostic, candidate_range,
                         "candidate function is not viable: no receiver parameter is declared");
        } else {
          BOOST_ASSERT(arity->provided > 0);
          const std::size_t required = arity->required - 1;
          const std::size_t provided = arity->provided - 1;
          EmitDiagnostic(
              kNoteDiagnostic, candidate_range,
              fmt::format("candidate function requires {} explicit {}, but {} {} provided", required,
                          required == 1 ? "argument" : "arguments", provided, provided == 1 ? "was" : "were"));
        }
        continue;
      }

      const auto* argument = std::get_if<CandidateArgumentFailure>(&candidate.failure);
      if (!argument) {
        continue;
      }
      if (argument->index == 0) {
        EmitDiagnostic(kNoteDiagnostic, candidate_range,
                       fmt::format("candidate function is not viable: {} for receiver",
                                   FormatConversionFailure(argument->failure)));
        continue;
      }

      EmitDiagnostic(kNoteDiagnostic, candidate_range,
                     fmt::format("candidate function is not viable: {} for argument {}",
                                 FormatConversionFailure(argument->failure), argument->index));
    }
    return;
  }

  if (const auto* ambiguous = std::get_if<AmbiguousOverload>(&resolution)) {
    Diagnose(expression, kErrorDiagnostic, expression.range, fmt::format("call to '{}' is ambiguous", callee->name));
    callee->contains_errors = true;
    for (const FunctionDecl* declaration : ambiguous->candidates) {
      EmitDiagnostic(kNoteDiagnostic, {declaration->range.begin, declaration->range.begin}, "candidate function");
    }
    return;
  }

  // Complete receiver and explicit-argument formation together before committing either.
  const auto& selected = std::get<SelectedOverload>(resolution);
  const FunctionDecl& declaration = *selected.target;
  const auto& function_type = static_cast<const FunctionType&>(*declaration.type.GetTypePtr());
  const auto& parameter_types = function_type.GetParameterTypes();
  auto formation = CompleteArguments(semantic_arguments, declaration, selected.conversions, symbol_table_);

  callee->declaration = &declaration;
  callee->type = declaration.type;
  if (const auto* failure = std::get_if<ArgumentCompletionFailure>(&formation)) {
    if (failure->index == 0) {
      Diagnose(expression, kErrorDiagnostic, expression.Receiver->range,
               fmt::format("cannot initialize receiver of function '{}': {}", callee->name,
                           FormatObjectFormationFailure(failure->failure)));
    } else {
      const std::size_t explicit_index = failure->index - 1;
      BOOST_ASSERT(explicit_index < expression.Args.size());
      Diagnose(expression, kErrorDiagnostic, expression.Args[explicit_index]->range,
               fmt::format("cannot initialize parameter {} of receiver function '{}': {}", explicit_index + 1,
                           callee->name, FormatObjectFormationFailure(failure->failure)));
    }
    return;
  }

  const auto& plans = std::get<std::vector<ConversionSequence>>(formation);
  BOOST_ASSERT(plans.size() == parameter_types.size());
  auto argument_slots = ExpressionSlots(expression.Args);
  argument_slots.insert(argument_slots.begin(), &expression.Receiver);
  CommitArgumentConversions(argument_slots, parameter_types, plans);
  FormCallResult(expression, function_type);
}

void Sema::FormCallResult(CallExpr& expression, const FunctionType& function_type) {
  const QualType return_type(function_type.GetReturnType());
  if (const ReferenceType* reference_type = (return_type ? return_type.GetTypePtr()->AsReferenceType() : nullptr)) {
    expression.type = QualType(reference_type->GetReferentType());
    switch (reference_type->GetMode()) {
      case ReferenceMode::Mut:
        expression.value_category = ValueCategory::LValue;
        break;
      case ReferenceMode::Copy:
        expression.type = expression.type.WithConst();
        expression.value_category = ValueCategory::LValue;
        break;
      case ReferenceMode::Move:
        expression.value_category = ValueCategory::MoveLValue;
        break;
    }
  } else {
    expression.type = return_type.WithoutConst();
    const bool produces_object = return_type && return_type.GetTypePtr()->IsObject();
    expression.value_category = produces_object ? ValueCategory::PureRValue : ValueCategory::None;
  }
}

void Sema::FormDirectCallResult(CallExpr& expression, DeclRefExpr& callee, const FunctionDecl& declaration) {
  BOOST_ASSERT(declaration.type && declaration.type.GetTypePtr()->GetKind() == TypeKind::Function);
  callee.declaration = &declaration;
  callee.type = declaration.type;
  FormCallResult(expression, static_cast<const FunctionType&>(*declaration.type.GetTypePtr()));
}

void Sema::FormConstructionResult(ConstructionExpr& expression, const ConstructorDecl& declaration,
                                  bool returns_pointer) {
  BOOST_ASSERT(declaration.target_type);
  BOOST_ASSERT(declaration.type && declaration.type.GetTypePtr()->GetKind() == TypeKind::Function);
  expression.constructor = &declaration;
  expression.type = returns_pointer ? QualType(ast_context_->GetPointerType(QualType(declaration.target_type)))
                                    : QualType(declaration.target_type);
  expression.value_category = ValueCategory::PureRValue;
}

void Sema::FormDestructorCallResult(DestructorCallExpr& expression, DeclRefExpr& callee,
                                    const DestructorDecl& declaration) {
  BOOST_ASSERT(declaration.target_type);
  BOOST_ASSERT(declaration.type && declaration.type.GetTypePtr()->GetKind() == TypeKind::Function);
  callee.declaration = &declaration;
  callee.type = declaration.type;
  expression.type = QualType(ast_context_->GetBuiltinType(BuiltinTypeKind::Void));
  expression.value_category = ValueCategory::None;
}

bool Sema::MaterializeComptimeInteger(std::unique_ptr<Expr>& expression) {
  BOOST_ASSERT(expression);
  BOOST_ASSERT(expression->type);
  BOOST_ASSERT(expression->type.GetTypePtr()->GetKind() == TypeKind::ComptimeInt);

  const auto value = EvaluateComptimeInteger(*expression);
  BOOST_ASSERT(value && "all currently supported comptime integers are evaluable");
  if (!value) {
    return false;
  }

  const BuiltinType* default_type = DefaultIntegerType(*ast_context_, *value);
  if (!default_type) {
    Diagnose(*expression, kErrorDiagnostic, expression->range,
             "integer constant cannot be represented by any default integer type");
    return false;
  }

  WrapInImplicitCast(expression, QualType(default_type), ImplicitConversionKind::ComptimeIntegerMaterialization);
  return true;
}

void Sema::DiagnoseImplicitConversionRisk(Node& owner, const SourceRange& range, QualType source, QualType target,
                                          ImplicitConversionKind kind, ImplicitConversionRisk risk) {
  switch (risk) {
    case ImplicitConversionRisk::None:
      break;
    case ImplicitConversionRisk::IntegerTruncation:
      BOOST_ASSERT(kind == ImplicitConversionKind::IntegerToInteger);
      Diagnose(owner, kWarningDiagnostic, range,
               fmt::format("implicit integer conversion from '{}' to '{}' may truncate value", TypeSpelling(source),
                           TypeSpelling(target)));
      break;
    case ImplicitConversionRisk::IntegerToFloatPrecisionLoss:
      BOOST_ASSERT(kind == ImplicitConversionKind::IntegerToFloat);
      Diagnose(owner, kWarningDiagnostic, range,
               fmt::format("implicit conversion from '{}' to '{}' may lose integer precision", TypeSpelling(source),
                           TypeSpelling(target)));
      break;
    case ImplicitConversionRisk::FloatNarrowing:
      BOOST_ASSERT(kind == ImplicitConversionKind::FloatToFloat);
      Diagnose(owner, kWarningDiagnostic, range,
               fmt::format("implicit floating-point conversion from '{}' to '{}' may lose precision or range",
                           TypeSpelling(source), TypeSpelling(target)));
      break;
    case ImplicitConversionRisk::FloatToIntegerValueLoss:
      BOOST_ASSERT(kind == ImplicitConversionKind::FloatToInteger);
      Diagnose(owner, kWarningDiagnostic, range,
               fmt::format("implicit conversion from '{}' to '{}' may lose fractional value or exceed integer range",
                           TypeSpelling(source), TypeSpelling(target)));
      break;
  }
}

void Sema::FinalizeVariableInitializer(VarDecl& declaration, std::unique_ptr<Expr>& initializer, TypeUseKind use) {
  BOOST_ASSERT(initializer);
  const bool has_explicit_type = declaration.Type != nullptr;
  if (initializer->ContainsErrors() || !initializer->type) {
    if (!has_explicit_type) {
      declaration.type = QualType{};
    }
    return;
  }
  BOOST_ASSERT(!initializer->type.GetTypePtr()->AsComptimeIntType());
  if (has_explicit_type) {
    if (declaration.type && !declaration.Type->ContainsErrors()) {
      ConvertExpression(initializer, declaration.type, *initializer,
                        fmt::format("cannot initialize variable '{}': ", declaration.name));
    }
    return;
  }
  if (initializer->type.GetTypePtr()->AsAddressOfFunctionOverloadSetType()) {
    ConvertExpression(initializer, QualType{}, *initializer, "");
    declaration.type = QualType{};
    return;
  }
  if (!initializer->type.GetTypePtr()->IsObject() || initializer->value_category == ValueCategory::None) {
    Diagnose(*initializer, kErrorDiagnostic, initializer->range,
             fmt::format("cannot infer an object type from {}",
                         DescribeExpressionType(initializer->type, "expression of type ")));
    declaration.type = QualType{};
    return;
  }
  const QualType inferred_type = initializer->type.WithoutConst();
  declaration.type = QualType{};
  if (!ValidateTypeUse(*initializer, inferred_type, use)) {
    return;
  }
  QualType object_type = inferred_type;
  TypeUseKind object_use = use;
  while (const auto* array = object_type.GetTypePtr()->AsArrayType()) {
    object_type = array->GetElementType();
    object_use = TypeUseKind::ArrayElement;
  }
  if (!ValidateAbstractObjectType(*initializer, object_type, object_use)) {
    return;
  }
  const bool initialized =
      ConvertExpression(initializer, inferred_type, *initializer, "cannot infer and initialize variable: ");
  declaration.type = initialized ? inferred_type : QualType{};
}

void Sema::AddLocalVariable(VarDecl& declaration) {
  if (declaration.name.empty()) {
    return;
  }

  auto [symbol, inserted] = symbol_table_.Insert(declaration.name, std::make_unique<VariableSymbol>(&declaration));
  if (inserted) {
    return;
  }

  BOOST_ASSERT(symbol);
  BOOST_ASSERT(symbol->GetKind() == SymbolKind::Variable);
  Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
           fmt::format("redefinition of variable '{}'", declaration.name));
  EmitDiagnostic(kNoteDiagnostic, SymbolDeclarationRange(*symbol), "previous declaration is here");
}

void Sema::CheckFunctionOperatorAndReturnDeclaration(FunctionDecl& declaration) {
  if (declaration.GetKind() == NodeKind::VirtualFunctionDecl && declaration.name == ":=") {
    Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
             fmt::format("operator '{}' cannot be overloaded", declaration.name));
  }
  if (declaration.ReturnVar && !declaration.ReturnVar->name.empty() && declaration.ReturnVar->type &&
      declaration.ReturnVar->type.GetTypePtr()->IsVoid()) {
    Diagnose(declaration, kErrorDiagnostic, declaration.ReturnVar->range,
             "void function cannot declare a named return object");
  }
}

void Sema::CheckFunctionDeclaration(FunctionDecl& declaration) {
  CheckFunctionVariableAttributes(declaration);
  CheckExplicitThisParameters(declaration);
  CheckFunctionVariableNames(declaration);
  if (declaration.name.empty()) {
    Diagnose(declaration, kErrorDiagnostic, NamedDeclarationRange(declaration),
             "function declaration requires a name or operator");
  }
}

void Sema::CheckConstructorDeclaration(ConstructorDecl& declaration) {
  CheckFunctionVariableAttributes(declaration);
  CheckExplicitThisParameters(declaration);
  CheckFunctionVariableNames(declaration);
}

void Sema::CheckDestructorDeclaration(DestructorDecl& declaration) {
  CheckFunctionVariableAttributes(declaration);
  CheckFunctionVariableNames(declaration);
}

void Sema::CheckExplicitThisParameters(FunctionDecl& declaration) {
  const bool declaration_allows_explicit_this =
      declaration.GetKind() == NodeKind::FunctionDecl || declaration.GetKind() == NodeKind::VirtualFunctionDecl;
  for (std::size_t index = 0; index < declaration.ParmVars.size(); ++index) {
    const auto& parameter = declaration.ParmVars[index];
    if (!parameter || parameter->name != "this") {
      continue;
    }

    if (!declaration_allows_explicit_this) {
      Diagnose(*parameter, kErrorDiagnostic, parameter->name_range,
               "constructor cannot declare an explicit 'this' parameter");
    } else if (index != 0) {
      Diagnose(*parameter, kErrorDiagnostic, parameter->name_range, "'this' parameter must be the first parameter");
    } else if (parameter->type && !(parameter->type && parameter->type.GetTypePtr()->AsReferenceType())) {
      Diagnose(*parameter, kErrorDiagnostic, parameter->name_range,
               "'this' parameter must have type 'mut T', 'copy T', or 'move T'");
    }
    InheritErrors(declaration, parameter.get());
  }
}

void Sema::CheckVariableGroupDeclaration(VarGroupDecl& declaration, TypeUseKind use) {
  // Group attributes are copied to each VarDecl, but each spelling must be
  // diagnosed only once.
  VarDecl* first_variable = nullptr;
  for (const auto& variable : declaration.Vars) {
    if (variable) {
      first_variable = variable.get();
      break;
    }
  }
  if (!first_variable) {
    return;
  }
  CheckVariableAttributes(*first_variable);
  InheritErrors(declaration, first_variable);

  if (use == TypeUseKind::GlobalVariable && declaration.InitExprs.empty() && !declaration.Body) {
    const SourceRange range = NamedDeclarationRange(*first_variable);
    Diagnose(declaration, kErrorDiagnostic, {range.begin, range.begin},
             "global variable declaration requires an initializer");
  } else {
    for (const auto& variable : declaration.Vars) {
      if (!variable || variable->Type || (!declaration.Body && !declaration.InitExprs.empty())) {
        continue;
      }
      const SourceRange range = NamedDeclarationRange(*variable);
      Diagnose(*variable, kErrorDiagnostic, {range.begin, range.begin},
               declaration.Body ? "variable initializer block requires an explicit type"
                                : "variable declaration requires a type or initializer");
      InheritErrors(declaration, variable.get());
    }
  }

  if (!declaration.InitExprs.empty() && declaration.Vars.size() != declaration.InitExprs.size()) {
    SourceRange range = declaration.range;
    if (declaration.InitExprs.size() < declaration.Vars.size()) {
      const auto& variable = declaration.Vars[declaration.InitExprs.size()];
      if (variable) {
        range = NamedDeclarationRange(*variable);
      }
    } else {
      const auto& initializer = declaration.InitExprs[declaration.Vars.size()];
      if (initializer) {
        range = initializer->range;
      }
    }
    Diagnose(declaration, kErrorDiagnostic, range, "variable count does not match initializer count");
  }
}

void Sema::CheckFunctionVariableAttributes(FunctionDecl& declaration) {
  for (const auto& parameter : declaration.ParmVars) {
    if (parameter) {
      CheckVariableAttributes(*parameter);
      InheritErrors(declaration, parameter.get());
    }
  }
  if (declaration.ReturnVar) {
    CheckVariableAttributes(*declaration.ReturnVar);
    InheritErrors(declaration, declaration.ReturnVar.get());
  }
}

void Sema::CheckFunctionVariableNames(FunctionDecl& declaration) {
  std::unordered_map<std::string, VarDecl*> names;
  const auto check_name = [&](VarDecl* variable) {
    if (!variable || variable->name.empty()) {
      return;
    }

    const auto [previous, inserted] = names.emplace(variable->name, variable);
    if (!inserted) {
      Diagnose(*variable, kErrorDiagnostic, NamedDeclarationRange(*variable),
               fmt::format("redefinition of variable '{}'", variable->name));
      EmitDiagnostic(kNoteDiagnostic, NamedDeclarationRange(*previous->second), "previous declaration is here");
    }
    InheritErrors(declaration, variable);
  };

  for (const auto& parameter : declaration.ParmVars) check_name(parameter.get());
  check_name(declaration.ReturnVar.get());
}

void Sema::CheckVariableAttributes(VarDecl& declaration) {
  std::unordered_set<std::string> names;
  for (const Attribute& attribute : declaration.attributes) {
    Diagnose(declaration, kErrorDiagnostic, attribute.range, fmt::format("unknown attribute '{}'", attribute.name));
    if (!names.insert(attribute.name).second) {
      Diagnose(declaration, kErrorDiagnostic, attribute.range, fmt::format("duplicate attribute '{}'", attribute.name));
    }
  }
}

void Sema::ResolveStructDeclarationTypes(StructDecl& declaration) {
  if (!declaration.base.empty()) {
    const TypeSymbol* type_symbol = AsTypeSymbol(symbol_table_.Lookup(declaration.base));
    if (!type_symbol) {
      Diagnose(declaration, kErrorDiagnostic, declaration.base_range,
               fmt::format("unknown type '{}'", declaration.base));
    } else {
      declaration.base_type = ast_context_->GetStructType(type_symbol->GetDeclaration());
    }
  }

  if (declaration.VirtualDecl) {
    for (const auto& function : declaration.VirtualDecl->Functions) {
      if (function) {
        ResolveFunctionDeclarationTypes(*function);
        InheritErrors(*declaration.VirtualDecl, function.get());
      }
    }
    InheritErrors(declaration, declaration.VirtualDecl.get());
  }

  std::unordered_map<std::string, FieldDecl*> direct_fields;
  for (const auto& field : declaration.Fields) {
    if (field) {
      ResolveTypeUse(field->Type.get(), TypeUseKind::Field, field->type);
      InheritErrors(*field, field->Type.get());
      if (!field->name.empty()) {
        const auto [it, inserted] = direct_fields.emplace(field->name, field.get());
        if (!inserted) {
          DiagnoseConflict(*field, NamedDeclarationRange(*field),
                           fmt::format("duplicate field '{}' in struct '{}'", field->name, declaration.name),
                           NamedDeclarationRange(*it->second), "previous field declaration is here");
        }
      }
      InheritErrors(declaration, field.get());
    }
  }
}

void Sema::ValidateStructInheritance(TranslationUnitDecl& translation_unit) {
  enum class State {
    Unvisited,
    Visiting,
    Valid,
    Invalid,
  };

  std::unordered_map<const StructDecl*, State> states;
  for (const auto& declaration : translation_unit.Decls) {
    if (declaration && declaration->GetKind() == NodeKind::StructDecl) {
      states.emplace(static_cast<const StructDecl*>(declaration.get()), State::Unvisited);
    }
  }

  const auto validate = [&](const auto& self, StructDecl& declaration) -> bool {
    State& state = states[&declaration];
    if (state == State::Valid) {
      return true;
    }
    if (state == State::Invalid) {
      return false;
    }
    BOOST_ASSERT(state == State::Unvisited);
    state = State::Visiting;

    if (declaration.base_type) {
      StructDecl* base = const_cast<StructDecl*>(declaration.base_type->GetDeclaration());
      BOOST_ASSERT(base);
      const State base_state = states[base];
      if (base_state == State::Visiting) {
        Diagnose(declaration, kErrorDiagnostic, declaration.base_range,
                 fmt::format("inheritance cycle involving struct '{}'", base->name));
        state = State::Invalid;
        return false;
      }
      if (!self(self, *base)) {
        declaration.contains_errors = true;
        state = State::Invalid;
        return false;
      }

      for (const auto& field : declaration.Fields) {
        if (!field || field->name != base->name) {
          continue;
        }
        DiagnoseConflict(*field, NamedDeclarationRange(*field),
                         fmt::format("field '{}' conflicts with direct base '{}'", field->name, base->name),
                         declaration.base_range, "direct base is specified here");
        break;
      }
    }

    state = State::Valid;
    return true;
  };

  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::StructDecl) {
      continue;
    }
    auto& structure = static_cast<StructDecl&>(*declaration);
    if (states[&structure] == State::Unvisited) {
      validate(validate, structure);
    }
  }
}

void Sema::ValidateObjectContainment(TranslationUnitDecl& translation_unit) {
  struct Edge {
    StructDecl* target{};
    Node* diagnostic_owner{};
    SourceRange range{};
    bool is_field{};
  };

  // Only by-value containment contributes an edge; arrays expose their leaf structure.
  const auto contained_structure = [](QualType type) -> StructDecl* {
    while (type && type.GetTypePtr()->GetKind() == TypeKind::Array) {
      type = static_cast<const ArrayType*>(type.GetTypePtr())->GetElementType();
    }
    if (!type || type.GetTypePtr()->GetKind() != TypeKind::Struct) {
      return nullptr;
    }
    return const_cast<StructDecl*>(static_cast<const StructType*>(type.GetTypePtr())->GetDeclaration());
  };

  std::vector<StructDecl*> structures;
  std::unordered_map<StructDecl*, std::vector<Edge>> graph;
  for (const auto& declaration : translation_unit.Decls) {
    if (!declaration || declaration->GetKind() != NodeKind::StructDecl) {
      continue;
    }
    auto* structure = static_cast<StructDecl*>(declaration.get());
    structures.push_back(structure);

    auto& outgoing = graph[structure];
    if (structure->base_type) {
      outgoing.push_back(Edge{const_cast<StructDecl*>(structure->base_type->GetDeclaration()), structure,
                              structure->base_range, false});
    }
    for (const auto& field : structure->Fields) {
      if (!field || !field->type) {
        continue;
      }
      if (StructDecl* target = contained_structure(field->type)) {
        const SourceRange range = field->Type ? field->Type->range : field->range;
        outgoing.push_back(Edge{target, field.get(), range, true});
      }
    }
  }

  // Tarjan low links partition the containment graph into strongly connected components.
  std::unordered_map<StructDecl*, std::size_t> indices;
  std::unordered_map<StructDecl*, std::size_t> low_links;
  std::unordered_set<StructDecl*> on_stack;
  std::vector<StructDecl*> stack;
  std::size_t next_index = 0;

  const auto visit = [&](const auto& self, StructDecl& structure) -> void {
    indices.emplace(&structure, next_index);
    low_links.emplace(&structure, next_index);
    ++next_index;
    stack.push_back(&structure);
    on_stack.insert(&structure);

    for (const Edge& edge : graph.at(&structure)) {
      const auto target_index = indices.find(edge.target);
      if (target_index == indices.end()) {
        self(self, *edge.target);
        low_links[&structure] = std::min(low_links[&structure], low_links.at(edge.target));
      } else if (on_stack.find(edge.target) != on_stack.end()) {
        low_links[&structure] = std::min(low_links[&structure], target_index->second);
      }
    }

    if (low_links[&structure] != indices.at(&structure)) {
      return;
    }

    std::vector<StructDecl*> component;
    for (;;) {
      BOOST_ASSERT(!stack.empty());
      StructDecl* member = stack.back();
      stack.pop_back();
      on_stack.erase(member);
      component.push_back(member);
      if (member == &structure) {
        break;
      }
    }

    // Diagnose one field edge per cyclic component and mark all participating structures.
    const std::unordered_set<StructDecl*> members(component.begin(), component.end());
    const Edge* diagnostic_edge = nullptr;
    for (StructDecl* member : component) {
      for (const Edge& edge : graph.at(member)) {
        if (edge.is_field && members.find(edge.target) != members.end()) {
          diagnostic_edge = &edge;
          break;
        }
      }
      if (diagnostic_edge) {
        break;
      }
    }
    if (!diagnostic_edge) {
      return;
    }  // Pure inheritance cycles are diagnosed by ValidateStructInheritance.

    for (StructDecl* member : component) member->contains_errors = true;
    Diagnose(*diagnostic_edge->diagnostic_owner, kErrorDiagnostic, diagnostic_edge->range,
             fmt::format("by-value object containment cycle involving struct '{}'", diagnostic_edge->target->name));
  };

  for (StructDecl* structure : structures) {
    if (indices.find(structure) == indices.end()) {
      visit(visit, *structure);
    }
  }
}

void Sema::ResolveFunctionDeclarationTypes(FunctionDecl& declaration) {
  std::vector<const Type*> parameter_types;
  parameter_types.reserve(declaration.ParmVars.size());
  bool complete = true;

  for (const auto& parameter : declaration.ParmVars) {
    if (!parameter) {
      complete = false;
      continue;
    }
    const bool valid = ResolveTypeUse(parameter->Type.get(), TypeUseKind::Parameter, parameter->type);
    InheritErrors(*parameter, parameter->Type.get());
    InheritErrors(declaration, parameter.get());
    if (!valid || parameter->ContainsErrors() || !parameter->type) {
      complete = false;
    }
    parameter_types.push_back(parameter->type.GetTypePtr());
  }

  if (declaration.ReturnVar) {
    const bool valid =
        ResolveTypeUse(declaration.ReturnVar->Type.get(), TypeUseKind::Return, declaration.ReturnVar->type);
    InheritErrors(*declaration.ReturnVar, declaration.ReturnVar->Type.get());
    InheritErrors(declaration, declaration.ReturnVar.get());
    if (!valid || !declaration.ReturnVar->type) {
      complete = false;
    }
  }

  if (!complete || parameter_types.size() != declaration.ParmVars.size()) {
    return;
  }

  if ((declaration.GetKind() == NodeKind::ConstructorDecl || declaration.GetKind() == NodeKind::DestructorDecl) &&
      !declaration.Body) {
    return;
  }

  QualType return_type(ast_context_->GetBuiltinType(BuiltinTypeKind::Void));
  if (declaration.GetKind() != NodeKind::ConstructorDecl && declaration.GetKind() != NodeKind::DestructorDecl &&
      declaration.ReturnVar) {
    return_type = declaration.ReturnVar->type;
  }
  if (!return_type) {
    return;
  }

  declaration.type = QualType(ast_context_->GetFunctionType(parameter_types, return_type.GetTypePtr()));
}

void Sema::ResolveVariableGroupTypes(VarGroupDecl& declaration, TypeUseKind use) {
  for (const auto& variable : declaration.Vars) {
    if (!variable || !variable->Type) {
      continue;
    }
    ResolveTypeUse(variable->Type.get(), use, variable->type);
    if (variable->type) {
      ValidateAbstractTypeUse(*variable->Type, variable->type, use);
    }
    InheritErrors(*variable, variable->Type.get());
    InheritErrors(declaration, variable.get());
  }
}

bool Sema::ResolveTypeUse(TypeSyntax* type_syntax, TypeUseKind use, QualType& resolved_type) {
  if (!type_syntax || type_syntax->ContainsErrors()) {
    return false;
  }

  resolved_type = ResolveType(*type_syntax);
  if (!resolved_type) {
    return false;
  }
  return ValidateTypeUse(*type_syntax, resolved_type, use);
}

QualType Sema::ResolveType(TypeSyntax& type_syntax) {
  switch (type_syntax.GetKind()) {
    case NodeKind::BuiltinTypeSyntax:
      return QualType(ast_context_->GetBuiltinType(static_cast<BuiltinTypeSyntax&>(type_syntax).kind));
    case NodeKind::NamedTypeSyntax: {
      auto& named_type_syntax = static_cast<NamedTypeSyntax&>(type_syntax);
      const TypeSymbol* type_symbol = AsTypeSymbol(symbol_table_.Lookup(named_type_syntax.name));
      if (!type_symbol) {
        Diagnose(named_type_syntax, kErrorDiagnostic, named_type_syntax.range,
                 fmt::format("unknown type '{}'", named_type_syntax.name));
        return QualType{};
      }
      return QualType(ast_context_->GetStructType(type_symbol->GetDeclaration()));
    }
    case NodeKind::PointerTypeSyntax: {
      auto& pointer_type_syntax = static_cast<PointerTypeSyntax&>(type_syntax);
      if (!pointer_type_syntax.Pointee || pointer_type_syntax.Pointee->ContainsErrors()) {
        return QualType{};
      }
      const QualType pointee_type = ResolveType(*pointer_type_syntax.Pointee);
      InheritErrors(pointer_type_syntax, pointer_type_syntax.Pointee.get());
      if (!pointee_type) {
        return QualType{};
      }
      if (pointee_type.GetTypePtr()->AsReferenceType()) {
        Diagnose(pointer_type_syntax, kErrorDiagnostic, pointer_type_syntax.range,
                 "pointer type cannot have a reference pointee");
        return QualType{};
      }
      return QualType(ast_context_->GetPointerType(pointee_type));
    }
    case NodeKind::FunctionTypeSyntax: {
      auto& function_type_syntax = static_cast<FunctionTypeSyntax&>(type_syntax);
      std::vector<const Type*> parameter_types;
      parameter_types.reserve(function_type_syntax.ParameterTypes.size());
      bool complete = true;
      for (const auto& parameter_type_syntax : function_type_syntax.ParameterTypes) {
        QualType parameter_type;
        if (parameter_type_syntax && !parameter_type_syntax->ContainsErrors()) {
          parameter_type = ResolveType(*parameter_type_syntax);
          if (parameter_type && !ValidateTypeUse(*parameter_type_syntax, parameter_type, TypeUseKind::Parameter)) {
            complete = false;
          }
        } else {
          complete = false;
        }
        InheritErrors(function_type_syntax, parameter_type_syntax.get());
        parameter_types.push_back(parameter_type.GetTypePtr());
        if (!parameter_type) {
          complete = false;
        }
      }

      QualType return_type;
      if (function_type_syntax.ReturnType && !function_type_syntax.ReturnType->ContainsErrors()) {
        return_type = ResolveType(*function_type_syntax.ReturnType);
        if (return_type && !ValidateTypeUse(*function_type_syntax.ReturnType, return_type, TypeUseKind::Return)) {
          complete = false;
        }
      } else {
        complete = false;
      }
      InheritErrors(function_type_syntax, function_type_syntax.ReturnType.get());
      if (!return_type) {
        complete = false;
      }

      if (!complete) {
        return QualType{};
      }
      return QualType(ast_context_->GetFunctionType(parameter_types, return_type.GetTypePtr()));
    }
    case NodeKind::VirtualSlotTypeSyntax: {
      auto& virtual_slot_syntax = static_cast<VirtualSlotTypeSyntax&>(type_syntax);
      if (!virtual_slot_syntax.FunctionPointer || virtual_slot_syntax.FunctionPointer->ContainsErrors()) {
        return QualType{};
      }
      const QualType pointer_type = ResolveType(*virtual_slot_syntax.FunctionPointer);
      InheritErrors(virtual_slot_syntax, virtual_slot_syntax.FunctionPointer.get());
      if (!pointer_type || pointer_type.GetTypePtr()->GetKind() != TypeKind::Pointer) {
        return QualType{};
      }
      const auto* pointer = static_cast<const PointerType*>(pointer_type.GetTypePtr());
      const QualType pointee = pointer->GetPointee();
      if (!pointee || pointee.GetTypePtr()->GetKind() != TypeKind::Function) {
        return QualType{};
      }

      const auto& function_type = static_cast<const FunctionType&>(*pointee.GetTypePtr());
      const auto& parameter_types = function_type.GetParameterTypes();
      const ReferenceType* receiver = parameter_types.empty() ? nullptr : parameter_types.front()->AsReferenceType();
      if (!receiver || receiver->GetReferentType()->GetKind() != TypeKind::Struct) {
        Diagnose(virtual_slot_syntax, kErrorDiagnostic, virtual_slot_syntax.range,
                 "virtual interface pointer type requires a first reference-to-struct parameter");
        return QualType{};
      }
      return QualType(ast_context_->GetVirtualSlotType(pointer));
    }
    case NodeKind::ConstTypeSyntax: {
      auto& const_type_syntax = static_cast<ConstTypeSyntax&>(type_syntax);
      if (!const_type_syntax.QualifiedType || const_type_syntax.QualifiedType->ContainsErrors()) {
        return QualType{};
      }
      const QualType qualified_type = ResolveType(*const_type_syntax.QualifiedType);
      InheritErrors(const_type_syntax, const_type_syntax.QualifiedType.get());
      if (!qualified_type) {
        return QualType{};
      }
      if (qualified_type.IsConstQualified()) {
        Diagnose(const_type_syntax, kErrorDiagnostic, const_type_syntax.range,
                 "duplicate 'const' qualifier on the same object layer");
        return QualType{};
      }
      if (qualified_type.GetTypePtr()->AsReferenceType()) {
        Diagnose(const_type_syntax, kErrorDiagnostic, const_type_syntax.range,
                 "a reference type cannot be const-qualified");
        return QualType{};
      }
      if (!(qualified_type && qualified_type.GetTypePtr()->IsObject())) {
        Diagnose(const_type_syntax, kErrorDiagnostic, const_type_syntax.range,
                 fmt::format("type '{}' cannot be const-qualified", TypeSpelling(qualified_type)));
        return QualType{};
      }
      return qualified_type.WithConst();
    }
    case NodeKind::ReferenceTypeSyntax: {
      auto& reference_type_syntax = static_cast<ReferenceTypeSyntax&>(type_syntax);
      if (!reference_type_syntax.ReferentType || reference_type_syntax.ReferentType->ContainsErrors()) {
        return QualType{};
      }
      const QualType referent_type = ResolveType(*reference_type_syntax.ReferentType);
      InheritErrors(reference_type_syntax, reference_type_syntax.ReferentType.get());
      if (!referent_type) {
        return QualType{};
      }
      if (referent_type.IsConstQualified()) {
        Diagnose(reference_type_syntax, kErrorDiagnostic, reference_type_syntax.range,
                 "reference referent must not be const-qualified");
        return QualType{};
      }
      if (referent_type && referent_type.GetTypePtr()->AsReferenceType()) {
        Diagnose(reference_type_syntax, kErrorDiagnostic, reference_type_syntax.range,
                 "a reference cannot refer to another reference type");
        return QualType{};
      }
      if (!(referent_type && referent_type.GetTypePtr()->IsObject())) {
        Diagnose(reference_type_syntax, kErrorDiagnostic, reference_type_syntax.range,
                 fmt::format("reference referent '{}' is not an object type", TypeSpelling(referent_type)));
        return QualType{};
      }
      return QualType(ast_context_->GetReferenceType(reference_type_syntax.mode, referent_type.GetTypePtr()));
    }
    case NodeKind::ArrayTypeSyntax: {
      auto& array_syntax = static_cast<ArrayTypeSyntax&>(type_syntax);
      if (!array_syntax.Length || !array_syntax.ElementType) {
        return QualType{};
      }

      array_syntax.Length = AnalyzeExpr(std::move(array_syntax.Length), ComptimeIntMode::Preserve);
      InheritErrors(array_syntax, array_syntax.Length.get());
      if (!array_syntax.Length || array_syntax.Length->ContainsErrors()) {
        return QualType{};
      }

      const auto evaluated = EvaluateConstantInteger(*array_syntax.Length, *ast_context_);
      const auto* value = std::get_if<cpp_int>(&evaluated);
      if (!value) {
        const auto& failure = std::get<ConstantIntegerFailure>(evaluated);
        const SourceRange failure_range = failure.expression ? failure.expression->range : array_syntax.Length->range;
        switch (failure.kind) {
          case ConstantIntegerFailureKind::NotInteger:
            Diagnose(
                array_syntax, kErrorDiagnostic, failure_range,
                fmt::format("array length expression must have integer type, not {}",
                            failure.expression ? DescribeExpressionType(failure.expression->type) : "'<unknown>'"));
            break;
          case ConstantIntegerFailureKind::NotConstant:
            Diagnose(array_syntax, kErrorDiagnostic, failure_range,
                     "array length is not a constant integer expression");
            break;
          case ConstantIntegerFailureKind::UnsupportedOperation:
            Diagnose(array_syntax, kErrorDiagnostic, failure_range,
                     "array length constant expression may use only '+', '-', and '*' arithmetic");
            break;
          case ConstantIntegerFailureKind::NotRepresentable:
            Diagnose(array_syntax, kErrorDiagnostic, failure_range,
                     "array length constant expression overflows its integer type");
            break;
        }
        return QualType{};
      }
      if (*value < 0) {
        Diagnose(array_syntax, kErrorDiagnostic, array_syntax.Length->range, "array length cannot be negative");
        return QualType{};
      }
      const auto* usize_type = ast_context_->GetBuiltinType(BuiltinTypeKind::USize);
      const cpp_int maximum = (cpp_int{1} << ast_context_->GetIntegerBitWidth(*usize_type)) - 1;
      if (*value > maximum || *value > std::numeric_limits<ArrayLength>::max()) {
        Diagnose(array_syntax, kErrorDiagnostic, array_syntax.Length->range,
                 "array length is outside the range of 'usize'");
        return QualType{};
      }

      const QualType element_type = ResolveType(*array_syntax.ElementType);
      InheritErrors(array_syntax, array_syntax.ElementType.get());
      if (!element_type) {
        return QualType{};
      }
      if (!ValidateTypeUse(*array_syntax.ElementType, element_type, TypeUseKind::ArrayElement)) {
        return QualType{};
      }
      return QualType(ast_context_->GetArrayType(element_type, value->convert_to<ArrayLength>()));
    }
    default:
      BOOST_ASSERT(false && "unsupported type node");
      return QualType{};
  }
}

bool Sema::ValidateTypeUse(Node& owner, QualType type, TypeUseKind use) {
  BOOST_ASSERT(type);

  if (type.GetTypePtr()->IsVoid() || type.GetTypePtr()->AsFunctionType()) {
    switch (use) {
      case TypeUseKind::Parameter:
        Diagnose(owner, kErrorDiagnostic, owner.range,
                 fmt::format("parameter type '{}' is not an object type", TypeSpelling(type)));
        return false;
      case TypeUseKind::LocalVariable:
      case TypeUseKind::GlobalVariable:
        Diagnose(owner, kErrorDiagnostic, owner.range,
                 fmt::format("variable type '{}' is not an object type", TypeSpelling(type)));
        return false;
      case TypeUseKind::Return:
        if (type.GetTypePtr()->IsVoid()) {
          break;
        }
        Diagnose(owner, kErrorDiagnostic, owner.range,
                 fmt::format("return type '{}' is not an object type", TypeSpelling(type)));
        return false;
      case TypeUseKind::Field:
        break;
      case TypeUseKind::ArrayElement:
        Diagnose(owner, kErrorDiagnostic, owner.range,
                 fmt::format("array element type '{}' is not an object type", TypeSpelling(type)));
        return false;
    }
  }

  if ((use == TypeUseKind::Parameter || use == TypeUseKind::Return) && type.IsConstQualified()) {
    Diagnose(owner, kErrorDiagnostic, owner.range,
             use == TypeUseKind::Parameter ? "by-value parameter type cannot be top-level const-qualified"
                                           : "by-value return type cannot be top-level const-qualified");
    return false;
  }

  if (use == TypeUseKind::Field && !(type && type.GetTypePtr()->IsObject())) {
    Diagnose(owner, kErrorDiagnostic, owner.range,
             fmt::format("field type '{}' is not an object type", TypeSpelling(type)));
    return false;
  }

  if (use == TypeUseKind::ArrayElement && !(type && type.GetTypePtr()->IsObject())) {
    Diagnose(owner, kErrorDiagnostic, owner.range,
             fmt::format("array element type '{}' is not an object type", TypeSpelling(type)));
    return false;
  }

  const ReferenceType* reference_type = (type ? type.GetTypePtr()->AsReferenceType() : nullptr);
  if (!reference_type) {
    return true;
  }

  switch (use) {
    case TypeUseKind::LocalVariable:
      if (reference_type->GetMode() == ReferenceMode::Mut) {
        return true;
      }
      Diagnose(owner, kErrorDiagnostic, owner.range,
               fmt::format("local '{}' reference variables are not currently supported", TypeSpelling(type)));
      return false;
    case TypeUseKind::GlobalVariable:
      Diagnose(owner, kErrorDiagnostic, owner.range, "global reference variables are not currently supported");
      return false;
    case TypeUseKind::Field:
      BOOST_ASSERT(false && "reference fields are rejected as non-object fields above");
      return false;
    case TypeUseKind::ArrayElement:
      BOOST_ASSERT(false && "reference array elements are rejected as non-object elements above");
      return false;
    case TypeUseKind::Parameter:
    case TypeUseKind::Return:
      return true;
  }
  BOOST_ASSERT(false && "unsupported type use");
  return false;
}

bool Sema::ValidateAbstractObjectType(Node& owner, QualType type, TypeUseKind use) {
  if (!type) {
    return true;
  }

  if (type.GetTypePtr()->GetKind() == TypeKind::Struct) {
    const StructDecl* structure = static_cast<const StructType*>(type.GetTypePtr())->GetDeclaration();
    if (!structure || !structure->is_abstract) {
      return true;
    }

    std::string message;
    switch (use) {
      case TypeUseKind::LocalVariable:
      case TypeUseKind::GlobalVariable:
        message = fmt::format("variable type '{}' is abstract", structure->name);
        break;
      case TypeUseKind::Field:
        message = fmt::format("field type '{}' is abstract", structure->name);
        break;
      case TypeUseKind::Parameter:
        message = fmt::format("by-value parameter type '{}' is abstract", structure->name);
        break;
      case TypeUseKind::Return:
        message = fmt::format("by-value return type '{}' is abstract", structure->name);
        break;
      case TypeUseKind::ArrayElement:
        message = fmt::format("array element type '{}' is abstract", structure->name);
        break;
    }
    Diagnose(owner, kErrorDiagnostic, owner.range, std::move(message));
    return false;
  }

  return true;
}

bool Sema::ValidateAbstractTypeUse(TypeSyntax& type_syntax, QualType type, TypeUseKind use) {
  if (!type) {
    return true;
  }
  if (!ValidateAbstractObjectType(type_syntax, type, use)) {
    return false;
  }
  return ValidateAbstractUsesInContainedFunctionTypes(type_syntax, type);
}

bool Sema::ValidateAbstractUsesInContainedFunctionTypes(TypeSyntax& type_syntax, QualType type) {
  BOOST_ASSERT(type);

  switch (type_syntax.GetKind()) {
    case NodeKind::BuiltinTypeSyntax:
    case NodeKind::NamedTypeSyntax:
      return true;
    case NodeKind::PointerTypeSyntax: {
      auto& pointer_syntax = static_cast<PointerTypeSyntax&>(type_syntax);
      BOOST_ASSERT(type.GetTypePtr()->GetKind() == TypeKind::Pointer);
      if (!pointer_syntax.Pointee) {
        return true;
      }
      const QualType pointee = static_cast<const PointerType*>(type.GetTypePtr())->GetPointee();
      const bool valid = ValidateAbstractUsesInContainedFunctionTypes(*pointer_syntax.Pointee, pointee);
      InheritErrors(pointer_syntax, pointer_syntax.Pointee.get());
      return valid;
    }
    case NodeKind::FunctionTypeSyntax: {
      auto& function_syntax = static_cast<FunctionTypeSyntax&>(type_syntax);
      BOOST_ASSERT(type.GetTypePtr()->GetKind() == TypeKind::Function);
      const auto& function_type = static_cast<const FunctionType&>(*type.GetTypePtr());
      const auto& parameter_types = function_type.GetParameterTypes();
      BOOST_ASSERT(parameter_types.size() == function_syntax.ParameterTypes.size());

      bool valid = true;
      for (std::size_t index = 0; index < function_syntax.ParameterTypes.size(); ++index) {
        const auto& parameter_syntax = function_syntax.ParameterTypes[index];
        if (!parameter_syntax) {
          continue;
        }
        if (!ValidateAbstractTypeUse(*parameter_syntax, QualType(parameter_types[index]), TypeUseKind::Parameter)) {
          valid = false;
        }
        InheritErrors(function_syntax, parameter_syntax.get());
      }

      if (function_syntax.ReturnType &&
          !ValidateAbstractTypeUse(*function_syntax.ReturnType, QualType(function_type.GetReturnType()),
                                   TypeUseKind::Return)) {
        valid = false;
      }
      InheritErrors(function_syntax, function_syntax.ReturnType.get());
      return valid;
    }
    case NodeKind::VirtualSlotTypeSyntax: {
      auto& virtual_slot_syntax = static_cast<VirtualSlotTypeSyntax&>(type_syntax);
      BOOST_ASSERT(type.GetTypePtr()->GetKind() == TypeKind::VirtualSlot);
      if (!virtual_slot_syntax.FunctionPointer) {
        return true;
      }
      const auto* virtual_slot_type = static_cast<const VirtualSlotType*>(type.GetTypePtr());
      const bool valid = ValidateAbstractUsesInContainedFunctionTypes(
          *virtual_slot_syntax.FunctionPointer, QualType(virtual_slot_type->GetEntryPointerType()));
      InheritErrors(virtual_slot_syntax, virtual_slot_syntax.FunctionPointer.get());
      return valid;
    }
    case NodeKind::ConstTypeSyntax: {
      auto& const_syntax = static_cast<ConstTypeSyntax&>(type_syntax);
      if (!const_syntax.QualifiedType) {
        return true;
      }
      const bool valid = ValidateAbstractUsesInContainedFunctionTypes(*const_syntax.QualifiedType, type.WithoutConst());
      InheritErrors(const_syntax, const_syntax.QualifiedType.get());
      return valid;
    }
    case NodeKind::ReferenceTypeSyntax: {
      auto& reference_syntax = static_cast<ReferenceTypeSyntax&>(type_syntax);
      BOOST_ASSERT(type.GetTypePtr()->GetKind() == TypeKind::Reference);
      if (!reference_syntax.ReferentType) {
        return true;
      }
      const auto* reference_type = static_cast<const ReferenceType*>(type.GetTypePtr());
      const bool valid = ValidateAbstractUsesInContainedFunctionTypes(*reference_syntax.ReferentType,
                                                                      QualType(reference_type->GetReferentType()));
      InheritErrors(reference_syntax, reference_syntax.ReferentType.get());
      return valid;
    }
    case NodeKind::ArrayTypeSyntax: {
      auto& array_syntax = static_cast<ArrayTypeSyntax&>(type_syntax);
      BOOST_ASSERT(type.GetTypePtr()->GetKind() == TypeKind::Array);
      if (!array_syntax.ElementType) {
        return true;
      }
      const auto* array_type = static_cast<const ArrayType*>(type.GetTypePtr());
      const bool valid =
          ValidateAbstractTypeUse(*array_syntax.ElementType, array_type->GetElementType(), TypeUseKind::ArrayElement);
      InheritErrors(array_syntax, array_syntax.ElementType.get());
      return valid;
    }
    default:
      BOOST_ASSERT(false && "unsupported type node");
      return true;
  }
}

void Sema::Diagnose(Node& owner, DiagnosticSeverity severity, const SourceRange& range, std::string message) {
  if (severity == kErrorDiagnostic) {
    owner.contains_errors = true;
  }
  EmitDiagnostic(severity, range, std::move(message));
}

void Sema::EmitDiagnostic(DiagnosticSeverity severity, const SourceRange& range, std::string message) {
  std::filesystem::path path;
  int line = 0;
  int column = 0;
  std::string line_source;
  int size = 0;

  const SourceLocation& begin = range.begin;
  if (begin.file >= 0 && begin.file < static_cast<int>(sources_->size())) {
    const Source& source = (*sources_)[begin.file];
    path = source.path;
    line = begin.line;
    column = begin.column;
    line_source = LineSource(source, begin.pos);

    if (range.end.IsValid() && range.end.file == begin.file && range.end.line == begin.line &&
        range.end.pos > begin.pos) {
      size = range.end.pos - begin.pos;
    }
  }

  diagnostic_engine_->Add(severity, std::move(path), line, column, std::move(message), std::move(line_source), size);
}

void Sema::DiagnoseConflict(Node& current_owner, const SourceRange& current_range, const std::string& message,
                            const SourceRange& conflicting_range, const char* note_message) {
  Diagnose(current_owner, kErrorDiagnostic, {current_range.begin, current_range.begin}, message);
  EmitDiagnostic(kNoteDiagnostic, {conflicting_range.begin, conflicting_range.begin}, note_message);
}

}  // namespace cw
