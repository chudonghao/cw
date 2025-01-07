/// \file Token.cpp
/// \author Donghao Chu
/// \date 2025-01-06
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include "Token.h"

#include <cstring>

namespace cw {
namespace tok {

const char *to_chars(tok::TokenType type) {
  switch (type) {
    case unknown:
      return "unknown";
    case comment:
      return "comment";
    case struct_:
      return "struct";
    case func:
      return "func";
    case var:
      return "var";
    case align:
      return "align";
    case if_:
      return "if";
    case else_:
      return "else";
    case for_:
      return "for";
    case break_:
      return "break";
    case continue_:
      return "continue";
    case return_:
      return "return";
    case identifier:
      return "identifier";
    case bool_:
      return "bool";
    case integer:
      return "integer";
    case float_:
      return "float";
    case string_literal:
      return "string_literal";
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
    case lessequal:
      return "<=";
    case greater:
      return ">";
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
    case equal:
      return "=";
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
    case blank:
      return "blank";
    case eol:
      return "eol";
    case eof:
      return "eof";
  }
  return "unknown";
}

tok::TokenType from_chars(const char *str) {
  if (strcmp(str, "unknown") == 0) return tok::unknown;
  if (strcmp(str, "comment") == 0) return tok::comment;
  if (strcmp(str, "struct") == 0) return tok::struct_;
  if (strcmp(str, "func") == 0) return tok::func;
  if (strcmp(str, "var") == 0) return tok::var;
  if (strcmp(str, "align") == 0) return tok::align;
  if (strcmp(str, "if") == 0) return tok::if_;
  if (strcmp(str, "else") == 0) return tok::else_;
  if (strcmp(str, "for") == 0) return tok::for_;
  if (strcmp(str, "break") == 0) return tok::break_;
  if (strcmp(str, "continue") == 0) return tok::continue_;
  if (strcmp(str, "return") == 0) return tok::return_;
  if (strcmp(str, "identifier") == 0) return tok::identifier;
  if (strcmp(str, "bool") == 0) return tok::bool_;
  if (strcmp(str, "integer") == 0) return tok::integer;
  if (strcmp(str, "float") == 0) return tok::float_;
  if (strcmp(str, "string_literal") == 0) return tok::string_literal;
  if (strcmp(str, ".") == 0) return tok::period;
  if (strcmp(str, "->") == 0) return tok::arrow;
  if (strcmp(str, "&") == 0) return tok::amp;
  if (strcmp(str, "&&") == 0) return tok::ampamp;
  if (strcmp(str, "*") == 0) return tok::star;
  if (strcmp(str, "+") == 0) return tok::plus;
  if (strcmp(str, "++") == 0) return tok::plusplus;
  if (strcmp(str, "-") == 0) return tok::minus;
  if (strcmp(str, "--") == 0) return tok::minusminus;
  if (strcmp(str, "~") == 0) return tok::tilde;
  if (strcmp(str, "!") == 0) return tok::exclaim;
  if (strcmp(str, "!=") == 0) return tok::exclaimequal;
  if (strcmp(str, "/") == 0) return tok::slash;
  if (strcmp(str, "%") == 0) return tok::percent;
  if (strcmp(str, "<") == 0) return tok::less;
  if (strcmp(str, "<=") == 0) return tok::lessequal;
  if (strcmp(str, ">") == 0) return tok::greater;
  if (strcmp(str, ">=") == 0) return tok::greaterequal;
  if (strcmp(str, "^") == 0) return tok::caret;
  if (strcmp(str, "|") == 0) return tok::pipe;
  if (strcmp(str, "||") == 0) return tok::pipepipe;
  if (strcmp(str, "?") == 0) return tok::question;
  if (strcmp(str, ":") == 0) return tok::colon;
  if (strcmp(str, "=") == 0) return tok::equal;
  if (strcmp(str, "==") == 0) return tok::equalequal;
  if (strcmp(str, ",") == 0) return tok::comma;
  if (strcmp(str, ";") == 0) return tok::semi;
  if (strcmp(str, "[") == 0) return tok::l_square;
  if (strcmp(str, "]") == 0) return tok::r_square;
  if (strcmp(str, "(") == 0) return tok::l_paren;
  if (strcmp(str, ")") == 0) return tok::r_paren;
  if (strcmp(str, "{") == 0) return tok::l_brace;
  if (strcmp(str, "}") == 0) return tok::r_brace;
  if (strcmp(str, "blank") == 0) return tok::blank;
  if (strcmp(str, "eol") == 0) return tok::eol;
  if (strcmp(str, "eof") == 0) return tok::eof;
  return tok::unknown;
}

}  // namespace tok
}  // namespace cw