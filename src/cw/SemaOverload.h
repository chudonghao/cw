/// \file SemaOverload.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <variant>
#include <vector>

#include "SemaConversion.h"

namespace cw::sema_detail {

/// \brief A candidate's full arity mismatch, including any prepared receiver.
struct CandidateArityFailure {
  std::size_t required{};  ///< Number of parameters.
  std::size_t provided{};  ///< Number of prepared arguments.
};

/// \brief The first unavailable conversion in argument order.
struct CandidateArgumentFailure {
  std::size_t index{};          ///< Zero-based index in the full argument list.
  ConversionFailure failure{};  ///< Conversion failure facts without diagnostic presentation.
};

using CandidateFailure = std::variant<CandidateArityFailure, CandidateArgumentFailure>;
using MatchArgumentsResult = std::variant<std::vector<ConversionSequence>, CandidateFailure>;

/// \brief An unavailable declaration and its call-specific failure.
struct CandidateFailureRecord {
  const FunctionDecl* target{};  ///< Borrowed declaration supplied by the caller.
  CandidateFailure failure{};    ///< Arity mismatch or first failed argument conversion.
};

/// \brief A unique winner and its conversions awaiting completion by the caller.
struct SelectedOverload {
  const FunctionDecl* target{};                 ///< Borrowed declaration better than every other viable candidate.
  std::vector<ConversionSequence> conversions;  ///< Owned matches in full parameter order.
};

/// \brief Failure facts for all supplied declarations, in input order.
struct NoViableOverload {
  std::vector<CandidateFailureRecord> candidates;  ///< Empty when no declarations were supplied.
};

/// \brief All viable declarations when none is better than every other one.
struct AmbiguousOverload {
  std::vector<const FunctionDecl*> candidates;  ///< Borrowed declarations in input order, including dominated ones.
};

using OverloadResult = std::variant<SelectedOverload, NoViableOverload, AmbiguousOverload>;

/// \brief Matches a known signature without completing conversions, mutating AST, or issuing diagnostics.
MatchArgumentsResult MatchArguments(const std::vector<ConversionSource>& arguments,
                                    const std::vector<const Type*>& parameter_types, ASTContext& ast_context,
                                    const SymbolTable& symbol_table);

/// \brief Matches and orders caller-selected valid function declarations without committing a call.
OverloadResult ResolveOverload(const std::vector<ConversionSource>& arguments,
                               const std::vector<const FunctionDecl*>& functions, ASTContext& ast_context,
                               const SymbolTable& symbol_table);

}  // namespace cw::sema_detail
