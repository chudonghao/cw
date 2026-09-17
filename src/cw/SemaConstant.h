/// \file SemaConstant.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <variant>

#include <boost/multiprecision/cpp_int.hpp>

namespace cw {

class ASTContext;
struct Expr;

namespace sema_detail {

enum class ConstantIntegerFailureKind {
  NotInteger,
  NotConstant,
  UnsupportedOperation,
  NotRepresentable,
};

struct ConstantIntegerFailure {
  ConstantIntegerFailureKind kind{ConstantIntegerFailureKind::NotConstant};
  const Expr* expression{};
};

using ConstantIntegerResult = std::variant<boost::multiprecision::cpp_int, ConstantIntegerFailure>;

/// \brief Evaluates the deliberately small integer constant-expression subset.
ConstantIntegerResult EvaluateConstantInteger(const Expr& expression, const ASTContext& ast_context);

}  // namespace sema_detail
}  // namespace cw
