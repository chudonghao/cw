/// \file LRParseTable.cpp
/// \author Donghao Chu
/// \date 2025/01/13
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include "LRParseTable.h"

#include <boost/algorithm/string.hpp>

#include "Grammar.h"

namespace cw::lang {

template <typename Action>
void Write_(std::ostream& os, const Grammar& grammar, const BasicLRParseTable<Action>& table) {
  auto FormatActions = [](const auto& actions) {
    if constexpr (std::is_same_v<Action, std::set<LRAction>>) {
      std::vector<std::string> action_strs;
      for (auto& action : actions) {
        action_strs.push_back(to_string(action));
      }
      return boost::join(action_strs, "/");
    } else {
      return to_string(actions);
    }
  };

  os << "state/action/symbol\t";
  for (auto a : grammar.V_T()) {
    os << grammar.SymbolName(a) << "\t";
  }
  for (auto A : grammar.V_N()) {
    os << grammar.SymbolName(A) << "\t";
  }
  os << std::endl;

  for (int s = 0; s < table.num_states(); ++s) {
    os << s << "\t";
    for (auto a : grammar.V_T()) {
      os << FormatActions(table(s, a)) << "\t";
    }
    for (auto A : grammar.V_N()) {
      os << FormatActions(table(s, A)) << "\t";
    }
    os << std::endl;
  }
}

void Write(std::ostream& os, const Grammar& grammar, const MultiActionLRParseTable& table) { Write_(os, grammar, table); }

void Write(std::ostream& os, const Grammar& grammar, const LRParseTable& table) { Write_(os, grammar, table); }

}  // namespace cw::lang
