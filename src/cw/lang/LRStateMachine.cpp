/// \file LRStateMachine.cpp
/// \author Donghao Chu
/// \date 2025-01-13
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include "LRStateMachine.h"
#include <stdexcept>
#include "LRParseTable.h"

namespace cw::lang {

LRStateMachine::LRStateMachine(Grammar grammar, LRParseTable parse_table) : grammar_(std::move(grammar)), parse_table_(std::move(parse_table)) {}

LRStateMachine::~LRStateMachine() {}

void LRStateMachine::Reset() {
  state_stack_.clear();
  symbol_stack_.clear();
}

int LRStateMachine::operator()(int symbol) {
  int state = state_stack_.empty() ? 0 : state_stack_.back();
  auto action = parse_table_(state, symbol);

  switch (action.type) {
    case kActionError: {
      return OnErrored(state, symbol);
    }
    case kActionShift: {
      state_stack_.push_back(action.state);
      symbol_stack_.push_back(symbol);
      return OnShifted(action.state, symbol);
    }
    case kActionReduce: {
      auto &p = grammar_.P(action.production);
      // TODO empty production
      int right_size = p.r.size();
      for (int i = 0; i < right_size; ++i) {
        state_stack_.pop_back();
        symbol_stack_.pop_back();
      }

      int ret = OnReduced(action.production, right_size);
      return ret ? ret : (*this)(p.l);
    }
    case kActionGoto: {
      symbol_stack_.push_back(symbol);
      state_stack_.push_back(action.state);
      return OnWentTo(action.state, symbol);
    }
    case kActionAccept: {
      return OnAccepted();
    }
    default:
      throw std::logic_error("Invalid action");
  }
}

}  // namespace cw::lang