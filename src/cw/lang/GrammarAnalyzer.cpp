/// \file GrammarAnalyzer.cpp
/// \author Donghao Chu
/// \date 2025-01-13
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include "GrammarAnalyzer.h"
#include "Grammar.h"

#include <boost/algorithm/string.hpp>

#include <iostream>
#include <vector>

namespace cw::lang {

const char *kLRItemPlaceHolderString = "·";

using ProductionRight_t = Grammar::ProductionRight_t;
using FIRSTS_db = GrammarAnalyzer::FIRSTS_db;
using FIRSTS_t = FIRSTS_db::value_type;
using FOLLOWS_db = GrammarAnalyzer::FOLLOWS_db;
using FOLLOWS_t = FOLLOWS_db::value_type;
using SELECTS_db = GrammarAnalyzer::SELECTS_db;
using SELECTS_t = SELECTS_db::value_type;

template <typename alpha_iter_t>
FIRSTS_t FIRST(const Grammar &g, const FIRSTS_db &first_db, alpha_iter_t alpha_begin, alpha_iter_t alpha_end) {
  FIRSTS_t firsts;

  int alpha_size = std::distance(alpha_begin, alpha_end);
  if (alpha_size == 0) {
    firsts.insert(g.ε());
    return firsts;
  } else if (alpha_size == 1 && *alpha_begin == g.ε()) {
    firsts.insert(g.ε());
    return firsts;
  } else {
    // ε should not be in α
  }

  int empty_count = 0;
  for (auto it = alpha_begin; it != alpha_end; ++it) {
    auto X = *it;
    // 如果元素是终结符，则将其加入到first集中，跳出循环
    // 如果是非终结符，则该非终结符的所有first集的所有内容加入first集中
    if (g.IsTerminal(X)) {
      firsts.insert(X);
      break;
    } else {
      if (!first_db[X].empty()) {
        auto &firsts2 = first_db[X];
        firsts.insert(firsts2.begin(), firsts2.end());
        if (firsts2.count(g.ε())) {
          ++empty_count;
          continue;
        }
      }
      // 未获取到非终结符的FIRST集，或集合不包含空，跳出循环
      break;
    }
  }
  if (empty_count == alpha_size) {
    // 所有符号都能推导出空，则将空加入到FIRST集中
    firsts.insert(g.ε());
  }

  return firsts;
}

FIRSTS_db FIRSTS(const Grammar &g) {
  FIRSTS_db firsts_db(g.NumSymbols4DB());

  // FIRST(terminal) = terminal
  for (auto a : g.V_T()) {
    firsts_db[a].insert(a);
  }

  // if V -> ε, FIRST(V) += {ε}
  for (auto A : g.V_N()) {
    for (auto p : g.Productions4(A)) {
      if (g.IsEmptyProduction(p)) {
        firsts_db[A].insert(g.ε());
      }
    }
  }

  bool has_new_first = true;
  do {
    has_new_first = false;

    for (auto V_N : g.V_N()) {
      for (auto pi : g.Productions4(V_N)) {
        auto &p = g.P(pi);
        auto fs = FIRST(g, firsts_db, p.r.begin(), p.r.end());
        for (auto f : fs) {
          if (firsts_db[V_N].insert(f).second) {
            has_new_first = true;
          }
        }
      }
    }
  } while (has_new_first);

  return firsts_db;
}

FOLLOWS_db FOLLOWS(const Grammar &g, const FIRSTS_db &firsts_db) {
  FOLLOWS_db follows_db(g.NumSymbols4DB());

  // add $ to FOLLOW(S)
  follows_db[g.S()] = {g.$()};

  bool has_new_follow = true;
  for (; has_new_follow;) {
    has_new_follow = false;

    // for each A in P
    for (auto &p : g.P()) {
      for (auto it = p.r.begin(); it != p.r.end(); ++it) {
        auto X = *it;
        if (g.IsTerminal(X)) {
          continue;
        }

        auto A = p.l;
        auto B = *it;
        auto beta_begin = std::next(it);
        auto beta_end = p.r.end();

        // for A -> αBβ, FIRST(β) except ε ⊆ FOLLOW(B)
        auto firsts_beta = FIRST(g, firsts_db, beta_begin, beta_end);
        bool firsts_beta_has_empty = false;
        for (auto a : firsts_beta) {
          if (a == g.ε()) {
            firsts_beta_has_empty = true;
            continue;
          }
          if (follows_db[B].insert(a).second) {
            has_new_follow = true;
          }
        }

        // if ε ∈ FIRST(β), then FOLLOW(B) ⊆ FOLLOW(A)
        if (firsts_beta_has_empty) {
          for (auto a : follows_db[A]) {
            if (follows_db[B].insert(a).second) {
              has_new_follow = true;
            }
          }
        }
      }
    }
  }

  return follows_db;
}

SELECTS_db SELECTS(const Grammar &g, const FIRSTS_db &firsts_db, const FOLLOWS_db &follows_db) {
  SELECTS_db selects_db(g.NumProductions());

  for (int pi = 0; pi < g.NumProductions(); ++pi) {
    // def A -> α
    auto &p = g.P(pi);
    auto A = p.l;
    auto alpha_begin = p.r.begin();
    auto alpha_end = p.r.end();

    // FIRST(α)
    FIRSTS_t firsts_alpha = FIRST(g, firsts_db, alpha_begin, alpha_end);

    // if ε ∉ FIRST(α), then SELECT(p) = FIRST(α)
    // if ε ∈ FIRST(α), then SELECT(p) = (FIRST(α) - {ε}) ∪ FOLLOW(A)
    if (firsts_alpha.count(g.ε()) == 0) {
      selects_db[pi] = firsts_alpha;
    } else {
      firsts_alpha.erase(g.ε());
      selects_db[pi].insert(firsts_alpha.begin(), firsts_alpha.end());
      selects_db[pi].insert(follows_db[p.l].begin(), follows_db[p.l].end());
    }
  }
  return selects_db;
}

bool IsMoveInState(const LRItem &item) { return item.place_holder == 0; }

bool IsReduceState(const LRItem &item) { return item.next_state == -1; }

int NextState(const LRItem &item) { return item.next_state; }

int LeftSymbol(const Grammar &g, const LRItem &item) {
  auto &p = g.P(item.production);
  return p.l;
}

bool IsNextSymbolNonTerminal(const Grammar &g, const LRItem &item) {
  auto &p = g.P(item.production);
  if (item.place_holder < 0 || p.r.size() <= item.place_holder) {
    return false;
  }
  auto next_symbol = p.r[item.place_holder];
  return g.IsNonTerminal(next_symbol);
}

int NextSymbol(const Grammar &g, const LRItem &item) {
  auto &p = g.P(item.production);
  BOOST_ASSERT(item.place_holder >= 0 && item.place_holder < p.r.size());
  return p.r[item.place_holder];
}

// bool IsLR0EqualItem(const Grammar &g, const LRItem &item, const LRItem &test) {
//   auto &p = g.P(item.production);
//   auto &p_test = g.P(test.production);
//   return IsNextSymbolNonTerminal(g, test) && NextSymbol(g, test) == p.l;
// }

std::vector<LRItem> LR0_ITEMS(const Grammar &g) {
  std::vector<LRItem> items;

  auto CreateItems = [](auto &items, int pi, auto &p) {
    for (auto i = 0; i <= p.r.size(); ++i) {
      int state = i;
      int next_state = i < p.r.size() ? items.size() + 1 : -1;
      items.emplace_back(pi, state, next_state);
    }
  };

  CreateItems(items, -1, g.P_prime());
  for (int pi = 0; pi < g.NumProductions(); ++pi) {
    CreateItems(items, pi, g.P(pi));
  }

  return items;
}

std::set<int> LR0_CLOSURE(const Grammar &g, const std::vector<LRItem> &lr_items, std::set<int> I) {
  std::set<int> new_items;
  do {
    I.insert(new_items.begin(), new_items.end());
    new_items.clear();

    for (auto ii : I) {
      auto &item = lr_items[ii];
      if (IsNextSymbolNonTerminal(g, item)) {
        auto A = NextSymbol(g, item);
        for (int equal_ii = 0; equal_ii < lr_items.size(); ++equal_ii) {
          auto &equal_item = lr_items[equal_ii];
          if (IsMoveInState(equal_item) && LeftSymbol(g, equal_item) == A) {
            if (I.count(equal_ii) == 0) {
              new_items.insert(equal_ii);
            }
          }
        }
      }
    }
  } while (!new_items.empty());
  return I;
}

std::set<int> LR0_GOTO(const Grammar &g, const std::vector<LRItem> &lr_items, const std::set<int> &I, int X) {
  std::set<int> J;
  if (I.empty()) {
    return J;
  }

  for (auto ii : I) {
    auto &item = lr_items[ii];
    if (!IsReduceState(item) && NextSymbol(g, item) == X) {
      J.insert(NextState(item));
    }
  }

  return LR0_CLOSURE(g, lr_items, J);
}

template <typename GOTO_func>
LRCanonicalCollection LRk_CANONICAL_COLLECTION(const Grammar &g, const std::vector<LRItem> &lr_items, GOTO_func &&goto_func) {
  BOOST_ASSERT(!lr_items.empty());
  BOOST_ASSERT(LeftSymbol(g, lr_items[0]) == g.S_prime() && IsMoveInState(lr_items[0]));

  LRCanonicalCollection C;
  C.insert(LR0_CLOSURE(g, lr_items, {0}));

#if 0
  std::unordered_set<std::pair<int, int>, HashIntPair> goto_set;
  std::vector<std::set<int>> new_states;
  std::vector<std::pair<int, int>> new_state_source;

  /// TODO Does it only need to be traversed once?
  do {
    for (int si = 0; si < new_states.size(); ++si) {
      auto source_state_index = new_state_source[si].first;
      auto symbol = new_state_source[si].second;
      auto &new_state = new_states[si];

      // insert
      auto [new_state_index, inserted] = C.insert(new_state);

      // record goto
      C.GOTO(source_state_index, symbol, new_state_index);
    }
    new_states.clear();
    new_state_source.clear();

    for (int ii = 0; ii < C.size(); ++ii) {
      auto &I = C[ii];
      for (auto X : g.V()) {
        if (goto_set.count({ii, X}) != 0) {
          continue;
        }

        auto J = goto_func(g, lr_items, I, X);
        if (J.empty()) {
          continue;
        }
        if (int new_state_index = C.index(J); new_state_index == -1) {
          new_states.push_back(J);
          new_state_source.emplace_back(ii, X);
        } else {
          C.GOTO(ii, X, new_state_index);
        }
      }
    }
  } while (!new_states.empty());
#else
  for (int ii = 0; ii < C.size(); ++ii) {
    for (auto X : g.V()) {
      auto &I = C[ii];
      auto J = goto_func(g, lr_items, I, X);
      if (J.empty()) {
        continue;
      }
      auto [ji, inserted] = C.insert(J);
      C.GOTO(ii, X, ji);
    }
  }
#endif

  return C;
}

LRCanonicalCollection LR0_CANONICAL_COLLECTION(const Grammar &g, const std::vector<LRItem> &lr_items) {
  //
  return LRk_CANONICAL_COLLECTION(g, lr_items, LR0_GOTO);
}

struct LR0ReduceFunc {
  void operator()(const Grammar &g, MultiActionLRParseTable &table, int state, const LRItem &item) const {
    auto &p = g.P(item.production);
    for (auto a : g.V_T()) {
      table(state, a).insert({kActionReduce, item.production});
    }
  }
};

struct SLRReduceFunc {
  const FOLLOWS_db &follows_db;
  SLRReduceFunc(const FOLLOWS_db &follows_db) : follows_db(follows_db) {}
  void operator()(const Grammar &g, MultiActionLRParseTable &table, int state, const LRItem &item) const {
    auto &p = g.P(item.production);
    for (auto a : follows_db[p.l]) {
      table(state, a).insert({kActionReduce, item.production});
    }
  }
};

struct LR1ReduceFunc {};

template <typename ReduceFunc>
MultiActionLRParseTable LRk_PARSE_TABLE(const Grammar &g, const std::vector<LRItem> &lr_items, const LRCanonicalCollection &C, ReduceFunc &&reduce) {
  MultiActionLRParseTable table;
  table.Resize(C.size(), g.NumSymbols4DB());
  for (int i = 0; i < C.size(); ++i) {
    auto &I = C[i];
    for (const auto &ii : I) {
      auto &item = lr_items[ii];
      if (IsReduceState(item)) {
        if (LeftSymbol(g, item) == g.S_prime()) {
          table(i, g.$()).insert({kActionAccept, -1});
        } else {
          reduce(g, table, i, item);
        }
      } else {
        auto X = NextSymbol(g, item);
        auto j = C.GOTO(i, X);
        if (j != -1) {
          if (g.IsTerminal(X)) {
            table(i, X).insert({kActionShift, j});
          } else if (g.IsNonTerminal(X)) {
            table(i, X).insert({kActionGoto, j});
          } else {
            throw std::logic_error(std::string("unknown symbol ") + g.SymbolName(X));
          }
        } else {
          throw std::logic_error("next state not found");
        }
      }
    }
  }
  return table;
}

MultiActionLRParseTable LR0_PARSE_TABLE(const Grammar &g, const std::vector<LRItem> &lr_items, const LRCanonicalCollection &C) {
  //
  return LRk_PARSE_TABLE(g, lr_items, C, LR0ReduceFunc());
}

MultiActionLRParseTable SLR_PARSE_TABLE(const Grammar &g, const FOLLOWS_db &follows_db, const std::vector<LRItem> &lr_items, const LRCanonicalCollection &C) {
  //
  return LRk_PARSE_TABLE(g, lr_items, C, SLRReduceFunc(follows_db));
}

}  // namespace cw::lang

