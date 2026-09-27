/// \file SemaConstant.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "SemaConstant.h"

#include "ASTContext.h"
#include "ast.h"

namespace cw::sema_detail {

namespace {

bool ConvertToType(llvm::APSInt& value, QualType type, const ASTContext& ast_context) {
  if (!type || type.GetTypePtr()->GetKind() == TypeKind::ComptimeInt) {
    return true;
  }
  const BuiltinType* integer = type.GetTypePtr()->AsBuiltinType();
  if (!integer || !integer->IsInteger()) {
    return false;
  }
  const unsigned width = ast_context.GetIntegerBitWidth(*integer);
  const bool is_signed = integer->IsSignedInteger();
  const bool fits = is_signed ? (value.isSigned() ? value.isSignedIntN(width) : value.isIntN(width - 1))
                              : (value.isNonNegative() && value.isIntN(width));
  if (!fits) {
    return false;
  }
  // Check the value before truncating or changing how its sign bit is interpreted.
  value = value.extOrTrunc(width);
  value.setIsSigned(is_signed);
  return true;
}

void NegateExactInteger(llvm::APSInt& value) {
  // An untyped sign must preserve the mathematical value, including the signed minimum.
  const unsigned width = (value.isSigned() ? value.getSignificantBits() : value.getActiveBits()) + 1;
  value = value.extOrTrunc(width);
  value.setIsSigned(true);
  value.negate();
  value = value.trunc(value.getSignificantBits());
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
      auto value = std::get<llvm::APSInt>(std::move(operand));
      if (!expression.type || expression.type.GetTypePtr()->GetKind() == TypeKind::ComptimeInt) {
        if (unary.op == expr::minus) {
          NegateExactInteger(value);
        }
        return value;
      }
      if (!ConvertToType(value, expression.type, ast_context)) {
        return Failure(ConstantIntegerFailureKind::NotRepresentable, expression);
      }
      if (unary.op == expr::minus) {
        bool overflow = false;
        const llvm::APInt zero(value.getBitWidth(), 0);
        value = value.isSigned() ? zero.ssub_ov(value, overflow) : zero.usub_ov(value, overflow);
        if (overflow) {
          return Failure(ConstantIntegerFailureKind::NotRepresentable, expression);
        }
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
      const auto* integer = expression.type ? expression.type.GetTypePtr()->AsBuiltinType() : nullptr;
      if (!integer || !integer->IsInteger()) {
        return Failure(ConstantIntegerFailureKind::NotInteger, expression);
      }
      auto left_value = std::get<llvm::APSInt>(std::move(left));
      auto right_value = std::get<llvm::APSInt>(std::move(right));
      if (!ConvertToType(left_value, expression.type, ast_context) ||
          !ConvertToType(right_value, expression.type, ast_context)) {
        return Failure(ConstantIntegerFailureKind::NotRepresentable, expression);
      }
      // Required constant evaluation rejects each overflow before evaluating its parent.
      llvm::APSInt value(left_value.getBitWidth(), left_value.isUnsigned());
      bool overflow = false;
      if (binary.op == expr::plus) {
        value =
            value.isSigned() ? left_value.sadd_ov(right_value, overflow) : left_value.uadd_ov(right_value, overflow);
      } else if (binary.op == expr::minus) {
        value =
            value.isSigned() ? left_value.ssub_ov(right_value, overflow) : left_value.usub_ov(right_value, overflow);
      } else {
        value =
            value.isSigned() ? left_value.smul_ov(right_value, overflow) : left_value.umul_ov(right_value, overflow);
      }
      if (overflow) {
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
      auto value = std::get<llvm::APSInt>(std::move(result));
      if (!ConvertToType(value, expression.type, ast_context)) {
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
