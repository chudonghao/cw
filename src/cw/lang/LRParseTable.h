/// \file LRParseTable.h
/// \author Donghao Chu
/// \date 2025/01/13
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include <set>
#include <string>
#include <vector>

#include <boost/assert.hpp>

namespace cw::lang {

enum LRActionType : int {
  kActionError,
  kActionShift,
  kActionReduce,
  kActionGoto,
  kActionAccept,
};

struct LRAction {
  LRAction() = default;
  LRAction(LRActionType type, int d) : type(type), state(d) {}

  LRActionType type{};
  union {
    int state{};     // shift/goto
    int production;  // reduce
    int error;       // error
  };
};

inline std::string to_string(const LRAction& action) {
  switch (action.type) {
    default:
    case LRActionType::kActionError:
      return "";
    case LRActionType::kActionShift:
      return "s" + std::to_string(action.state);
    case LRActionType::kActionReduce:
      return "r" + std::to_string(action.production);
    case LRActionType::kActionGoto:
      return std::to_string(action.state);
    case LRActionType::kActionAccept:
      return "acc";
  }
}

inline bool operator<(const LRAction& lhs, const LRAction& rhs) {
  if (lhs.type < rhs.type) return true;
  if (rhs.type < lhs.type) return false;
  return lhs.state < rhs.state;
}
inline bool operator>(const LRAction& lhs, const LRAction& rhs) { return rhs < lhs; }
inline bool operator<=(const LRAction& lhs, const LRAction& rhs) { return !(rhs < lhs); }
inline bool operator>=(const LRAction& lhs, const LRAction& rhs) { return !(lhs < rhs); }

template <typename T>
class BasicLRParseTable {
 public:
  using Action = T;

  int num_states() const { return num_states_; }

  int num_symbols() const { return num_symbols_; }

  bool empty() const { return table_.empty(); }

  void Resize(int num_states, int num_symbols) {
    BOOST_ASSERT(num_states > 0);
    BOOST_ASSERT(num_symbols > 0);
    num_states_ = num_states;
    num_symbols_ = num_symbols;
    table_.resize(num_states * num_symbols);
  }

  Action& operator()(int state, int symbol) {
    BOOST_ASSERT(0 <= state && state < num_states_);
    BOOST_ASSERT(0 <= symbol && symbol < num_symbols_);
    return table_[state * num_symbols_ + symbol];
  }

  const Action& operator()(int state, int symbol) const {
    BOOST_ASSERT(0 <= state && state < num_states_);
    BOOST_ASSERT(0 <= symbol && symbol < num_symbols_);
    return table_[state * num_symbols_ + symbol];
  }

 private:
  int num_states_{};
  int num_symbols_{};
  std::vector<Action> table_;
};

using MultiActionLRParseTable = BasicLRParseTable<std::set<LRAction>>;
using LRParseTable = BasicLRParseTable<LRAction>;

class Grammar;

void Write(std::ostream& os, const Grammar& grammar, const MultiActionLRParseTable& table);

void Write(std::ostream& os, const Grammar& grammar, const LRParseTable& table);

}  // namespace cw::lang
