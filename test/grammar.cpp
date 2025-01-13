#include <functional>
#include <gtest/gtest.h>

#include "cw/lang/Grammar.h"
#include "cw/lang/GrammarAnalyzer.h"
#include "cw/lang/cw.h"

namespace G_ab {

enum Symbol {
  ε,
  S,
  B,
  a,
  b,
  end,

  num_symbols,
  terminal_start = a,
  terminal_end = end + 1,
};

const char *to_string(Symbol s) {
  switch (s) {
  case ε:
    return "ε";
  case S:
    return "S";
  case B:
    return "B";
  case a:
    return "a";
  case b:
    return "b";
  case end:
    return "$";
  }
  throw std::runtime_error("Invalid symbol");
}

Symbol operator"" _s(const char *s, size_t l) {
  std::string_view sv(s, l);
  if (sv == to_string(Symbol::ε)) {
    return Symbol::ε;
  }
  if (sv == to_string(Symbol::S)) {
    return Symbol::S;
  }
  if (sv == to_string(Symbol::B)) {
    return Symbol::B;
  }
  if (sv == to_string(Symbol::a)) {
    return Symbol::a;
  }
  if (sv == to_string(Symbol::b)) {
    return Symbol::b;
  }
  if (sv == to_string(Symbol::end)) {
    return Symbol::end;
  }
  throw std::runtime_error("Invalid symbol");
}

bool is_terminal(Symbol s) { return terminal_start <= s && s < terminal_end; }

} // namespace G_ab
namespace cw::lang {
template <> G_ab::Symbol from_string<G_ab::Symbol>(const char *s) {
  return G_ab::operator"" _s(s, strlen(s));
}
} // namespace cw::lang

namespace G_Expr {

enum Symbol : int {
  ε,      // ε
  E,      // E
  T,      // T,
  F,      // F
  plus,   // +
  times,  // *
  lparen, // (
  rparen, // )
  id,     // id
  end,    // $

  num_symbols,
  terminal_start = plus,
  terminal_end = end + 1,
};

const char *to_string(Symbol s) {
  if (s < 0) {
    return "";
  }
  switch (s) {
  case ε:
    return "ε";
  case E:
    return "E";
  case T:
    return "T";
  case F:
    return "F";
  case plus:
    return "+";
  case times:
    return "*";
  case lparen:
    return "(";
  case rparen:
    return ")";
  case id:
    return "id";
  case end:
    return "$";
  }
  throw std::logic_error("Invalid symbol");
}

Symbol from_string(Symbol tag, const char *s) {
  (void)tag;
  if (strcmp(s, "ε") == 0) {
    return Symbol::ε;
  }
  if (strcmp(s, "E") == 0) {
    return Symbol::E;
  }
  if (strcmp(s, "T") == 0) {
    return Symbol::T;
  }
  if (strcmp(s, "F") == 0) {
    return Symbol::F;
  }
  if (strcmp(s, "+") == 0) {
    return Symbol::plus;
  }
  if (strcmp(s, "*") == 0) {
    return Symbol::times;
  }
  if (strcmp(s, "(") == 0) {
    return Symbol::lparen;
  }
  if (strcmp(s, ")") == 0) {
    return Symbol::rparen;
  }
  if (strcmp(s, "id") == 0) {
    return Symbol::id;
  }
  if (strcmp(s, "$") == 0) {
    return Symbol::end;
  }
  throw std::runtime_error("Invalid symbol");
}

bool is_terminal(Symbol s) { return terminal_start <= s && s < terminal_end; }

} // namespace G_Expr

namespace cw::lang {

template <> G_Expr::Symbol from_string<G_Expr::Symbol>(const char *s) {
  return from_string(G_Expr::Symbol{}, s);
}

} // namespace cw::lang

TEST(Grammar, LR0_Canonical_Collection) {
  using namespace cw::lang;

  ProductionVec<G_ab::Symbol> P;
  P("S", "B", "B");
  P("B", "a", "B");
  P("B", "b");

  auto g = Grammar::Create(P, G_ab::num_symbols, "S", "ε", "$");
  auto ga = GrammarAnalyzer::Analyze(g, GrammarAnalyzer::LR0);

  std::cout << "===G===" << std::endl;
  g.Dump(std::cout);
  std::cout << "===LR(0) items===" << std::endl;
  ga.DumpLR0Items(std::cout);
  std::cout << "===LR(0) canonical collection===" << std::endl;
  ga.DumpLR0CanonicalCollection(std::cout);
}

TEST(Grammar, LR0_Canonical_Collection2) {
  using namespace cw::lang;

  using Symbol_t = G_Expr::Symbol;
  auto num_symbols = G_Expr::num_symbols;

  ProductionVec<Symbol_t> P;
  P("E", "E", "+", "T");
  P("E", "T");
  P("T", "T", "*", "F");
  P("T", "F");
  P("F", "(", "E", ")");
  P("F", "id");

  auto g = Grammar::Create(P, num_symbols, "E", "ε", "$");
  auto ga = GrammarAnalyzer::Analyze(g, GrammarAnalyzer::LR0 | GrammarAnalyzer::SLR);
  std::cout << "===G===" << std::endl;
  g.Dump(std::cout);
  std::cout << "===LR(0) items===" << std::endl;
  ga.DumpLR0Items(std::cout);
  std::cout << "===LR(0) canonical collection===" << std::endl;
  ga.DumpLR0CanonicalCollection(std::cout);
  std::cout << "===LR(0) parse table===" << std::endl;
  ga.DumpLR0ParseTable(std::cout);
  std::cout << "===SLR parse table===" << std::endl;
  ga.DumpSLRParseTable(std::cout);
}
