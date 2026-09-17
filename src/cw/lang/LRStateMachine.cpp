/// \file LRStateMachine.cpp
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "LRStateMachine.h"

#include <stdexcept>

#include "LRParseTable.h"

namespace cw::lang {

LRStateMachine::LRStateMachine(Grammar grammar, LRParseTable parse_table)
    : grammar_(std::move(grammar)), parse_table_(std::move(parse_table)) {}

LRStateMachine::~LRStateMachine() {}

void LRStateMachine::Reset() {
  state_stack_.clear();
  symbol_stack_.clear();
}

int LRStateMachine::operator()(int symbol) {
  if (symbol < 0 || parse_table_.num_symbols() <= symbol) {
    throw std::logic_error("Invalid symbol");
  }

  int state = state_stack_.empty() ? 0 : state_stack_.back();
  const auto& action = parse_table_(state, symbol);

  switch (action.type) {
    case kActionError: {
      return OnErrored(state, symbol);
    }
    case kActionShift: {
      symbol_stack_.push_back(symbol);
      state_stack_.push_back(action.state);
      return OnShifted(action.state, symbol);
    }
    case kActionReduce: {
      auto& p = grammar_.P(action.production);

      // Pop the production body to recover the state before this nonterminal.
      int right_size = p.r.size();
      for (int i = 0; i < right_size; ++i) {
        state_stack_.pop_back();
        symbol_stack_.pop_back();
      }

      int pre_state = state_stack_.empty() ? 0 : state_stack_.back();
      const auto& new_action = parse_table_(pre_state, p.l);
      if (new_action.type != kActionGoto) {
        throw std::logic_error("Invalid action");
      }

      // GOTO replaces the reduced body with its left-hand nonterminal.
      symbol_stack_.emplace_back(p.l);
      state_stack_.push_back(new_action.state);

      return OnReduced(action.production, new_action.state, p.l);
    }
    case kActionAccept: {
      return OnAccepted();
    }
    default:
      throw std::logic_error("Invalid action");
  }
}

}  // namespace cw::lang
