/// \file SemaConstant.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "SemaConstant.h"

#include "ASTContext.h"
#include "ast.h"

namespace cw::sema_detail {

namespace {

using boost::multiprecision::cpp_int;

bool FitsType(const cpp_int& value, QualType type, const ASTContext& ast_context) {
  if (!type || type.GetTypePtr()->GetKind() == TypeKind::ComptimeInt) {
    return true;
  }
  const BuiltinType* integer = type.GetTypePtr()->AsBuiltinType();
  if (!integer || !integer->IsInteger()) {
    return false;
  }
  const unsigned width = ast_context.GetIntegerBitWidth(*integer);
  if (integer->IsSignedInteger()) {
    const cpp_int boundary = cpp_int{1} << (width - 1);
    return value >= -boundary && value < boundary;
  }
  return value >= 0 && value < (cpp_int{1} << width);
}

ConstantIntegerResult Failure(ConstantIntegerFailureKind kind, const Expr& expression) {
  return ConstantIntegerFailure{kind, &expression};
}

ConstantIntegerResult Evaluate(const Expr& expression, const ASTContext& ast_context) {
  switch (expression.GetKind()) {
    case NodeKind::IntegerLiteral:
      return static_cast<const IntegerLiteral&>(expression).value;
    case NodeKind::ParenExpr: {
      const auto& parentheses = static_cast<const ParenExpr&>(expression);
      if (!parentheses.SubExpr) {
        return Failure(ConstantIntegerFailureKind::NotConstant, expression);
      }
      return Evaluate(*parentheses.SubExpr, ast_context);
    }
    case NodeKind::UnaryOperator: {
      const auto& unary = static_cast<const UnaryOperator&>(expression);
      if (!unary.Operand) {
        return Failure(ConstantIntegerFailureKind::NotConstant, expression);
      }
      if (unary.op != expr::plus && unary.op != expr::minus) {
        return Failure(ConstantIntegerFailureKind::UnsupportedOperation, expression);
      }
      auto operand = Evaluate(*unary.Operand, ast_context);
      if (const auto* failure = std::get_if<ConstantIntegerFailure>(&operand)) {
        return *failure;
      }
      cpp_int value = std::get<cpp_int>(std::move(operand));
      if (unary.op == expr::minus) {
        value = -value;
      }
      if (!FitsType(value, expression.type, ast_context)) {
        return Failure(ConstantIntegerFailureKind::NotRepresentable, expression);
      }
      return value;
    }
    case NodeKind::BinaryOperator: {
      const auto& binary = static_cast<const BinaryOperator&>(expression);
      if (!binary.LHS || !binary.RHS) {
        return Failure(ConstantIntegerFailureKind::NotConstant, expression);
      }
      if (binary.op != expr::plus && binary.op != expr::minus && binary.op != expr::star) {
        return Failure(ConstantIntegerFailureKind::UnsupportedOperation, expression);
      }
      auto left = Evaluate(*binary.LHS, ast_context);
      if (const auto* failure = std::get_if<ConstantIntegerFailure>(&left)) {
        return *failure;
      }
      auto right = Evaluate(*binary.RHS, ast_context);
      if (const auto* failure = std::get_if<ConstantIntegerFailure>(&right)) {
        return *failure;
      }
      // Compute exactly before checking the typed result; host overflow must not affect folding.
      cpp_int value;
      if (binary.op == expr::plus) {
        value = std::get<cpp_int>(left) + std::get<cpp_int>(right);
      } else if (binary.op == expr::minus) {
        value = std::get<cpp_int>(left) - std::get<cpp_int>(right);
      } else {
        value = std::get<cpp_int>(left) * std::get<cpp_int>(right);
      }
      if (!FitsType(value, expression.type, ast_context)) {
        return Failure(ConstantIntegerFailureKind::NotRepresentable, expression);
      }
      return value;
    }
    case NodeKind::ImplicitCastExpr: {
      const auto& cast = static_cast<const ImplicitCastExpr&>(expression);
      if (!cast.SubExpr) {
        return Failure(ConstantIntegerFailureKind::NotConstant, expression);
      }
      switch (cast.conversion_kind) {
        case ImplicitConversionKind::Identity:
        case ImplicitConversionKind::LValueToRValue:
        case ImplicitConversionKind::ComptimeIntegerMaterialization:
        case ImplicitConversionKind::IntegerToInteger:
          break;
        default:
          return Failure(ConstantIntegerFailureKind::UnsupportedOperation, expression);
      }
      auto result = Evaluate(*cast.SubExpr, ast_context);
      if (const auto* failure = std::get_if<ConstantIntegerFailure>(&result)) {
        return *failure;
      }
      const cpp_int& value = std::get<cpp_int>(result);
      if (!FitsType(value, expression.type, ast_context)) {
        return Failure(ConstantIntegerFailureKind::NotRepresentable, expression);
      }
      return value;
    }
    default:
      if (expression.type &&
          (!expression.type.GetTypePtr()->AsBuiltinType() ||
           !expression.type.GetTypePtr()->AsBuiltinType()->IsInteger()) &&
          expression.type.GetTypePtr()->GetKind() != TypeKind::ComptimeInt) {
        return Failure(ConstantIntegerFailureKind::NotInteger, expression);
      }
      return Failure(ConstantIntegerFailureKind::NotConstant, expression);
  }
}

}  // namespace

ConstantIntegerResult EvaluateConstantInteger(const Expr& expression, const ASTContext& ast_context) {
  return Evaluate(expression, ast_context);
}

}  // namespace cw::sema_detail
