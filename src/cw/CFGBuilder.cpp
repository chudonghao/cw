/// \file CFGBuilder.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "CFGBuilder.h"

#include <algorithm>
#include <utility>
#include <vector>

#include <boost/assert.hpp>

namespace cw {
namespace {

bool IsLogicalOperator(const BinaryOperator& expression) {
  return expression.op == expr::ampamp || expression.op == expr::pipepipe;
}

bool IsAssignmentOperatorCall(const OperatorCallExpr& expression) {
  if (expression.Args.size() != 2 || !expression.Args[0] || !expression.Args[1] || !expression.Callee ||
      expression.Callee->GetKind() != NodeKind::DeclRefExpr) {
    return false;
  }
  const ValueDecl* declaration = static_cast<const DeclRefExpr&>(*expression.Callee).declaration;
  if (!declaration) {
    return false;
  }
  switch (declaration->GetKind()) {
    case NodeKind::FunctionDecl:
    case NodeKind::VirtualFunctionDecl:
      return static_cast<const FunctionDecl*>(declaration)->name == "=";
    default:
      return false;
  }
}

void AppendChild(const std::unique_ptr<Expr>& child, std::vector<const Expr*>& children) {
  if (child) {
    children.push_back(child.get());
  }
}

std::vector<const Expr*> ExpressionChildren(const Expr& expression, ABIKind abi = ABIKind::Itanium) {
  std::vector<const Expr*> children;
  auto append_arguments = [&](const auto& arguments) {
    if (AreArgumentsEvaluatedRightToLeft(abi)) {
      for (auto argument = arguments.rbegin(); argument != arguments.rend(); ++argument)
        AppendChild(*argument, children);
    } else {
      for (const auto& argument : arguments) AppendChild(argument, children);
    }
  };

  switch (expression.GetKind()) {
    case NodeKind::ParenExpr:
      AppendChild(static_cast<const ParenExpr&>(expression).SubExpr, children);
      break;
    case NodeKind::UnaryOperator:
      AppendChild(static_cast<const UnaryOperator&>(expression).Operand, children);
      break;
    case NodeKind::BinaryOperator: {
      const auto& binary = static_cast<const BinaryOperator&>(expression);
      AppendChild(binary.LHS, children);
      AppendChild(binary.RHS, children);
      break;
    }
    case NodeKind::InitializationExpr: {
      const auto& initialization = static_cast<const InitializationExpr&>(expression);
      AppendChild(initialization.Target, children);
      AppendChild(initialization.Source, children);
      break;
    }
    case NodeKind::ImplicitResultInitializationExpr:
      AppendChild(static_cast<const ImplicitResultInitializationExpr&>(expression).Source, children);
      break;
    case NodeKind::ConditionalOperator: {
      const auto& conditional = static_cast<const ConditionalOperator&>(expression);
      AppendChild(conditional.Cond, children);
      AppendChild(conditional.Then, children);
      AppendChild(conditional.Else, children);
      break;
    }
    case NodeKind::MemberExpr:
      AppendChild(static_cast<const MemberExpr&>(expression).Base, children);
      break;
    case NodeKind::BaseSubobjectExpr:
      AppendChild(static_cast<const BaseSubobjectExpr&>(expression).Base, children);
      break;
    case NodeKind::SubscriptExpr: {
      const auto& subscript = static_cast<const SubscriptExpr&>(expression);
      AppendChild(subscript.Base, children);
      AppendChild(subscript.Index, children);
      break;
    }
    case NodeKind::ArrayValueExpr: {
      const auto& array = static_cast<const ArrayValueExpr&>(expression);
      for (const auto& element : array.Elements) AppendChild(element, children);
      break;
    }
    case NodeKind::CallExpr:
    case NodeKind::OperatorCallExpr: {
      const auto& call = static_cast<const CallExpr&>(expression);
      AppendChild(call.Callee, children);
      append_arguments(call.Args);
      break;
    }
    case NodeKind::ReceiverCallExpr: {
      const auto& call = static_cast<const ReceiverCallExpr&>(expression);
      // Sema has already made arrow dereference part of the receiver subtree.
      AppendChild(call.Callee, children);
      if (!AreArgumentsEvaluatedRightToLeft(abi)) {
        AppendChild(call.Receiver, children);
      }
      append_arguments(call.Args);
      if (AreArgumentsEvaluatedRightToLeft(abi)) {
        AppendChild(call.Receiver, children);
      }
      break;
    }
    case NodeKind::ConstructionExpr: {
      const auto& construction = static_cast<const ConstructionExpr&>(expression);
      AppendChild(construction.TargetAddress, children);
      append_arguments(construction.Args);
      break;
    }
    case NodeKind::ArrayConstructionExpr:
      AppendChild(static_cast<const ArrayConstructionExpr&>(expression).Source, children);
      break;
    case NodeKind::ArrayAssignmentExpr: {
      const auto& assignment = static_cast<const ArrayAssignmentExpr&>(expression);
      AppendChild(assignment.LHS, children);
      AppendChild(assignment.RHS, children);
      break;
    }
    case NodeKind::DestructorCallExpr: {
      const auto& call = static_cast<const DestructorCallExpr&>(expression);
      AppendChild(call.TargetAddress, children);
      AppendChild(call.Callee, children);
      for (const auto& argument : call.Args) AppendChild(argument, children);
      break;
    }
    case NodeKind::ImplicitCastExpr:
      AppendChild(static_cast<const ImplicitCastExpr&>(expression).SubExpr, children);
      break;
    case NodeKind::MaterializeTemporaryExpr:
      AppendChild(static_cast<const MaterializeTemporaryExpr&>(expression).SubExpr, children);
      break;
    case NodeKind::ImplicitOverloadSetSelectionExpr:
      // The retained source subtree describes name lookup and overload
      // selection; it is not a separate runtime evaluation.
      break;
    default:
      break;
  }

  return children;
}

bool ContainsControlFlow(const Expr& expression) {
  if (expression.GetKind() == NodeKind::ConditionalOperator) {
    return true;
  }
  if (expression.GetKind() == NodeKind::BinaryOperator &&
      IsLogicalOperator(static_cast<const BinaryOperator&>(expression))) {
    return true;
  }

  for (const Expr* child : ExpressionChildren(expression)) {
    if (ContainsControlFlow(*child)) {
      return true;
    }
  }
  return false;
}

bool RequiresSeparateCFGEvent(const Expr& expression) { return ContainsControlFlow(expression); }

}  // namespace

std::unique_ptr<CFG> CFGBuilder::Build(const FunctionDecl& function, ABIKind abi) {
  if (!function.Body) {
    return nullptr;
  }
  return CFGBuilder(&function, abi).BuildFunction();
}

std::unique_ptr<CFG> CFGBuilder::Build(const TranslationUnitDecl& translation_unit, ABIKind abi) {
  return CFGBuilder(nullptr, abi).BuildGlobals(translation_unit);
}

CFGBuilder::CFGBuilder(const FunctionDecl* function, ABIKind abi)
    : function_(function), abi_(abi), cfg_(std::make_unique<CFG>()) {}

std::unique_ptr<CFG> CFGBuilder::BuildFunction() {
  BOOST_ASSERT(function_);
  CFGBlock& body_entry = cfg_->CreateBlock();
  cfg_->Connect(cfg_->GetEntry(), body_entry, CFGEdgeKind::Unconditional);

  for (const auto& parameter : function_->ParmVars) {
    if (parameter) {
      body_entry.EmplaceElement<CFGDeclarationElement>(*parameter, CFGDeclarationForm::Parameter);
    }
  }
  if (HasReturnObject()) {
    body_entry.EmplaceElement<CFGDeclarationElement>(*function_->ReturnVar, CFGDeclarationForm::ReturnObject);
  }

  const bool has_return_object = HasReturnObject();
  const bool needs_result_check = has_return_object || function_->GetKind() == NodeKind::ConstructorDecl;
  BlockList natural_exits;
  if (has_return_object) {
    natural_exits = BuildResultCompound(*function_->Body, body_entry, false);
  } else if (CFGBlock* natural_exit = BuildCompound(*function_->Body, body_entry, false)) {
    natural_exits.push_back(natural_exit);
  }

  for (CFGBlock* natural_exit : natural_exits) {
    if (needs_result_check) {
      if (has_return_object) {
        natural_exit->EmplaceElementAt<CFGResultCheckElement>(ResultExitProgramPoint(*natural_exit), *function_,
                                                              ResultExitLocation(*natural_exit, *function_->Body));
      } else {
        natural_exit->EmplaceElement<CFGResultCheckElement>(*function_, *function_->Body);
      }
    }
    natural_exit->EmplaceElement<CFGScopeExitElement>(*function_->Body);
    natural_exit->EmplaceElement<CFGScopeExitElement>(*function_);
    cfg_->Connect(*natural_exit, cfg_->GetExit(), CFGEdgeKind::Unconditional);
  }

  return std::move(cfg_);
}

std::unique_ptr<CFG> CFGBuilder::BuildGlobals(const TranslationUnitDecl& translation_unit) {
  CFGBlock* current = &cfg_->CreateBlock();
  cfg_->Connect(cfg_->GetEntry(), *current, CFGEdgeKind::Unconditional);
  for (const auto& declaration : translation_unit.Decls) {
    if (!current) {
      break;
    }
    if (!declaration || declaration->GetKind() != NodeKind::VarGroupDecl) {
      continue;
    }
    current = BuildVarGroup(static_cast<const VarGroupDecl&>(*declaration), *current);
  }
  // Completing initialization does not end the lifetime of any global object.
  if (current) {
    cfg_->Connect(*current, cfg_->GetExit(), CFGEdgeKind::Unconditional);
  }
  return std::move(cfg_);
}

CFGBlock* CFGBuilder::BuildCompound(const CompoundStmt& statement, CFGBlock& current, bool emit_normal_scope_exit) {
  scope_stack_.push_back(&statement);
  CFGBlock* block = &current;

  for (const auto& child : statement.Stmts) {
    if (!child) {
      continue;
    }
    if (!block) {
      block = &cfg_->CreateBlock();
    }
    block = BuildStatement(*child, *block);
  }
  for (const auto& tail : statement.TailExprs) {
    if (!tail) {
      continue;
    }
    if (!block) {
      block = &cfg_->CreateBlock();
    }
    block = BuildExpression(*tail, *block);
  }

  if (block && emit_normal_scope_exit) {
    block->EmplaceElement<CFGScopeExitElement>(statement);
  }
  scope_stack_.pop_back();
  return block;
}

CFGBuilder::BlockList CFGBuilder::BuildResultCompound(const CompoundStmt& statement, CFGBlock& current,
                                                      bool emit_normal_scope_exit) {
  scope_stack_.push_back(&statement);
  CFGBlock* block = &current;

  std::size_t statement_count = statement.Stmts.size();
  while (statement_count != 0 && !statement.Stmts[statement_count - 1]) --statement_count;
  bool has_tail_expression = false;
  for (const auto& tail : statement.TailExprs) {
    if (tail) {
      has_tail_expression = true;
      break;
    }
  }
  // Preserve a terminal if's separate exits so result initialization is checked on each branch.
  const bool has_final_if = !has_tail_expression && statement_count != 0 &&
                            statement.Stmts[statement_count - 1]->GetKind() == NodeKind::IfStmt;

  for (std::size_t index = 0; index < statement_count; ++index) {
    const auto& child = statement.Stmts[index];
    if (!child) {
      continue;
    }
    if (!block) {
      block = &cfg_->CreateBlock();
    }
    if (has_final_if && index + 1 == statement_count) {
      BlockList exits = BuildResultIf(static_cast<const IfStmt&>(*child), *block);
      if (emit_normal_scope_exit) {
        for (CFGBlock* exit : exits) exit->EmplaceElement<CFGScopeExitElement>(statement);
      }
      scope_stack_.pop_back();
      return exits;
    }
    block = BuildStatement(*child, *block);
  }

  for (const auto& tail : statement.TailExprs) {
    if (!tail) {
      continue;
    }
    if (!block) {
      block = &cfg_->CreateBlock();
    }
    block = BuildExpression(*tail, *block);
  }

  BlockList exits;
  if (block) {
    if (emit_normal_scope_exit) {
      block->EmplaceElement<CFGScopeExitElement>(statement);
    }
    RecordResultExit(*block, statement);
    exits.push_back(block);
  }
  scope_stack_.pop_back();
  return exits;
}

CFGBuilder::BlockList CFGBuilder::BuildResultIf(const IfStmt& statement, CFGBlock& current) {
  CFGBlock* condition = &current;
  if (statement.Cond) {
    condition = BuildExpression(*statement.Cond, *condition);
  }
  condition->SetTerminator(statement);

  CFGBlock& then_entry = cfg_->CreateBlock();
  CFGBlock& else_entry = cfg_->CreateBlock();
  cfg_->Connect(*condition, then_entry, CFGEdgeKind::True);
  cfg_->Connect(*condition, else_entry, CFGEdgeKind::False);

  BlockList exits;
  if (statement.Then) {
    BlockList then_exits = BuildResultCompound(*statement.Then, then_entry, true);
    exits.insert(exits.end(), then_exits.begin(), then_exits.end());
  } else {
    RecordResultExit(then_entry, statement);
    exits.push_back(&then_entry);
  }
  if (statement.Else) {
    BlockList else_exits = BuildResultCompound(*statement.Else, else_entry, true);
    exits.insert(exits.end(), else_exits.begin(), else_exits.end());
  } else {
    RecordResultExit(else_entry, statement);
    exits.push_back(&else_entry);
  }
  return exits;
}

CFGBlock* CFGBuilder::BuildStatement(const Stmt& statement, CFGBlock& current) {
  switch (statement.GetKind()) {
    case NodeKind::CompoundStmt:
      return BuildCompound(static_cast<const CompoundStmt&>(statement), current);
    case NodeKind::ExprStmt: {
      const auto& expression_statement = static_cast<const ExprStmt&>(statement);
      if (!expression_statement.Expr) {
        return &current;
      }
      return BuildExpression(*expression_statement.Expr, current);
    }
    case NodeKind::DeclStmt: {
      const auto& declaration_statement = static_cast<const DeclStmt&>(statement);
      if (declaration_statement.Decl && declaration_statement.Decl->GetKind() == NodeKind::VarGroupDecl) {
        return BuildVarGroup(static_cast<const VarGroupDecl&>(*declaration_statement.Decl), current);
      }
      return &current;
    }
    case NodeKind::IfStmt:
      return BuildIf(static_cast<const IfStmt&>(statement), current);
    case NodeKind::WhileStmt:
      return BuildWhile(static_cast<const WhileStmt&>(statement), current);
    case NodeKind::BreakStmt: {
      current.SetTerminator(statement);
      if (loop_stack_.empty()) {
        return nullptr;
      }
      const LoopContext& loop = loop_stack_.back();
      EmitScopeExits(current, loop.outer_scope_depth);
      cfg_->Connect(current, *loop.break_target, CFGEdgeKind::Unconditional);
      return nullptr;
    }
    case NodeKind::ContinueStmt: {
      current.SetTerminator(statement);
      if (loop_stack_.empty()) {
        return nullptr;
      }
      const LoopContext& loop = loop_stack_.back();
      EmitScopeExits(current, loop.outer_scope_depth);
      cfg_->Connect(current, *loop.continue_target, CFGEdgeKind::Unconditional);
      return nullptr;
    }
    case NodeKind::ReturnStmt:
      return BuildReturn(static_cast<const ReturnStmt&>(statement), current);
    default:
      BOOST_ASSERT(false && "unsupported statement node");
      return &current;
  }
}

CFGBlock* CFGBuilder::BuildIf(const IfStmt& statement, CFGBlock& current) {
  CFGBlock* condition = &current;
  if (statement.Cond) {
    condition = BuildExpression(*statement.Cond, *condition);
  }
  condition->SetTerminator(statement);

  CFGBlock& then_entry = cfg_->CreateBlock();
  cfg_->Connect(*condition, then_entry, CFGEdgeKind::True);
  CFGBlock* then_exit = statement.Then ? BuildCompound(*statement.Then, then_entry) : &then_entry;

  if (!statement.Else) {
    CFGBlock& join = cfg_->CreateBlock();
    cfg_->Connect(*condition, join, CFGEdgeKind::False);
    if (then_exit) {
      cfg_->Connect(*then_exit, join, CFGEdgeKind::Unconditional);
    }
    join.SetAnchor(statement);
    return &join;
  }

  CFGBlock& else_entry = cfg_->CreateBlock();
  cfg_->Connect(*condition, else_entry, CFGEdgeKind::False);
  CFGBlock* else_exit = BuildCompound(*statement.Else, else_entry);
  if (!then_exit && !else_exit) {
    return nullptr;
  }

  CFGBlock& join = cfg_->CreateBlock();
  if (then_exit) {
    cfg_->Connect(*then_exit, join, CFGEdgeKind::Unconditional);
  }
  if (else_exit) {
    cfg_->Connect(*else_exit, join, CFGEdgeKind::Unconditional);
  }
  join.SetAnchor(statement);
  return &join;
}

CFGBlock* CFGBuilder::BuildWhile(const WhileStmt& statement, CFGBlock& current) {
  CFGBlock& condition_entry = cfg_->CreateBlock();
  cfg_->Connect(current, condition_entry, CFGEdgeKind::Unconditional);

  CFGBlock* condition_exit = &condition_entry;
  if (statement.Cond) {
    condition_exit = BuildExpression(*statement.Cond, *condition_exit);
  }
  condition_exit->SetTerminator(statement);

  CFGBlock& body_entry = cfg_->CreateBlock();
  CFGBlock& loop_exit = cfg_->CreateBlock();
  cfg_->Connect(*condition_exit, body_entry, CFGEdgeKind::True);
  cfg_->Connect(*condition_exit, loop_exit, CFGEdgeKind::False);

  loop_stack_.push_back(LoopContext{&condition_entry, &loop_exit, scope_stack_.size()});
  CFGBlock* body_exit = statement.Body ? BuildCompound(*statement.Body, body_entry) : &body_entry;
  loop_stack_.pop_back();

  if (body_exit) {
    cfg_->Connect(*body_exit, condition_entry, CFGEdgeKind::Unconditional);
  }
  loop_exit.SetAnchor(statement);
  return &loop_exit;
}

CFGBlock* CFGBuilder::BuildReturn(const ReturnStmt& statement, CFGBlock& current) {
  CFGBlock* exit_block = &current;
  if (statement.Expr) {
    exit_block = BuildExpression(*statement.Expr, *exit_block);
  }
  exit_block->SetTerminator(statement);

  if (initializer_block_depth_ != 0) {
    return nullptr;
  }

  EmitFunctionExit(*exit_block, statement);
  return nullptr;
}

CFGBlock* CFGBuilder::BuildVarGroup(const VarGroupDecl& declaration, CFGBlock& current) {
  CFGBlock* block = &current;

  if (declaration.Body) {
    for (const auto& variable : declaration.Vars) {
      if (variable) {
        block->EmplaceElement<CFGDeclarationElement>(*variable, CFGDeclarationForm::InitializerBlockResult);
      }
    }

    // Check every terminal branch while the initializer block's locals are still in scope.
    ++initializer_block_depth_;
    BlockList body_exits = BuildResultCompound(*declaration.Body, *block, false);
    --initializer_block_depth_;
    for (CFGBlock* body_exit : body_exits) {
      body_exit->EmplaceElementAt<CFGResultCheckElement>(ResultExitProgramPoint(*body_exit), declaration,
                                                         ResultExitLocation(*body_exit, *declaration.Body));
      body_exit->EmplaceElement<CFGScopeExitElement>(*declaration.Body);
    }
    if (body_exits.empty()) {
      return nullptr;
    }
    if (body_exits.size() == 1) {
      return body_exits.front();
    }

    CFGBlock& continuation = cfg_->CreateBlock();
    for (CFGBlock* body_exit : body_exits) {
      cfg_->Connect(*body_exit, continuation, CFGEdgeKind::Unconditional);
    }
    continuation.SetAnchor(declaration);
    return &continuation;
  }

  if (!declaration.InitExprs.empty()) {
    for (std::size_t index = 0; index < std::max(declaration.Vars.size(), declaration.InitExprs.size()); ++index) {
      const Expr* initializer = index < declaration.InitExprs.size() ? declaration.InitExprs[index].get() : nullptr;
      if (initializer) {
        block = BuildExpression(*initializer, *block);
      }
      if (index >= declaration.Vars.size() || !declaration.Vars[index]) {
        continue;
      }
      // A type-inferred group member with no mapped source has no type or
      // initialization operation to recover. Explicitly typed group members,
      // and every member with an actual source, do establish a recovered
      // initialized instance at the declaration boundary.
      if (!declaration.Vars[index]->Type && !initializer) {
        continue;
      }
      block->EmplaceElement<CFGDeclarationElement>(*declaration.Vars[index], CFGDeclarationForm::DirectInitialization,
                                                   initializer);
    }
    return block;
  }

  for (const auto& variable : declaration.Vars) {
    if (variable) {
      block->EmplaceElement<CFGDeclarationElement>(*variable, CFGDeclarationForm::Uninitialized);
    }
  }
  return block;
}

CFGBlock* CFGBuilder::BuildExpression(const Expr& expression, CFGBlock& current, CFGExpressionContext context) {
  switch (expression.GetKind()) {
    case NodeKind::InitializationExpr:
      return BuildInitializationExpression(static_cast<const InitializationExpr&>(expression), current);
    case NodeKind::ImplicitResultInitializationExpr:
      return BuildImplicitResultInitializationExpression(
          static_cast<const ImplicitResultInitializationExpr&>(expression), current);
    case NodeKind::ConditionalOperator:
      return BuildConditionalExpression(static_cast<const ConditionalOperator&>(expression), current, context);
    case NodeKind::BinaryOperator: {
      const auto& binary = static_cast<const BinaryOperator&>(expression);
      if (binary.IsSimpleAssignment()) {
        return BuildSimpleAssignment(binary, current);
      }
      if (IsLogicalOperator(binary)) {
        return BuildLogicalExpression(binary, current);
      }
      break;
    }
    case NodeKind::OperatorCallExpr: {
      const auto& call = static_cast<const OperatorCallExpr&>(expression);
      if (IsAssignmentOperatorCall(call)) {
        return BuildAssignmentOperatorCall(call, current);
      }
      break;
    }
    case NodeKind::ArrayAssignmentExpr:
      return BuildArrayAssignment(static_cast<const ArrayAssignmentExpr&>(expression), current);
    case NodeKind::ArrayValueExpr:
      return BuildArrayValue(static_cast<const ArrayValueExpr&>(expression), current, context);
    default:
      break;
  }
  return BuildGenericExpression(expression, current, context);
}

CFGBlock* CFGBuilder::BuildGenericExpression(const Expr& expression, CFGBlock& current, CFGExpressionContext context) {
  CFGBlock* block = &current;
  std::vector<const Expr*> excluded_subexpressions;
  const std::vector<const Expr*> children = ExpressionChildren(expression, abi_);
  const bool ordered_call =
      expression.GetKind() == NodeKind::CallExpr || expression.GetKind() == NodeKind::ReceiverCallExpr ||
      expression.GetKind() == NodeKind::OperatorCallExpr || expression.GetKind() == NodeKind::ConstructionExpr ||
      expression.GetKind() == NodeKind::DestructorCallExpr;
  // Splitting every sibling preserves the evaluation before and after a branch.
  // Other multi-operand forms retain their existing source-level region.
  if ((children.size() == 1 || ordered_call) && std::any_of(children.begin(), children.end(), [](const Expr* child) {
        return RequiresSeparateCFGEvent(*child);
      })) {
    for (const Expr* child : children) {
      const CFGExpressionContext child_context =
          expression.GetKind() == NodeKind::ParenExpr ? context : CFGExpressionContext::Ordinary;
      block = BuildExpression(*child, *block, child_context);
      excluded_subexpressions.push_back(child);
    }
  }
  // Keep the enclosing event, but exclude children already represented by separate events.
  block->EmplaceElement<CFGExpressionElement>(expression, context, std::move(excluded_subexpressions));
  return block;
}

CFGBlock* CFGBuilder::BuildConditionalExpression(const ConditionalOperator& expression, CFGBlock& current,
                                                 CFGExpressionContext context) {
  CFGBlock* condition = &current;
  if (expression.Cond) {
    condition = BuildExpression(*expression.Cond, *condition);
  }
  condition->SetTerminator(expression);

  CFGBlock& then_entry = cfg_->CreateBlock();
  CFGBlock& else_entry = cfg_->CreateBlock();
  CFGBlock& join = cfg_->CreateBlock();
  cfg_->Connect(*condition, then_entry, CFGEdgeKind::True);
  cfg_->Connect(*condition, else_entry, CFGEdgeKind::False);

  CFGBlock* then_exit = &then_entry;
  if (expression.Then) {
    then_exit = BuildExpression(*expression.Then, *then_exit, context);
  }
  CFGBlock* else_exit = &else_entry;
  if (expression.Else) {
    else_exit = BuildExpression(*expression.Else, *else_exit, context);
  }
  cfg_->Connect(*then_exit, join, CFGEdgeKind::Unconditional);
  cfg_->Connect(*else_exit, join, CFGEdgeKind::Unconditional);
  join.SetAnchor(expression);
  return &join;
}

CFGBlock* CFGBuilder::BuildLogicalExpression(const BinaryOperator& expression, CFGBlock& current) {
  CFGBlock* condition = &current;
  if (expression.LHS) {
    condition = BuildExpression(*expression.LHS, *condition);
  }
  condition->SetTerminator(expression);

  CFGBlock& rhs_entry = cfg_->CreateBlock();
  CFGBlock& join = cfg_->CreateBlock();
  if (expression.op == expr::ampamp) {
    cfg_->Connect(*condition, rhs_entry, CFGEdgeKind::True);
    cfg_->Connect(*condition, join, CFGEdgeKind::False);
  } else {
    cfg_->Connect(*condition, join, CFGEdgeKind::True);
    cfg_->Connect(*condition, rhs_entry, CFGEdgeKind::False);
  }

  CFGBlock* rhs_exit = &rhs_entry;
  if (expression.RHS) {
    rhs_exit = BuildExpression(*expression.RHS, *rhs_exit);
  }
  cfg_->Connect(*rhs_exit, join, CFGEdgeKind::Unconditional);
  join.SetAnchor(expression);
  return &join;
}

CFGBlock* CFGBuilder::BuildSimpleAssignment(const BinaryOperator& expression, CFGBlock& current) {
  BOOST_ASSERT(expression.IsSimpleAssignment());
  CFGBlock* block = &current;
  std::vector<const Expr*> operands;
  if (expression.RHS) {
    block = BuildExpression(*expression.RHS, *block);
    operands.push_back(expression.RHS.get());
  }
  if (expression.LHS) {
    block = BuildExpression(*expression.LHS, *block, CFGExpressionContext::Ordinary);
    operands.push_back(expression.LHS.get());
  }
  block->EmplaceElement<CFGExpressionElement>(expression, CFGExpressionContext::Ordinary, std::move(operands));
  return block;
}

CFGBlock* CFGBuilder::BuildArrayAssignment(const ArrayAssignmentExpr& expression, CFGBlock& current) {
  CFGBlock* block = &current;
  std::vector<const Expr*> operands;
  if (expression.RHS) {
    block = BuildExpression(*expression.RHS, *block);
    operands.push_back(expression.RHS.get());
  }
  if (expression.LHS) {
    block = BuildExpression(*expression.LHS, *block, CFGExpressionContext::Ordinary);
    operands.push_back(expression.LHS.get());
  }
  block->EmplaceElement<CFGExpressionElement>(expression, CFGExpressionContext::Ordinary, std::move(operands));
  return block;
}

CFGBlock* CFGBuilder::BuildArrayValue(const ArrayValueExpr& expression, CFGBlock& current,
                                      CFGExpressionContext context) {
  CFGBlock* block = &current;
  std::vector<const Expr*> elements;
  elements.reserve(expression.Elements.size());
  for (const auto& element : expression.Elements) {
    if (!element) {
      continue;
    }
    block = BuildExpression(*element, *block);
    elements.push_back(element.get());
  }
  block->EmplaceElement<CFGExpressionElement>(expression, context, std::move(elements));
  return block;
}

CFGBlock* CFGBuilder::BuildAssignmentOperatorCall(const OperatorCallExpr& expression, CFGBlock& current) {
  BOOST_ASSERT(IsAssignmentOperatorCall(expression));
  CFGBlock* block = &current;
  std::vector<const Expr*> operands;

  // `=` has a language-defined evaluation order even after Sema replaces the
  // source BinaryOperator with an OperatorCallExpr. Args retain source order
  // [lhs, rhs], while the CFG evaluates rhs before lhs.
  block = BuildExpression(*expression.Args[1], *block);
  operands.push_back(expression.Args[1].get());

  const Expr& lhs = *expression.Args[0];
  block = BuildExpression(lhs, *block, CFGExpressionContext::Ordinary);
  operands.push_back(&lhs);

  block->EmplaceElement<CFGExpressionElement>(expression, CFGExpressionContext::Ordinary, std::move(operands));
  return block;
}

CFGBlock* CFGBuilder::BuildInitializationExpression(const InitializationExpr& expression, CFGBlock& current) {
  CFGBlock* block = &current;
  std::vector<const Expr*> operands;
  if (expression.Source) {
    block = BuildExpression(*expression.Source, *block);
    operands.push_back(expression.Source.get());
  }
  if (expression.Target) {
    const Expr* target = expression.Target->IgnoreParens();
    const bool is_non_lvalue_conditional =
        target && target->GetKind() == NodeKind::ConditionalOperator && target->value_category != ValueCategory::LValue;
    // Locating an initialization target must not read the object being initialized.
    const CFGExpressionContext target_context =
        is_non_lvalue_conditional ? CFGExpressionContext::Ordinary : CFGExpressionContext::InitializationTarget;
    block = BuildExpression(*expression.Target, *block, target_context);
    operands.push_back(expression.Target.get());
  }
  block->EmplaceElement<CFGExpressionElement>(expression, CFGExpressionContext::Ordinary, std::move(operands));
  return block;
}

CFGBlock* CFGBuilder::BuildImplicitResultInitializationExpression(const ImplicitResultInitializationExpr& expression,
                                                                  CFGBlock& current) {
  CFGBlock* block = &current;
  std::vector<const Expr*> operands;
  if (expression.Source) {
    block = BuildExpression(*expression.Source, *block);
    operands.push_back(expression.Source.get());
  }
  block->EmplaceElement<CFGExpressionElement>(expression, CFGExpressionContext::Ordinary, std::move(operands));
  return block;
}

void CFGBuilder::EmitScopeExits(CFGBlock& block, std::size_t outer_scope_depth) {
  BOOST_ASSERT(outer_scope_depth <= scope_stack_.size());
  for (std::size_t index = scope_stack_.size(); index > outer_scope_depth; --index) {
    block.EmplaceElement<CFGScopeExitElement>(*scope_stack_[index - 1]);
  }
}

void CFGBuilder::EmitFunctionExit(CFGBlock& block, const Node& exit_location) {
  BOOST_ASSERT(function_);
  if (HasReturnObject() || function_->GetKind() == NodeKind::ConstructorDecl) {
    block.EmplaceElement<CFGResultCheckElement>(*function_, exit_location);
  }
  EmitScopeExits(block, 0);
  block.EmplaceElement<CFGScopeExitElement>(*function_);
  cfg_->Connect(block, cfg_->GetExit(), CFGEdgeKind::Unconditional);
}

void CFGBuilder::RecordResultExit(CFGBlock& block, const Node& location) {
  result_exit_locations_[&block] = &location;
  result_exit_program_points_[&block] = cfg_->ReserveProgramPoint();
}

const Node& CFGBuilder::ResultExitLocation(const CFGBlock& block, const CompoundStmt& fallback) const {
  const auto it = result_exit_locations_.find(&block);
  return it != result_exit_locations_.end() && it->second ? *it->second : fallback;
}

std::size_t CFGBuilder::ResultExitProgramPoint(const CFGBlock& block) const {
  const auto it = result_exit_program_points_.find(&block);
  BOOST_ASSERT(it != result_exit_program_points_.end());
  return it->second;
}

bool CFGBuilder::HasReturnObject() const {
  if (!function_ || function_->GetKind() == NodeKind::ConstructorDecl ||
      function_->GetKind() == NodeKind::DestructorDecl || !function_->ReturnVar) {
    return false;
  }
  const QualType return_type = function_->ReturnVar->type;
  if (!return_type || return_type.GetTypePtr()->GetKind() != TypeKind::Builtin) {
    return true;
  }
  return static_cast<const BuiltinType*>(return_type.GetTypePtr())->GetBuiltinTypeKind() != BuiltinTypeKind::Void;
}

}  // namespace cw
