/// \file LRStateMachine.h
/// \author Donghao Chu
/// \date 2025-01-13
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include "Grammar.h"
#include "LRParseTable.h"

namespace cw::lang {

class LRStateMachine {
 protected:
  Grammar grammar_;
  LRParseTable parse_table_;
  std::vector<int> state_stack_;
  std::vector<int> symbol_stack_;

 public:
  LRStateMachine(Grammar grammar, LRParseTable parse_table);

  virtual ~LRStateMachine();

  virtual void Reset();

  int operator()(int symbol);

 protected:
  virtual int OnReduced(int production_id, int n_symbols) = 0;

  virtual int OnErrored(int state, int symbol) = 0;

  virtual int OnShifted(int state, int symbol) = 0;

  virtual int OnWentTo(int state, int symbol) = 0;

  virtual int OnAccepted() = 0;
};

}  // namespace cw::lang
