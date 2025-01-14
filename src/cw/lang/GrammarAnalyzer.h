/// \file GrammarAnalyzer.h
/// \author Donghao Chu
/// \date 2025-01-13
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include <set>
#include <stdexcept>
#include <unordered_map>
#include <vector>

#include "Grammar.h"
#include "LRParseTable.h"

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

  bool empty() const { return C_.empty(); }

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

  bool IsLR0() const;

  bool IsSLR() const;

  bool IsLR1() const;

  LRParseTable CreateLR0PaserTable() const;

  LRParseTable CreateSLRPaserTable() const;

  LRParseTable CreateLR1ParserTable() const;

  LRParseTable CreateLRPaserTable() const {
    if (IsLR1()) {
      return CreateLR1ParserTable();
    }
    if (IsSLR()) {
      return CreateSLRPaserTable();
    }
    if (IsLR0()) {
      return CreateLR0PaserTable();
    }
    throw std::logic_error("Invalid grammar");
  }

  void DumpFirsts(std::ostream& os) const;

  void DumpFollows(std::ostream& os) const;

  void DumpSelects(std::ostream& os) const;

  void DumpLR0Item(std::ostream& os, int ii) const;

  void DumpLR0Items(std::ostream& os) const;

  void DumpLR0CanonicalCollection(std::ostream& os) const;

  void DumpLR0ParseTable(std::ostream& os) const;

  void DumpSLRParseTable(std::ostream& os) const;

 private:
  GrammarAnalyzer(const Grammar& g) : grammar(g) {}

 private:
  void DumpParseTable(std::ostream& os, const MultiActionLRParseTable& table) const;

  bool HasConflict(const MultiActionLRParseTable& table) const;

  LRParseTable ConvertToSingleActionLRParseTable(const MultiActionLRParseTable& table) const;
};

}  // namespace cw::lang
