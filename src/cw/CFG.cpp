/// \file CFG.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "CFG.h"

#include <utility>

#include <boost/assert.hpp>

namespace cw {

CFGExpressionElement::CFGExpressionElement(const Expr& expression, CFGExpressionContext context,
                                           std::vector<const Expr*> excluded_subexpressions)
    : CFGElement(CFGElementKind::Expression),
      expression_(&expression),
      context_(context),
      excluded_subexpressions_(std::move(excluded_subexpressions)) {
  for (const Expr* excluded : excluded_subexpressions_) {
    BOOST_ASSERT(excluded);
    BOOST_ASSERT(excluded != expression_);
  }
}

CFGDeclarationElement::CFGDeclarationElement(const VarDecl& declaration, CFGDeclarationForm form,
                                             const Expr* initializer)
    : CFGElement(CFGElementKind::Declaration), declaration_(&declaration), form_(form), initializer_(initializer) {}

CFGScopeExitElement::CFGScopeExitElement(const Node& scope) : CFGElement(CFGElementKind::ScopeExit), scope_(&scope) {}

CFGResultCheckElement::CFGResultCheckElement(const Node& result_owner, const Node& exit_location)
    : CFGElement(CFGElementKind::ResultCheck), result_owner_(&result_owner), exit_location_(&exit_location) {}

void CFGBlock::SetTerminator(const Node& terminator) {
  BOOST_ASSERT(!terminator_);
  terminator_ = &terminator;
  terminator_program_point_ = (*next_program_point_)++;
}

void CFGBlock::SetAnchor(const Node& anchor) {
  BOOST_ASSERT(!anchor_);
  anchor_ = &anchor;
  anchor_program_point_ = (*next_program_point_)++;
}

CFG::CFG() {
  entry_ = &CreateBlock();
  exit_ = &CreateBlock();
}

CFG::~CFG() = default;

CFGBlock& CFG::CreateBlock() {
  auto block = std::unique_ptr<CFGBlock>(new CFGBlock(blocks_.size(), next_program_point_));
  CFGBlock& result = *block;
  blocks_.push_back(std::move(block));
  return result;
}

CFGEdge& CFG::Connect(CFGBlock& source, CFGBlock& target, CFGEdgeKind kind) {
  auto edge = std::unique_ptr<CFGEdge>(new CFGEdge(source, target, kind));
  CFGEdge& result = *edge;
  edges_.push_back(std::move(edge));
  source.successors_.push_back(&result);
  target.predecessors_.push_back(&result);
  return result;
}

}  // namespace cw
