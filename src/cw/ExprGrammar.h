/// \file ExprGrammar.h
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include "lang/Grammar.h"

namespace cw::expr {

enum ExprGrammarSymbol : int {
  ε,
  Expr,
  StringLiterals,
  ID,
  ArgumentList,
  ParenthesizedArgumentList,
  ArrayInitializer,
  ArrayElement,
  ArrayElementList,
  NonVirtualCallName,
  OperatorFunctionName,
  PrimaryExpr,
  PostfixExpr,
  T3,
  T4,
  T5,
  T6,
  T7,
  T8,
  T9,
  T10,
  T11,
  T12,
  T13,
  T14,
  T15,
  T16,

  // Identifiers
  identifier,  // abc_123, etc.

  // Constants
  null_literal,       // null
  bool_literal,       // true, false
  integer_literal,    // 123, 0xFF, etc.
  character_literal,  // 'a', '\n', etc.
  float_literal,      // 1.23f, 0.0, etc.
  string_literal,     // "abc", etc.

  // Keyword operators
  move_,  // move value

  // Function names accepted only by dedicated expression productions.
  operator_,  // operator

  // Reserved object expression
  this_,  // current object

  // Keyword-led calls
  ctor_,        // ctor (address) T(arguments)
  dtor_,        // dtor (address) T()
  nonvirtual_,  // explicit non-virtual named function call

  // Operators
  period,               // .
  arrow,                // ->
  amp,                  // &
  ampamp,               // &&
  star,                 // *
  plus,                 // +
  plusplus,             // ++
  minus,                // -
  minusminus,           // --
  tilde,                // ~
  exclaim,              // !
  exclaimequal,         // !=
  slash,                // /
  percent,              // %
  less,                 // <
  lessequal,            // <=
  lessless,             // <<
  greater,              // >
  greaterequal,         // >=
  greatergreater,       // >>
  caret,                // ^
  pipe,                 // |
  pipepipe,             // ||
  question,             // ?
  colon,                // :
  colonequal,           // :=
  equal,                // =
  plusequal,            // +=
  minusequal,           // -=
  starequal,            // *=
  slashequal,           // /=
  percentequal,         // %=
  lesslessequal,        // <<=
  greatergreaterequal,  // >>=
  ampequal,             // &=
  caretequal,           // ^=
  pipeequal,            // |=
  equalequal,           // ==
  comma,                // ,

  // Separators
  semi,      // ;
  l_square,  // [
  r_square,  // ]
  l_paren,   // (
  r_paren,   // )
  l_brace,   // {
  r_brace,   // }

  // Parser-produced terminals
  type,  // Type syntax parsed as one terminal by the enclosing parser.

  $,

