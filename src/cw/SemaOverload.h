/// \file SemaOverload.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <variant>
#include <vector>

#include "SemaConversion.h"

namespace cw::sema_detail {

/// \brief A source declaration or a semantic-only signature supplied by the caller.
using OverloadCandidate = std::variant<const FunctionDecl*, const FunctionType*>;

/// \brief Returns the signature used for matching and ordering either candidate kind.
const FunctionType& CandidateType(const OverloadCandidate& candidate);

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

/// \brief An unavailable candidate and its call-specific failure.
struct CandidateFailureRecord {
  OverloadCandidate target{};    ///< Borrowed declaration or signature supplied by the caller.
  CandidateFailure failure{};    ///< Arity mismatch or first failed argument conversion.
};

/// \brief A unique winner and its conversions awaiting completion by the caller.
struct SelectedOverload {
  OverloadCandidate target{};                   ///< Candidate better than every other viable candidate.
  std::vector<ConversionSequence> conversions;  ///< Owned matches in full parameter order.
};

/// \brief Failure facts for all supplied candidates, in input order.
struct NoViableOverload {
  std::vector<CandidateFailureRecord> candidates;  ///< Empty when no candidates were supplied.
};

/// \brief All viable candidates when none is better than every other one.
struct AmbiguousOverload {
  std::vector<OverloadCandidate> candidates;  ///< Candidates in input order, including dominated ones.
};

using OverloadResult = std::variant<SelectedOverload, NoViableOverload, AmbiguousOverload>;

/// \brief Matches a known signature without completing conversions, mutating AST, or issuing diagnostics.
MatchArgumentsResult MatchArguments(const std::vector<ConversionSource>& arguments,
                                    const std::vector<const Type*>& parameter_types, ASTContext& ast_context,
                                    const LookupContext& lookup_context);

/// \brief Matches and orders caller-selected candidates without committing an operation.
OverloadResult ResolveOverload(const std::vector<ConversionSource>& arguments,
                               const std::vector<OverloadCandidate>& candidates, ASTContext& ast_context,
                               const LookupContext& lookup_context);

/// \brief Resolves a call whose candidates are all function declarations.
OverloadResult ResolveOverload(const std::vector<ConversionSource>& arguments,
                               const std::vector<const FunctionDecl*>& functions, ASTContext& ast_context,
                               const LookupContext& lookup_context);

}  // namespace cw::sema_detail
