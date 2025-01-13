/// \file GrammarAnalyzer.h
/// \author Donghao Chu
/// \date 2025-01-13
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include <set>
#include <string>
#include <unordered_map>
#include <vector>

#include "Grammar.h"

namespace cw::lang {

namespace util {

struct HashIntSet {
  std::size_t operator()(const std::set<int>& I) const {
    std::size_t h = 0;
    for (auto i : I) {
      h ^= std::hash<int>()(i) + 0x9e3779b9 + (h << 6) + (h >> 2);
    }
    return h;
  }
};
struct HashIntPair {
  std::size_t operator()(const std::pair<int, int>& p) const {
    //
    return std::hash<long long>()(reinterpret_cast<const long long&>(p));
  }
};

}  // namespace util

using util::HashIntPair;
using util::HashIntSet;

struct LRItem {
  // production index
  int production{-1};
  // LR(0) place holder
  int place_holder{-1};
  // LR(1) lookahead
  int lookahead{-1};
  // next state item index
  int next_state{-1};

  LRItem(int production, int place_holder, int next_state) : production(production), place_holder(place_holder), next_state(next_state) {}
  LRItem(int production, int place_holder, int next_state, int lookahead) : production(production), place_holder(place_holder), next_state(next_state), lookahead(lookahead) {}
};

class LRCanonicalCollection {
  std::vector<std::set<int>> C_;
  std::unordered_map<std::set<int>, int, HashIntSet> C_map_;
  std::unordered_map<std::pair<int, int>, int, HashIntPair> GOTO_map_;

 public:
  int GOTO(int state, int symbol) const {
    if (GOTO_map_.find({state, symbol}) != GOTO_map_.end()) {
      return GOTO_map_.at({state, symbol});
    }
    return -1;
  }
  void GOTO(int state, int symbol, int next_state) { GOTO_map_[{state, symbol}] = next_state; }

  std::pair<int, bool> insert(const std::set<int>& I) {
    auto it = C_map_.find(I);
    if (it == C_map_.end()) {
      int index = C_.size();
      C_.push_back(I);
      C_map_[I] = index;
      return {index, true};
    }
    return {it->second, false};
  }

  auto begin() const { return C_.begin(); }

  auto end() const { return C_.end(); }

  int size() const { return C_.size(); }

  const std::set<int>& operator[](int index) const { return C_[index]; }

  int index(const std::set<int>& I) const {
    auto it = C_map_.find(I);
    if (it == C_map_.end()) {
      return -1;
    }
    return it->second;
  }

  int count(const std::set<int>& I) const { return C_map_.count(I); }
};

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

  void Resize(int num_states, int num_symbols) {
    num_states_ = num_states;
    num_symbols_ = num_symbols;
    table_.resize(num_states * num_symbols);
  }

  Action& operator()(int state, int symbol) { return table_[state * num_symbols_ + symbol]; }

  const Action& operator()(int state, int symbol) const { return table_[state * num_symbols_ + symbol]; }

 private:
  int num_states_{};
  int num_symbols_{};
  std::vector<Action> table_;
};

using MultiActionLRParseTable = BasicLRParseTable<std::set<LRAction>>;
using LRParseTable = BasicLRParseTable<LRAction>;

class GrammarAnalyzer {
 public:
  enum GrammarType {
    LR0 = 0x1,
    SLR = 0x2,
    LR1 = 0x4,
    ALL = LR0 | SLR | LR1,
  };

  // V(index) -> V set
  using FIRSTS_db = std::vector<std::set<int>>;
  // V(index) -> V set
  using FOLLOWS_db = std::vector<std::set<int>>;
  // P(index) -> V set
  using SELECTS_db = std::vector<std::set<int>>;

  const Grammar& grammar;
  FIRSTS_db firsts_db;
  FOLLOWS_db follows_db;
  SELECTS_db selects_db;

  // used for LR(0) and SLR
  std::vector<LRItem> lr0_items;
  // state(index) -> lr0 item indices
  LRCanonicalCollection lr0_canonical_collection;
  MultiActionLRParseTable lr0_parse_table;
  MultiActionLRParseTable slr_parse_table;

  // used for LR(1)
  std::vector<LRItem> lr1_items;
  // state(index) -> lr1 item indices
  LRCanonicalCollection lr1_canonical_collection;
  MultiActionLRParseTable lr1_parse_table;

  static GrammarAnalyzer Analyze(const Grammar& g, unsigned int GRAMMAR_TYPE = ALL);

  void DumpFirsts(std::ostream& os);

  void DumpFollows(std::ostream& os);

  void DumpSelects(std::ostream& os);

  void DumpLR0Item(std::ostream& os, int ii);

  void DumpLR0Items(std::ostream& os);

  void DumpLR0CanonicalCollection(std::ostream& os);

  void DumpLR0ParseTable(std::ostream& os);

  void DumpSLRParseTable(std::ostream& os);

 private:
  GrammarAnalyzer(const Grammar& g) : grammar(g) {}

 private:
  void DumpParseTable(std::ostream& os, const MultiActionLRParseTable& table);
};

}  // namespace cw::lang