  num_symbols,
  terminals_start = identifier,
  terminals_end = $ + 1,
};

inline const char* to_string(ExprGrammarSymbol symbol) {
  switch (symbol) {
    case ε:
      return "ε";
    case Expr:
      return "Expr";
    case StringLiterals:
      return "StringLiterals";
    case ID:
      return "ID";
    case ArgumentList:
      return "ArgumentList";
    case ParenthesizedArgumentList:
      return "ParenthesizedArgumentList";
    case ArrayInitializer:
      return "ArrayInitializer";
    case ArrayElement:
      return "ArrayElement";
    case ArrayElementList:
      return "ArrayElementList";
    case NonVirtualCallName:
      return "NonVirtualCallName";
    case OperatorFunctionName:
      return "OperatorFunctionName";
    case PrimaryExpr:
      return "PrimaryExpr";
    case PostfixExpr:
      return "PostfixExpr";
    case T3:
      return "T3";
    case T4:
      return "T4";
    case T5:
      return "T5";
    case T6:
      return "T6";
    case T7:
      return "T7";
    case T8:
      return "T8";
    case T9:
      return "T9";
    case T10:
      return "T10";
    case T11:
      return "T11";
    case T12:
      return "T12";
    case T13:
      return "T13";
    case T14:
      return "T14";
    case T15:
      return "T15";
    case T16:
      return "T16";
    case identifier:
      return "identifier";
    case null_literal:
      return "null";
    case bool_literal:
      return "bool_literal";
    case integer_literal:
      return "integer_literal";
    case character_literal:
      return "character_literal";
    case float_literal:
      return "float_literal";
    case string_literal:
      return "string_literal";
    case move_:
      return "move";
    case operator_:
      return "operator";
    case this_:
      return "this";
    case ctor_:
      return "ctor";
    case dtor_:
      return "dtor";
    case nonvirtual_:
      return "nonvirtual";
    case period:
      return ".";
    case arrow:
      return "->";
    case amp:
      return "&";
    case ampamp:
      return "&&";
    case star:
      return "*";
    case plus:
      return "+";
    case plusplus:
      return "++";
    case minus:
      return "-";
    case minusminus:
      return "--";
    case tilde:
      return "~";
    case exclaim:
      return "!";
    case exclaimequal:
      return "!=";
    case slash:
      return "/";
    case percent:
      return "%";
    case less:
      return "<";
    case lessless:
      return "<<";
    case lessequal:
      return "<=";
    case greater:
      return ">";
    case greatergreater:
      return ">>";
    case greaterequal:
      return ">=";
    case caret:
      return "^";
    case pipe:
      return "|";
    case pipepipe:
      return "||";
    case question:
      return "?";
    case colon:
      return ":";
    case colonequal:
      return ":=";
    case equal:
      return "=";
    case plusequal:
      return "+=";
    case minusequal:
      return "-=";
    case starequal:
      return "*=";
    case slashequal:
      return "/=";
    case percentequal:
      return "%=";
    case lesslessequal:
      return "<<=";
    case greatergreaterequal:
      return ">>=";
    case ampequal:
      return "&=";
    case caretequal:
      return "^=";
    case pipeequal:
      return "|=";
    case equalequal:
      return "==";
    case comma:
      return ",";
    case semi:
      return ";";
    case l_square:
      return "[";
    case r_square:
      return "]";
    case l_paren:
      return "(";
    case r_paren:
      return ")";
    case l_brace:
      return "{";
    case r_brace:
      return "}";
    case type:
      return "type";
    case $:
      return "$";
    default:
      throw std::logic_error("invalid symbol");
  }
}

inline ExprGrammarSymbol from_string(ExprGrammarSymbol tag, const char* str) {
  (void)tag;
  if (strcmp(str, to_string(ε)) == 0) {
    return ε;
  }
  if (strcmp(str, to_string(Expr)) == 0) {
    return Expr;
  }
  if (strcmp(str, to_string(StringLiterals)) == 0) {
    return StringLiterals;
  }
  if (strcmp(str, to_string(ID)) == 0) {
    return ID;
  }
  if (strcmp(str, to_string(ArgumentList)) == 0) {
    return ArgumentList;
  }
  if (strcmp(str, to_string(ParenthesizedArgumentList)) == 0) {
    return ParenthesizedArgumentList;
  }
  if (strcmp(str, to_string(ArrayInitializer)) == 0) {
    return ArrayInitializer;
  }
  if (strcmp(str, to_string(ArrayElement)) == 0) {
    return ArrayElement;
  }
  if (strcmp(str, to_string(ArrayElementList)) == 0) {
    return ArrayElementList;
  }
  if (strcmp(str, to_string(NonVirtualCallName)) == 0) {
    return NonVirtualCallName;
  }
  if (strcmp(str, to_string(OperatorFunctionName)) == 0) {
    return OperatorFunctionName;
  }
  if (strcmp(str, to_string(PrimaryExpr)) == 0) {
    return PrimaryExpr;
  }
  if (strcmp(str, to_string(PostfixExpr)) == 0) {
    return PostfixExpr;
  }
  if (strcmp(str, to_string(T3)) == 0) {
    return T3;
  }
  if (strcmp(str, to_string(T4)) == 0) {
    return T4;
  }
  if (strcmp(str, to_string(T5)) == 0) {
    return T5;
  }
  if (strcmp(str, to_string(T6)) == 0) {
    return T6;
  }
  if (strcmp(str, to_string(T7)) == 0) {
    return T7;
  }
  if (strcmp(str, to_string(T8)) == 0) {
    return T8;
  }
  if (strcmp(str, to_string(T9)) == 0) {
    return T9;
  }
  if (strcmp(str, to_string(T10)) == 0) {
    return T10;
  }
  if (strcmp(str, to_string(T11)) == 0) {
    return T11;
  }
  if (strcmp(str, to_string(T12)) == 0) {
    return T12;
  }
  if (strcmp(str, to_string(T13)) == 0) {
    return T13;
  }
  if (strcmp(str, to_string(T14)) == 0) {
    return T14;
  }
  if (strcmp(str, to_string(T15)) == 0) {
    return T15;
  }
  if (strcmp(str, to_string(T16)) == 0) {
    return T16;
  }
  if (strcmp(str, to_string(identifier)) == 0) {
    return identifier;
  }
  if (strcmp(str, to_string(null_literal)) == 0) {
    return null_literal;
  }
  if (strcmp(str, to_string(bool_literal)) == 0) {
    return bool_literal;
  }
  if (strcmp(str, to_string(integer_literal)) == 0) {
    return integer_literal;
  }
  if (strcmp(str, to_string(character_literal)) == 0) {
    return character_literal;
  }
  if (strcmp(str, to_string(float_literal)) == 0) {
    return float_literal;
  }
  if (strcmp(str, to_string(string_literal)) == 0) {
    return string_literal;
  }
  if (strcmp(str, to_string(move_)) == 0) {
    return move_;
  }
  if (strcmp(str, to_string(operator_)) == 0) {
    return operator_;
  }
  if (strcmp(str, to_string(this_)) == 0) {
    return this_;
  }
  if (strcmp(str, to_string(ctor_)) == 0) {
    return ctor_;
  }
  if (strcmp(str, to_string(dtor_)) == 0) {
    return dtor_;
  }
  if (strcmp(str, to_string(nonvirtual_)) == 0) {
    return nonvirtual_;
  }
  if (strcmp(str, to_string(period)) == 0) {
    return period;
  }
  if (strcmp(str, to_string(arrow)) == 0) {
    return arrow;
  }
  if (strcmp(str, to_string(amp)) == 0) {
    return amp;
  }
  if (strcmp(str, to_string(ampamp)) == 0) {
    return ampamp;
  }
  if (strcmp(str, to_string(star)) == 0) {
    return star;
  }
  if (strcmp(str, to_string(plus)) == 0) {
    return plus;
  }
  if (strcmp(str, to_string(plusplus)) == 0) {
    return plusplus;
  }
  if (strcmp(str, to_string(minus)) == 0) {
    return minus;
  }
  if (strcmp(str, to_string(minusminus)) == 0) {
    return minusminus;
  }
  if (strcmp(str, to_string(tilde)) == 0) {
    return tilde;
  }
  if (strcmp(str, to_string(exclaim)) == 0) {
    return exclaim;
  }
  if (strcmp(str, to_string(exclaimequal)) == 0) {
    return exclaimequal;
  }
  if (strcmp(str, to_string(slash)) == 0) {
    return slash;
  }
  if (strcmp(str, to_string(percent)) == 0) {
    return percent;
  }
  if (strcmp(str, to_string(less)) == 0) {
    return less;
  }
  if (strcmp(str, to_string(lessless)) == 0) {
    return lessless;
  }
  if (strcmp(str, to_string(lessequal)) == 0) {
    return lessequal;
  }
  if (strcmp(str, to_string(greater)) == 0) {
    return greater;
  }
  if (strcmp(str, to_string(greatergreater)) == 0) {
    return greatergreater;
  }
  if (strcmp(str, to_string(greaterequal)) == 0) {
    return greaterequal;
  }
  if (strcmp(str, to_string(caret)) == 0) {
    return caret;
  }
  if (strcmp(str, to_string(pipe)) == 0) {
    return pipe;
  }
  if (strcmp(str, to_string(pipepipe)) == 0) {
    return pipepipe;
  }
  if (strcmp(str, to_string(question)) == 0) {
    return question;
  }
  if (strcmp(str, to_string(colon)) == 0) {
    return colon;
  }
  if (strcmp(str, to_string(colonequal)) == 0) {
    return colonequal;
  }
  if (strcmp(str, to_string(equal)) == 0) {
    return equal;
  }
  if (strcmp(str, to_string(plusequal)) == 0) {
    return plusequal;
  }
  if (strcmp(str, to_string(minusequal)) == 0) {
    return minusequal;
  }
  if (strcmp(str, to_string(starequal)) == 0) {
    return starequal;
  }
  if (strcmp(str, to_string(slashequal)) == 0) {
    return slashequal;
  }
  if (strcmp(str, to_string(percentequal)) == 0) {
    return percentequal;
  }
  if (strcmp(str, to_string(lesslessequal)) == 0) {
    return lesslessequal;
  }
  if (strcmp(str, to_string(greatergreaterequal)) == 0) {
    return greatergreaterequal;
  }
  if (strcmp(str, to_string(ampequal)) == 0) {
    return ampequal;
  }
  if (strcmp(str, to_string(caretequal)) == 0) {
    return caretequal;
  }
  if (strcmp(str, to_string(pipeequal)) == 0) {
    return pipeequal;
  }
  if (strcmp(str, to_string(equalequal)) == 0) {
    return equalequal;
  }
  if (strcmp(str, to_string(comma)) == 0) {
    return comma;
  }
  if (strcmp(str, to_string(semi)) == 0) {
    return semi;
  }
  if (strcmp(str, to_string(l_square)) == 0) {
    return l_square;
  }
  if (strcmp(str, to_string(r_square)) == 0) {
    return r_square;
  }
  if (strcmp(str, to_string(l_paren)) == 0) {
    return l_paren;
  }
  if (strcmp(str, to_string(r_paren)) == 0) {
    return r_paren;
  }
  if (strcmp(str, to_string(l_brace)) == 0) {
    return l_brace;
  }
  if (strcmp(str, to_string(r_brace)) == 0) {
    return r_brace;
  }
  if (strcmp(str, to_string(type)) == 0) {
    return type;
  }
  if (strcmp(str, to_string($)) == 0) {
    return $;
  }
  throw std::logic_error("invalid symbol");
}

inline bool is_terminal(ExprGrammarSymbol symbol) { return symbol >= terminals_start && symbol < terminals_end; }

}  // namespace cw::expr

