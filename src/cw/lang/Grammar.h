/// \file Grammar.h
/// \author Donghao Chu
/// \date 2025-01-10
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include <algorithm>
#include <initializer_list>
#include <ostream>
#include <vector>

#include <boost/container/static_vector.hpp>

namespace cw::lang {

constexpr int kMaxProductionLength = 10;

template <typename Symbol_t>
struct Production {
  using Symbol = Symbol_t;
  using Right = boost::container::static_vector<Symbol, kMaxProductionLength>;

  // left
  Symbol l{};
  // right
  Right r{};
  // auxiliary
  // int index{};

  Production() = default;

  Production(Symbol l, const Right& r) : l(l), r(r) {}
};

template <typename From, typename To>
struct ProductionTransform {
  Production<To> operator()(const Production<From>& p) const {
    typename Production<To>::Right r(p.r.size());
    std::transform(p.r.begin(), p.r.end(), r.begin(), [](const From& f) { return static_cast<To>(f); });
    Production<To> tp(p.l, r);
    return tp;
  }
};

template <typename Symbol>
Symbol from_string(const char* s);

template <typename Symbol>
class ProductionVec : public std::vector<Production<Symbol>> {
 public:
  using std::vector<Production<Symbol>>::vector;

  template <typename... Args>
  void operator()(const char* l, Args... args) {
    this->emplace_back(Production(from_string<Symbol>(l), {from_string<Symbol>(args)...}));
  }

  template <typename... Args>
  void operator()(Symbol l, Args... args) {
    this->emplace_back(Production(l, {args...}));
  }
};

class Grammar {
 public:
  struct SymbolInfo {
    // id, must equal to index
    int id{};
    bool is_terminal{};
    bool valid{};
    const char* name{};
  };
  using Production_t = Production<int>;
  using ProductionLeft_t = decltype(Production_t::l);
  using ProductionRight_t = decltype(Production_t::r);

 private:
  std::vector<SymbolInfo> symbol_infos_;
  std::vector<int> V_T_;
  std::vector<int> V_N_;
  // productions
  ProductionVec<int> P_;
  // augmented grammar: S '- > S
  Production<int> P_prime_;
  // start symbol
  int S_;
  // S'
  int S_prime_;
  // ε
  int ε_;
  // $
  int $_;

  // V_T and V_N
  std::vector<int> V_;
  // V(index) -> Productions
  std::vector<std::vector<int>> V2Ps_;

 public:
  template <typename Symbol_t>
  static Grammar Create(const ProductionVec<Symbol_t>& P, int num_symbols, Symbol_t Start, Symbol_t ε, Symbol_t $);

  template <typename Symbol_t>
  static Grammar Create(const ProductionVec<Symbol_t>& P, int num_symbols, const char* Start, const char* ε, const char* $);

  std::vector<int>& V() { return V_; }
  std::vector<int>& V_T() { return V_T_; }
  std::vector<int>& V_N() { return V_N_; }
  ProductionVec<int>& P() { return P_; }
  Production<int>& P(int index) { return index == -1 ? P_prime_ : P_[index]; }
  Production<int>& P_prime() { return P_prime_; }
  int& S() { return S_; }
  int& S_prime() { return S_prime_; }
  int& ε() { return ε_; }
  int& $() { return $_; }

  int NumSymbols4DB() const { return symbol_infos_.size(); }
  bool IsValidSymbol(int id) const { return 0 <= id && id < symbol_infos_.size() && symbol_infos_[id].valid; }
  bool IsTerminal(int id) const { return IsValidSymbol(id) && symbol_infos_[id].is_terminal; }
  bool IsNonTerminal(int id) const { return IsValidSymbol(id) && !symbol_infos_[id].is_terminal; }
  const char* SymbolName(int id) const { return IsValidSymbol(id) ? symbol_infos_[id].name : ""; }

  // Productions for V_N
  std::vector<int>& Productions4(int V_N) { return V2Ps_[V_N]; }

  int NumProductions() const { return P_.size(); }

  const std::vector<int>& V() const { return V_; }
  const std::vector<int>& V_T() const { return V_T_; }
  const std::vector<int>& V_N() const { return V_N_; }
  const ProductionVec<int>& P() const { return P_; }
  const Production<int>& P(int index) const { return index == -1 ? P_prime_ : P_[index]; }
  const Production<int>& P_prime() const { return P_prime_; }
  int S() const { return S_; }
  int S_prime() const { return S_prime_; }
  int ε() const { return ε_; }
  int $() const { return $_; }

  // Productions for V_N
  const std::vector<int>& Productions4(int V_N) const { return V2Ps_[V_N]; }

  bool IsEmptyProduction(int pi) const { return P(pi).r.size() == 1 && P(pi).r[0] == ε(); }

  void Dump(std::ostream& os) const;

  void DumpProduction(std::ostream& os, int pi) const;
};

}  // namespace cw::lang

// implement
namespace cw::lang {

template <typename Symbol_t>
Grammar Grammar::Create(const ProductionVec<Symbol_t>& P, int num_symbols, Symbol_t Start, Symbol_t ε, Symbol_t $) {
  Grammar G;
  std::transform(P.begin(), P.end(), std::back_inserter(G.P_), ProductionTransform<Symbol_t, int>());
  G.S_ = Start;
  G.ε_ = ε;
  G.$_ = $;

  G.symbol_infos_.resize(num_symbols + 1 /* add S' */);
  G.V2Ps_.resize(num_symbols + 1 /* add S' */);

  for (int i = 0; i < num_symbols; ++i) {
    G.symbol_infos_[i].id = i;
    G.symbol_infos_[i].is_terminal = is_terminal(static_cast<Symbol_t>(i));
    G.symbol_infos_[i].name = to_string(static_cast<Symbol_t>(i));
    G.symbol_infos_[i].valid = strlen(G.symbol_infos_[i].name) > 0;
    if (G.symbol_infos_[i].valid) {
      G.V_.push_back(i);
      if (i == ε) {
        // ignore ε
      } else if (G.symbol_infos_[i].is_terminal) {
        G.V_T_.push_back(i);
      } else {
        G.V_N_.push_back(i);
      }
    }
  }

  // TODO
  // add S'
  G.symbol_infos_[num_symbols].id = num_symbols;
  G.symbol_infos_[num_symbols].is_terminal = false;
  G.symbol_infos_[num_symbols].name = "S'";
  G.symbol_infos_[num_symbols].valid = true;
  G.S_prime_ = num_symbols;

  for (int i = 0; i < G.P_.size(); ++i) {
    G.V2Ps_[G.P_[i].l].push_back(i);
  }

  G.P_prime_ = Production<int>(G.S_prime_, {G.S_});

  return G;
}

template <typename Symbol_t>
Grammar Grammar::Create(const ProductionVec<Symbol_t>& P, int num_symbols, const char* Start, const char* ε, const char* $) {
  return Create(P, num_symbols, from_string<Symbol_t>(Start), from_string<Symbol_t>(ε), from_string<Symbol_t>($));
}

}  // namespace cw::lang
