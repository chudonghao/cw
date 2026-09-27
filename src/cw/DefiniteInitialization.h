/// \file DefiniteInitialization.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <vector>

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

/// \brief Stable diagnostics and constructor completion boundaries, without AST mutation.
/// Delegating constructors update initialization state but report no local completion boundaries.
struct DefiniteInitializationResult {
  std::vector<DefiniteInitializationFinding> findings;
  std::vector<const ExprStmt*> this_initialization_completions;
  bool this_complete_at_entry{};
};

/// \brief Performs fixed-point definite-initialization analysis over an execution-body CFG.
class DefiniteInitializationAnalysis {
 public:
  /// \brief Solves the CFG and returns stable diagnostics and constructor completion boundaries.
  ///
  /// The analysis neither emits diagnostics nor mutates the Semantic AST.
  static DefiniteInitializationResult Run(const FunctionDecl& function, const CFG& cfg);
  /// \brief Analyzes ordered global initialization without ending global object lifetimes at its exit.
  static DefiniteInitializationResult Run(const TranslationUnitDecl& translation_unit, const CFG& cfg);
};

}  // namespace cw
