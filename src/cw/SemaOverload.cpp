/// \file SemaOverload.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "SemaOverload.h"

#include <utility>

#include <boost/assert.hpp>

namespace cw::sema_detail {
namespace {

/// \brief A function match retained for comparison during this resolution.
struct ViableCandidate {
  const FunctionDecl* target{};                 ///< Borrowed declaration with a viable match.
  std::vector<ConversionSequence> conversions;  ///< Owned matches without completed object formation.
};

const std::vector<const Type*>& FunctionParameterTypes(const FunctionDecl& declaration) {
  BOOST_ASSERT(declaration.type && declaration.type.GetTypePtr()->AsFunctionType());
  return declaration.type.GetTypePtr()->AsFunctionType()->GetParameterTypes();
}

bool IsBetterCandidate(const std::vector<ConversionSource>& arguments, const ViableCandidate& left,
                       const ViableCandidate& right) {
  const auto& left_parameters = FunctionParameterTypes(*left.target);
  const auto& right_parameters = FunctionParameterTypes(*right.target);
  BOOST_ASSERT(left.conversions.size() == arguments.size() && left_parameters.size() == arguments.size());
  BOOST_ASSERT(right.conversions.size() == arguments.size() && right_parameters.size() == arguments.size());
  // A candidate must be no worse for every argument and better for at least one.
  bool strictly_better = false;
  for (std::size_t index = 0; index < arguments.size(); ++index) {
    switch (CompareConversion(arguments[index].state, QualType(left_parameters[index]), left.conversions[index],
                              QualType(right_parameters[index]), right.conversions[index])) {
      case ConversionComparison::Better:
        strictly_better = true;
        break;
      case ConversionComparison::Worse:
        return false;
      case ConversionComparison::Indistinguishable:
        break;
    }
  }
  return strictly_better;
}

}  // namespace

MatchArgumentsResult MatchArguments(const std::vector<ConversionSource>& arguments,
                                    const std::vector<const Type*>& parameter_types, ASTContext& ast_context,
                                    const SymbolTable& symbol_table) {
  if (parameter_types.size() != arguments.size()) {
    return CandidateFailure{CandidateArityFailure{parameter_types.size(), arguments.size()}};
  }
  std::vector<ConversionSequence> conversions;
  conversions.reserve(arguments.size());
  for (std::size_t index = 0; index < arguments.size(); ++index) {
    auto result = BuildConversion(arguments[index], QualType(parameter_types[index]), ast_context, symbol_table);
    if (const auto* failure = std::get_if<ConversionFailure>(&result)) {
      return CandidateFailure{CandidateArgumentFailure{index, *failure}};
    }
    conversions.push_back(std::get<ConversionSequence>(std::move(result)));
  }
  return conversions;
}

OverloadResult ResolveOverload(const std::vector<ConversionSource>& arguments,
                               const std::vector<const FunctionDecl*>& functions, ASTContext& ast_context,
                               const SymbolTable& symbol_table) {
  // Retain failed matches for diagnostics while collecting candidates eligible for ranking.
  std::vector<ViableCandidate> viable;
  viable.reserve(functions.size());
  NoViableOverload no_viable;
  for (const FunctionDecl* declaration : functions) {
    BOOST_ASSERT(declaration);
    auto match = MatchArguments(arguments, FunctionParameterTypes(*declaration), ast_context, symbol_table);
    if (const auto* failure = std::get_if<CandidateFailure>(&match)) {
      no_viable.candidates.push_back({declaration, *failure});
    } else {
      viable.push_back({declaration, std::get<std::vector<ConversionSequence>>(std::move(match))});
    }
  }
  if (viable.empty()) {
    return no_viable;
  }

  // Indistinguishability is not transitive. Require a winner to beat every
  // other viable candidate rather than depending on a tournament or sorting.
  for (std::size_t index = 0; index < viable.size(); ++index) {
    bool better_than_all = true;
    for (std::size_t other = 0; other < viable.size(); ++other) {
      if (index != other && !IsBetterCandidate(arguments, viable[index], viable[other])) {
        better_than_all = false;
        break;
      }
    }
    if (better_than_all) {
      return SelectedOverload{viable[index].target, std::move(viable[index].conversions)};
    }
  }

  AmbiguousOverload ambiguous;
  ambiguous.candidates.reserve(viable.size());
  for (const auto& candidate : viable) ambiguous.candidates.push_back(candidate.target);
  return ambiguous;
}

}  // namespace cw::sema_detail