namespace cw::lang {

template <>
inline expr::ExprGrammarSymbol from_string<expr::ExprGrammarSymbol>(const char* str) {
  return from_string(expr::ExprGrammarSymbol{}, str);
}

}  // namespace cw::lang

namespace cw {

inline lang::ProductionVec<expr::ExprGrammarSymbol> ExprGrammarProductions() {
  lang::ProductionVec<expr::ExprGrammarSymbol> P;
  P("Expr", "T16");
  P("StringLiterals", "string_literal");
  P("StringLiterals", "StringLiterals", "string_literal");

  P("ID", "identifier");

  P("ArgumentList", "T16");
  P("ArgumentList", "ArgumentList", ",", "T16");

  P("ParenthesizedArgumentList", "(", ")");
  P("ParenthesizedArgumentList", "(", "ArgumentList", ")");

  P("ArrayElement", "T16");
  P("ArrayElement", "ArrayInitializer");
  P("ArrayElementList", "ArrayElement");
  P("ArrayElementList", "ArrayElementList", ",", "ArrayElement");
  P("ArrayInitializer", "{", "}");
  P("ArrayInitializer", "{", "ArrayElementList", "}");

  P("NonVirtualCallName", "nonvirtual", "identifier");

  P("OperatorFunctionName", "operator", "+");
  P("OperatorFunctionName", "operator", "-");
  P("OperatorFunctionName", "operator", "!");
  P("OperatorFunctionName", "operator", "*");
  P("OperatorFunctionName", "operator", "/");
  P("OperatorFunctionName", "operator", "%");
  P("OperatorFunctionName", "operator", "<");
  P("OperatorFunctionName", "operator", "<=");
  P("OperatorFunctionName", "operator", ">");
  P("OperatorFunctionName", "operator", ">=");
  P("OperatorFunctionName", "operator", "==");
  P("OperatorFunctionName", "operator", "!=");
  P("OperatorFunctionName", "operator", "=");
  P("OperatorFunctionName", "operator", "(", ")");

  P("PrimaryExpr", "ID");
  P("PrimaryExpr", "null");
  P("PrimaryExpr", "integer_literal");
  P("PrimaryExpr", "character_literal");
  P("PrimaryExpr", "float_literal");
  P("PrimaryExpr", "bool_literal");
  P("PrimaryExpr", "StringLiterals");
  P("PrimaryExpr", "this");
  P("PrimaryExpr", "(", "Expr", ")");
  P("PrimaryExpr", "type", "ArrayInitializer");

  P("PostfixExpr", "PrimaryExpr");
  P("PostfixExpr", "OperatorFunctionName", "ParenthesizedArgumentList");
  P("PostfixExpr", "PostfixExpr", "ParenthesizedArgumentList");
  P("PostfixExpr", "PostfixExpr", ".", "identifier");
  P("PostfixExpr", "PostfixExpr", "->", "identifier");
  P("PostfixExpr", "PostfixExpr", ".", "NonVirtualCallName", "ParenthesizedArgumentList");
  P("PostfixExpr", "PostfixExpr", "->", "NonVirtualCallName", "ParenthesizedArgumentList");
  P("PostfixExpr", "PostfixExpr", "[", "Expr", "]");
  P("PostfixExpr", "PostfixExpr", "++");
  P("PostfixExpr", "PostfixExpr", "--");
  P("PostfixExpr", "ctor", "(", "Expr", ")", "identifier", "ParenthesizedArgumentList");
  P("PostfixExpr", "dtor", "(", "Expr", ")", "identifier", "(", ")");
  P("PostfixExpr", "NonVirtualCallName", "ParenthesizedArgumentList");

  P("T3", "PostfixExpr");
  P("T3", "++", "T3");  // right associative
  P("T3", "--", "T3");  // right associative
  P("T3", "+", "T3");   // right associative
  P("T3", "-", "T3");   // right associative
  P("T3", "!", "T3");   // right associative
  P("T3", "~", "T3");   // right associative
  P("T3", "*", "T3");   // right associative
  P("T3", "&", "T3");   // right associative
  P("T3", "&", "OperatorFunctionName");
  P("T3", "move", "T3");  // right associative

  P("T4", "T3");
  // P("T4", "T4", ".*", "T3");  // left associative
  // P("T4", "T4", "->*", "T3");  // left associative

  P("T5", "T4");
  P("T5", "T5", "*", "T4");  // left associative
  P("T5", "T5", "/", "T4");  // left associative
  P("T5", "T5", "%", "T4");  // left associative

  P("T6", "T5");
  P("T6", "T6", "+", "T5");  // left associative
  P("T6", "T6", "-", "T5");  // left associative

  P("T7", "T6");
  P("T7", "T7", "<<", "T6");  // left associative
  P("T7", "T7", ">>", "T6");  // left associative

  P("T8", "T7");
  // P("T8", "T8", "<=>", "T7");  // left associative

  P("T9", "T8");
  P("T9", "T9", "<", "T8");   // left associative
  P("T9", "T9", "<=", "T8");  // left associative
  P("T9", "T9", ">", "T8");   // left associative
  P("T9", "T9", ">=", "T8");  // left associative

  P("T10", "T9");
  P("T10", "T10", "==", "T9");  // left associative
  P("T10", "T10", "!=", "T9");  // left associative

  P("T11", "T10");
  P("T11", "T11", "&", "T10");  // left associative

  P("T12", "T11");
  P("T12", "T12", "^", "T11");  // left associative

  P("T13", "T12");
  P("T13", "T13", "|", "T12");  // left associative

  P("T14", "T13");
  P("T14", "T14", "&&", "T13");  // left associative

  P("T15", "T14");
  P("T15", "T15", "||", "T14");  // left associative

  P("T16", "T15");
  P("T16", "T15", "?", "T16", ":", "T16");  // right associative
  P("T16", "T15", ":=", "T16");             // right associative
  P("T16", "T15", "=", "T16");              // right associative
  P("T16", "T15", "+=", "T16");             // right associative
  P("T16", "T15", "-=", "T16");             // right associative
  P("T16", "T15", "*=", "T16");             // right associative
  P("T16", "T15", "/=", "T16");             // right associative
  P("T16", "T15", "%=", "T16");             // right associative
  P("T16", "T15", "<<=", "T16");            // right associative
  P("T16", "T15", ">>=", "T16");            // right associative
  P("T16", "T15", "&=", "T16");             // right associative
  P("T16", "T15", "^=", "T16");             // right associative
  P("T16", "T15", "|=", "T16");             // right associative

  // T17 (comma expression) removed - comma only used as separator

  return P;
}

inline lang::Grammar ExprGrammar() {
  return lang::Grammar::Create("CW Expr Grammar", ExprGrammarProductions(), expr::ExprGrammarSymbol::num_symbols,
                               "Expr", "ε", "$");
}

}  // namespace cw