namespace cw::lang {

GrammarAnalyzer GrammarAnalyzer::Analyze(const Grammar &g, unsigned int GRAMMAR_TYPE) {
  GrammarAnalyzer ga(g);
  ga.firsts_db = FIRSTS(g);
  ga.follows_db = FOLLOWS(g, ga.firsts_db);
  ga.selects_db = SELECTS(g, ga.firsts_db, ga.follows_db);

  if (GRAMMAR_TYPE & (LR0 | SLR)) {
    ga.lr0_items = LR0_ITEMS(g);
    ga.lr0_canonical_collection = LR0_CANONICAL_COLLECTION(g, ga.lr0_items);
  }

  if (GRAMMAR_TYPE & LR0) {
    ga.lr0_parse_table = LR0_PARSE_TABLE(g, ga.lr0_items, ga.lr0_canonical_collection);
  }

  if (GRAMMAR_TYPE & SLR) {
    ga.slr_parse_table = SLR_PARSE_TABLE(g, ga.follows_db, ga.lr0_items, ga.lr0_canonical_collection);
  }

  if (GRAMMAR_TYPE & LR1) {
  }

  return ga;
}

bool GrammarAnalyzer::IsLR0() const {
  if (lr0_items.empty() || lr0_canonical_collection.empty()) {
    return false;
  }
  return !HasConflict(lr0_parse_table);
}

bool GrammarAnalyzer::IsSLR() const {
  if (lr0_items.empty() || lr0_canonical_collection.empty()) {
    return false;
  }
  return !HasConflict(slr_parse_table);
}

void GrammarAnalyzer::DumpFirsts(std::ostream &os) const {
  std::set<int> viewed_index;
  for (auto A : grammar.V_N()) {
    if (firsts_db[A].empty()) {
      continue;
    }

    os << "FIRST( " << grammar.SymbolName(A) << " ) = { ";
    for (auto X : firsts_db[A]) {
      os << grammar.SymbolName(X) << ' ';
    }
    os << "}" << std::endl;
  }
}

void GrammarAnalyzer::DumpFollows(std::ostream &os) const {
  for (auto A : grammar.V_N()) {
    if (follows_db[A].empty()) {
      continue;
    }

    os << "FOLLOW( " << grammar.SymbolName(A) << " ) = { ";
    for (auto X : follows_db[A]) {
      os << grammar.SymbolName(X) << ' ';
    }
    os << "}" << std::endl;
  }
}

void GrammarAnalyzer::DumpSelects(std::ostream &os) const {
  for (int pi = 0; pi < grammar.NumProductions(); ++pi) {
    os << "SELECT( ";
    grammar.DumpProduction(os, pi);
    os << " ) = { ";
    for (auto X : selects_db[pi]) {
      os << grammar.SymbolName(X) << " ";
    }
    os << "}" << std::endl;
  }
}

void GrammarAnalyzer::DumpLR0Item(std::ostream &os, int ii) const {
  auto &item = lr0_items[ii];
  auto &p = grammar.P(item.production);

  os << grammar.SymbolName(p.l) << " -> ";
  for (int i = 0; i < p.r.size(); ++i) {
    if (i == item.place_holder) {
      os << kLRItemPlaceHolderString << " ";
    }
    os << grammar.SymbolName(p.r[i]) << " ";
  }
  if (item.place_holder == p.r.size()) {
    os << kLRItemPlaceHolderString;
  }

  os << " (next: " << item.next_state << ")";
}

void GrammarAnalyzer::DumpLR0Items(std::ostream &os) const {
  for (int ii = 0; ii < lr0_items.size(); ++ii) {
    os << "item " << ii << ": ";
    DumpLR0Item(os, ii);
    os << std::endl;
  }
}

void GrammarAnalyzer::DumpLR0CanonicalCollection(std::ostream &os) const {
  auto &C = lr0_canonical_collection;

  for (int i = 0; i < C.size(); ++i) {
    os << "I" << i << ":" << std::endl;
    for (auto ii : C[i]) {
      os << "  ";
      DumpLR0Item(os, ii);
      os << std::endl;
    }
  }

  for (int i = 0; i < C.size(); ++i) {
    for (auto X : grammar.V()) {
      auto j = C.GOTO(i, X);
      if (j != -1) {
        os << "GOTO( I" << i << ", " << grammar.SymbolName(X) << " ) = I" << j << std::endl;
      }
    }
  }
}

void GrammarAnalyzer::DumpLR0ParseTable(std::ostream &os) const { DumpParseTable(os, lr0_parse_table); }

void GrammarAnalyzer::DumpSLRParseTable(std::ostream &os) const { DumpParseTable(os, slr_parse_table); }

void GrammarAnalyzer::DumpParseTable(std::ostream &os, const MultiActionLRParseTable &table) const {
  auto FormatActions = [](const std::set<LRAction> &actions) {
    std::vector<std::string> action_strs;
    for (auto &action : actions) {
      action_strs.push_back(to_string(action));
    }
    return boost::join(action_strs, "/");
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

bool GrammarAnalyzer::HasConflict(const MultiActionLRParseTable &table) const {
  for (int state = 0; state < table.num_states(); ++state) {
    for (int symbol = 0; symbol < table.num_symbols(); ++symbol) {
      auto &action = table(state, symbol);
      if (action.size() > 1) {
        return true;
      }
    }
  }
  return false;
}

}  // namespace cw::lang
