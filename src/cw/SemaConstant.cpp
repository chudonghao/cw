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
    case NodeKind::ScalarValueInitExpr: {
      const auto* type = expression.type.GetTypePtr()->AsBuiltinType();
      if (!type || !type->IsInteger()) {
        return Failure(ConstantIntegerFailureKind::NotInteger, expression);
      }
      return llvm::APSInt(llvm::APInt(ast_context.GetIntegerBitWidth(*type), 0), !type->IsSignedInteger());
    }
    case NodeKind::FunctionalCastExpr: {
      const auto& cast = static_cast<const FunctionalCastExpr&>(expression);
      auto result = Evaluate(*cast.SubExpr, ast_context);
      if (const auto* failure = std::get_if<ConstantIntegerFailure>(&result)) {
        return *failure;
      }
      const auto* target = expression.type.GetTypePtr()->AsBuiltinType();
      if (!target || !target->IsInteger()) {
        return Failure(ConstantIntegerFailureKind::NotInteger, expression);
      }
      auto value = std::get<llvm::APSInt>(std::move(result));
      if (!ConvertToType(value, expression.type, ast_context)) {
        return Failure(ConstantIntegerFailureKind::NotRepresentable, expression);
      }
      return value;
    }
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
      if (unary.op != expr::plus && unary.op != expr::minus && unary.op != expr::tilde) {
        return Failure(ConstantIntegerFailureKind::UnsupportedOperation, expression);
      }
      auto operand = Evaluate(*unary.Operand, ast_context);
      if (const auto* failure = std::get_if<ConstantIntegerFailure>(&operand)) {
        return *failure;
      }
      auto value = std::get<llvm::APSInt>(std::move(operand));
      if (!expression.type || expression.type.GetTypePtr()->GetKind() == TypeKind::ComptimeInt) {
        if (unary.op == expr::tilde) {
          return Failure(ConstantIntegerFailureKind::NotInteger, expression);
        }
        if (unary.op == expr::minus) {
          NegateExactInteger(value);
        }
        return value;
      }
      if (!ConvertToType(value, expression.type, ast_context)) {
        return Failure(ConstantIntegerFailureKind::NotRepresentable, expression);
      }
      if (unary.op == expr::tilde) {
        value.flipAllBits();
      } else if (unary.op == expr::minus) {
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
      if (binary.op != expr::plus && binary.op != expr::minus && binary.op != expr::star && binary.op != expr::slash &&
          binary.op != expr::percent && binary.op != expr::amp && binary.op != expr::pipe && binary.op != expr::caret &&
          binary.op != expr::lessless && binary.op != expr::greatergreater) {
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
          !ConvertToType(right_value, binary.RHS->type, ast_context)) {
        return Failure(ConstantIntegerFailureKind::NotRepresentable, expression);
      }
      if (IsShiftBinaryOperator(binary.op)) {
        // Required constant evaluation checks the original count, without masking or narrowing it.
        if (right_value.isNegative() || right_value.uge(left_value.getBitWidth())) {
          return Failure(ConstantIntegerFailureKind::InvalidShiftCount, *binary.RHS);
        }
        const unsigned count = static_cast<unsigned>(right_value.getZExtValue());
        if (binary.op == expr::lessless) {
          left_value <<= count;
        } else {
          left_value >>= count;
        }
        return left_value;
      }
      if ((binary.op == expr::slash || binary.op == expr::percent) && right_value.isZero()) {
        return Failure(ConstantIntegerFailureKind::ZeroDivisor, *binary.RHS);
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
      } else if (binary.op == expr::star) {
        value =
            value.isSigned() ? left_value.smul_ov(right_value, overflow) : left_value.umul_ov(right_value, overflow);
      } else if (binary.op == expr::slash) {
        value = value.isSigned() ? left_value.sdiv_ov(right_value, overflow) : left_value.udiv(right_value);
      } else if (binary.op == expr::percent) {
        // MIN % -1 is zero even though the corresponding quotient is not representable.
        value = left_value % right_value;
      } else if (binary.op == expr::amp) {
        value = left_value & right_value;
      } else if (binary.op == expr::pipe) {
        value = left_value | right_value;
      } else {
        value = left_value ^ right_value;
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
