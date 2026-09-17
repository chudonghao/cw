/// \file CFGBuilder.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <memory>
#include <unordered_map>
#include <vector>

#include "ABI.h"
#include "CFG.h"

namespace cw {

/// \brief Builds a source-level CFG from a type-complete Semantic AST.
///
/// The builder does not mutate the AST and does not perform data-flow analysis.
/// Build() returns null for a function declaration without a body.
class CFGBuilder {
  using BlockList = std::vector<CFGBlock*>;

  struct LoopContext {
    CFGBlock* continue_target;
    CFGBlock* break_target;
    std::size_t outer_scope_depth;
  };

  const FunctionDecl* function_;  ///< Null while building global initialization.
  const ABIKind abi_;
  std::unique_ptr<CFG> cfg_;
  std::vector<const CompoundStmt*> scope_stack_;
  std::vector<LoopContext> loop_stack_;
  std::unordered_map<const CFGBlock*, const Node*> result_exit_locations_;
  std::unordered_map<const CFGBlock*, std::size_t> result_exit_program_points_;
  std::size_t initializer_block_depth_{};

 public:
  /// \brief Builds the CFG for one function definition.
  static std::unique_ptr<CFG> Build(const FunctionDecl& function, ABIKind abi);
  /// \brief Builds one CFG for the translation unit's ordered global initialization.
  static std::unique_ptr<CFG> Build(const TranslationUnitDecl& translation_unit, ABIKind abi);

 private:
  CFGBuilder(const FunctionDecl* function, ABIKind abi);

  std::unique_ptr<CFG> BuildFunction();
  std::unique_ptr<CFG> BuildGlobals(const TranslationUnitDecl& translation_unit);

  CFGBlock* BuildCompound(const CompoundStmt& statement, CFGBlock& current, bool emit_normal_scope_exit = true);
  BlockList BuildResultCompound(const CompoundStmt& statement, CFGBlock& current, bool emit_normal_scope_exit);
  BlockList BuildResultIf(const IfStmt& statement, CFGBlock& current);
  CFGBlock* BuildStatement(const Stmt& statement, CFGBlock& current);
  CFGBlock* BuildIf(const IfStmt& statement, CFGBlock& current);
  CFGBlock* BuildWhile(const WhileStmt& statement, CFGBlock& current);
  CFGBlock* BuildReturn(const ReturnStmt& statement, CFGBlock& current);
  CFGBlock* BuildVarGroup(const VarGroupDecl& declaration, CFGBlock& current);

  CFGBlock* BuildExpression(const Expr& expression, CFGBlock& current,
                            CFGExpressionContext context = CFGExpressionContext::Ordinary);
  CFGBlock* BuildGenericExpression(const Expr& expression, CFGBlock& current, CFGExpressionContext context);
  CFGBlock* BuildConditionalExpression(const ConditionalOperator& expression, CFGBlock& current,
                                       CFGExpressionContext context);
  CFGBlock* BuildLogicalExpression(const BinaryOperator& expression, CFGBlock& current);
  CFGBlock* BuildSimpleAssignment(const BinaryOperator& expression, CFGBlock& current);
  CFGBlock* BuildArrayAssignment(const ArrayAssignmentExpr& expression, CFGBlock& current);
  CFGBlock* BuildArrayValue(const ArrayValueExpr& expression, CFGBlock& current, CFGExpressionContext context);
  CFGBlock* BuildAssignmentOperatorCall(const OperatorCallExpr& expression, CFGBlock& current);
  CFGBlock* BuildInitializationExpression(const InitializationExpr& expression, CFGBlock& current);
  CFGBlock* BuildImplicitResultInitializationExpression(const ImplicitResultInitializationExpr& expression,
                                                        CFGBlock& current);

  void EmitScopeExits(CFGBlock& block, std::size_t outer_scope_depth);
  void EmitFunctionExit(CFGBlock& block, const Node& exit_location);
  void RecordResultExit(CFGBlock& block, const Node& location);
  const Node& ResultExitLocation(const CFGBlock& block, const CompoundStmt& fallback) const;
  std::size_t ResultExitProgramPoint(const CFGBlock& block) const;
  bool HasReturnObject() const;
};

}  // namespace cw
