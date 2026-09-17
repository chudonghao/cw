/// \file DefiniteInitialization.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <vector>

#include "ABI.h"
#include "CFG.h"

namespace cw {

/// \brief Kinds of stable findings produced by definite-initialization analysis.
enum class DefiniteInitializationFindingKind {
  UninitializedRead,
  RepeatedInitialization,
  OutOfOrderInitialization,
  OutOfOrderSubobjectInitialization,
  ConflictingStates,
  UninitializedResult,
};

/// \brief One source-located definite-initialization finding.
///
/// Findings only describe analysis results. Applying diagnostics and marking the
/// Semantic AST are responsibilities of the caller.
struct DefiniteInitializationFinding {
  DefiniteInitializationFindingKind kind{};
  const Node* owner{};                ///< Non-owning AST node that locates the finding.
  SourceRange range{};                ///< Preferred source range for the diagnostic.
  const VarDecl* declaration{};       ///< Non-owning declaration whose state caused the finding.
  const FunctionDecl* this_owner{};   ///< Non-owning constructor owning a tracked `this` root.
  std::size_t program_point{};        ///< Stable structural execution point used for ordering.
  std::size_t intra_program_order{};  ///< Stable diagnostic order inside one source-level CFG region.
};

/// \brief Performs fixed-point definite-initialization analysis over an execution-body CFG.
class DefiniteInitializationAnalysis {
 public:
  /// \brief Solves the CFG and returns stable findings in program-point order.
  ///
  /// The analysis neither emits diagnostics nor mutates the Semantic AST.
  static std::vector<DefiniteInitializationFinding> Run(const FunctionDecl& function, const CFG& cfg, ABIKind abi);
  /// \brief Analyzes ordered global initialization without ending global object lifetimes at its exit.
  static std::vector<DefiniteInitializationFinding> Run(const TranslationUnitDecl& translation_unit, const CFG& cfg,
                                                        ABIKind abi);
};

}  // namespace cw
