/// \file CFGBuilder.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "CFGBuilder.h"

#include <algorithm>
#include <utility>
#include <vector>

#include <boost/assert.hpp>

namespace cw {
std::unique_ptr<CFG> CFGBuilder::Build(const FunctionDecl& function) {
  if (!function.Body) {
    return nullptr;
  }
  return CFGBuilder(&function).BuildFunction();
}

std::unique_ptr<CFG> CFGBuilder::Build(const TranslationUnitDecl& translation_unit) {
  return CFGBuilder(nullptr).BuildGlobals(translation_unit);
}

CFGBuilder::CFGBuilder(const FunctionDecl* function) : function_(function), cfg_(std::make_unique<CFG>()) {}

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
  for (const auto& declaration : translation_unit.FlattenedDecls()) {
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
    EmitExpression(*tail, *block);
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
    EmitExpression(*tail, *block);
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
  if (statement.Cond) {
    EmitExpression(*statement.Cond, current);
  }
  current.SetTerminator(statement);

  CFGBlock& then_entry = cfg_->CreateBlock();
  CFGBlock& else_entry = cfg_->CreateBlock();
  cfg_->Connect(current, then_entry, CFGEdgeKind::True);
  cfg_->Connect(current, else_entry, CFGEdgeKind::False);

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
    case NodeKind::ImplicitThisInitializationCompleteStmt:
      return &current;
    case NodeKind::ExprStmt: {
      const auto& expression_statement = static_cast<const ExprStmt&>(statement);
      if (!expression_statement.Expr) {
        return &current;
      }
      EmitExpression(*expression_statement.Expr, current);
      return &current;
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
  if (statement.Cond) {
    EmitExpression(*statement.Cond, current);
  }
  current.SetTerminator(statement);

  CFGBlock& then_entry = cfg_->CreateBlock();
  cfg_->Connect(current, then_entry, CFGEdgeKind::True);
  CFGBlock* then_exit = statement.Then ? BuildCompound(*statement.Then, then_entry) : &then_entry;

  if (!statement.Else) {
    CFGBlock& join = cfg_->CreateBlock();
    cfg_->Connect(current, join, CFGEdgeKind::False);
    if (then_exit) {
      cfg_->Connect(*then_exit, join, CFGEdgeKind::Unconditional);
    }
    join.SetAnchor(statement);
    return &join;
  }

  CFGBlock& else_entry = cfg_->CreateBlock();
  cfg_->Connect(current, else_entry, CFGEdgeKind::False);
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

  if (statement.Cond) {
    EmitExpression(*statement.Cond, condition_entry);
  }
  condition_entry.SetTerminator(statement);

  CFGBlock& body_entry = cfg_->CreateBlock();
  CFGBlock& loop_exit = cfg_->CreateBlock();
  cfg_->Connect(condition_entry, body_entry, CFGEdgeKind::True);
  cfg_->Connect(condition_entry, loop_exit, CFGEdgeKind::False);

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
  if (statement.Expr) {
    EmitExpression(*statement.Expr, current);
  }
  current.SetTerminator(statement);

  if (initializer_block_depth_ != 0) {
    return nullptr;
  }

  EmitFunctionExit(current, statement);
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
        EmitExpression(*initializer, *block);
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

void CFGBuilder::EmitExpression(const Expr& expression, CFGBlock& block) {
  block.EmplaceElement<CFGExpressionElement>(expression);
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
