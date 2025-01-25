#include <fstream>

#include <gtest/gtest.h>

#include "cw/ExprGrammar.h"
#include "cw/lang/Grammar.h"
#include "cw/lang/GrammarAnalyzer.h"


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

}  // namespace G_ab
namespace cw::lang {
template <>
G_ab::Symbol from_string<G_ab::Symbol>(const char *s) {
  return G_ab::operator"" _s(s, strlen(s));
}
}  // namespace cw::lang

namespace G_Expr {

enum Symbol : int {
  ε,       // ε
  E,       // E
  T,       // T,
  F,       // F
  plus,    // +
  times,   // *
  lparen,  // (
  rparen,  // )
  id,      // id
  end,     // $

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

}  // namespace G_Expr

namespace cw::lang {

template <>
G_Expr::Symbol from_string<G_Expr::Symbol>(const char *s) {
  return from_string(G_Expr::Symbol{}, s);
}

}  // namespace cw::lang

namespace G_Equation {

enum Symbol : int {
  ε,
  S,
  L,
  R,
  times,
  plus,
  equal,
  id,
  end,

  num_symbols,
  terminal_start = times,
  terminal_end = end + 1,
};

const char *to_string(Symbol s) {
  switch (s) {
    case ε:
      return "ε";
    case S:
      return "S";
    case L:
      return "L";
    case R:
      return "R";
    case times:
      return "*";
    case plus:
      return "+";
    case equal:
      return "=";
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
  if (strcmp(s, "S") == 0) {
    return Symbol::S;
  }
  if (strcmp(s, "L") == 0) {
    return Symbol::L;
  }
  if (strcmp(s, "R") == 0) {
    return Symbol::R;
  }
  if (strcmp(s, "*") == 0) {
    return Symbol::times;
  }
  if (strcmp(s, "+") == 0) {
    return Symbol::plus;
  }
  if (strcmp(s, "=") == 0) {
    return Symbol::equal;
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

}  // namespace G_Equation

namespace cw::lang {
template <>
G_Equation::Symbol from_string<G_Equation::Symbol>(const char *s) {
  return from_string(G_Equation::Symbol{}, s);
}
}  // namespace cw::lang

TEST(Grammar, LR0) {
  using namespace cw::lang;

  using Symbol_t = G_ab::Symbol;
  auto num_symbols = G_ab::num_symbols;

  ProductionVec<Symbol_t> P;
  P("S", "B", "B");
  P("B", "a", "B");
  P("B", "b");

  auto g = Grammar::Create("ab", P, num_symbols, "S", "ε", "$");
  auto ga = GrammarAnalyzer::Analyze(g, GrammarAnalyzer::LR0);

  ASSERT_TRUE(ga.IsLR0());
}

TEST(Grammar, SLR) {
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

  auto g = Grammar::Create("Expr", P, num_symbols, "E", "ε", "$");
  auto ga = GrammarAnalyzer::Analyze(g, GrammarAnalyzer::LR0 | GrammarAnalyzer::SLR);
  ASSERT_FALSE(ga.IsLR0());
  ASSERT_TRUE(ga.IsSLR());
}

TEST(Grammar, LR1) {
  using namespace cw::lang;

  using Symbol_t = G_Equation::Symbol;
  auto num_symbols = G_Equation::num_symbols;

  ProductionVec<Symbol_t> P;
  P("S", "L", "=", "R");
  P("S", "R");
  P("L", "*", "R");
  P("L", "id");
  P("R", "L");

  auto g = Grammar::Create("Equation", P, num_symbols, "S", "ε", "$");
  auto ga = GrammarAnalyzer::Analyze(g, GrammarAnalyzer::ALL);
  ASSERT_FALSE(ga.IsLR0());
  ASSERT_FALSE(ga.IsSLR());
  // ASSERT_TRUE(ga.IsLR1());
}

TEST(Grammar, CW_Expr) {
  using namespace cw;

  lang::Grammar g = ExprGrammar();
  auto ga = lang::GrammarAnalyzer::Analyze(g, lang::GrammarAnalyzer::ALL);
  ASSERT_FALSE(ga.IsLR0());
  ASSERT_TRUE(ga.IsSLR());
}
