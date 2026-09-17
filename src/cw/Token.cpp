/// \file Token.cpp
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "Token.h"

#include <cstring>

namespace cw {
namespace tok {

const char* to_string(TokenType type) {
  switch (type) {
    case invalid:
      return "invalid";
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
    case this_:
      return "this";
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
    case lessequal:
      return "<=";
    case lessless:
      return "<<";
    case greater:
      return ">";
    case greaterequal:
      return ">=";
    case greatergreater:
      return ">>";
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
    case builtin_type:
      return "builtin_type";
    case const_:
      return "const";
    case mut:
      return "mut";
    case copy:
      return "copy";
    case comment:
      return "comment";
    case struct_:
      return "struct";
    case trivial_:
      return "trivial";
    case virtual_:
      return "virtual";
    case abstract_:
      return "abstract";
    case override_:
      return "override";
    case func:
      return "func";
    case var:
      return "var";
    case alias:
      return "alias";
    case ctor:
      return "ctor";
    case dtor:
      return "dtor";
    case operator_:
      return "operator";
    case if_:
      return "if";
    case else_:
      return "else";
    case while_:
      return "while";
    case for_:
      return "for";
    case break_:
      return "break";
    case continue_:
      return "continue";
    case return_:
      return "return";
    case blank:
      return "blank";
    case eol:
      return "eol";
    case eof:
      return "eof";
    case eos:
      return "eos";
    case undefined:
      return "undefined";
    default:
      return "unknown";
  }
}

TokenType from_string(const char* str) {
  if (!str) {
    return invalid;
  }

  if (strcmp(str, "identifier") == 0) {
    return identifier;
  }
  if (strcmp(str, "null") == 0) {
    return null_literal;
  }
  if (strcmp(str, "bool_literal") == 0) {
    return bool_literal;
  }
  if (strcmp(str, "integer_literal") == 0) {
    return integer_literal;
  }
  if (strcmp(str, "character_literal") == 0) {
    return character_literal;
  }
  if (strcmp(str, "float_literal") == 0) {
    return float_literal;
  }
  if (strcmp(str, "string_literal") == 0) {
    return string_literal;
  }
  if (strcmp(str, "move") == 0) {
    return move_;
  }
  if (strcmp(str, "this") == 0) {
    return this_;
  }
  if (strcmp(str, "nonvirtual") == 0) {
    return nonvirtual_;
  }
  if (strcmp(str, ".") == 0) {
    return period;
  }
  if (strcmp(str, "->") == 0) {
    return arrow;
  }
  if (strcmp(str, "&") == 0) {
    return amp;
  }
  if (strcmp(str, "&&") == 0) {
    return ampamp;
  }
  if (strcmp(str, "*") == 0) {
    return star;
  }
  if (strcmp(str, "+") == 0) {
    return plus;
  }
  if (strcmp(str, "++") == 0) {
    return plusplus;
  }
  if (strcmp(str, "-") == 0) {
    return minus;
  }
  if (strcmp(str, "--") == 0) {
    return minusminus;
  }
  if (strcmp(str, "~") == 0) {
    return tilde;
  }
  if (strcmp(str, "!") == 0) {
    return exclaim;
  }
  if (strcmp(str, "!=") == 0) {
    return exclaimequal;
  }
  if (strcmp(str, "/") == 0) {
    return slash;
  }
  if (strcmp(str, "%") == 0) {
    return percent;
  }
  if (strcmp(str, "<") == 0) {
    return less;
  }
  if (strcmp(str, "<=") == 0) {
    return lessequal;
  }
  if (strcmp(str, "<<") == 0) {
    return lessless;
  }
  if (strcmp(str, ">") == 0) {
    return greater;
  }
  if (strcmp(str, ">=") == 0) {
    return greaterequal;
  }
  if (strcmp(str, ">>") == 0) {
    return greatergreater;
  }
  if (strcmp(str, "^") == 0) {
    return caret;
  }
  if (strcmp(str, "|") == 0) {
    return pipe;
  }
  if (strcmp(str, "||") == 0) {
    return pipepipe;
  }
  if (strcmp(str, "?") == 0) {
    return question;
  }
  if (strcmp(str, ":") == 0) {
    return colon;
  }
  if (strcmp(str, ":=") == 0) {
    return colonequal;
  }
  if (strcmp(str, "=") == 0) {
    return equal;
  }
  if (strcmp(str, "+=") == 0) {
    return plusequal;
  }
  if (strcmp(str, "-=") == 0) {
    return minusequal;
  }
  if (strcmp(str, "*=") == 0) {
    return starequal;
  }
  if (strcmp(str, "/=") == 0) {
    return slashequal;
  }
  if (strcmp(str, "%=") == 0) {
    return percentequal;
  }
  if (strcmp(str, "<<=") == 0) {
    return lesslessequal;
  }
  if (strcmp(str, ">>=") == 0) {
    return greatergreaterequal;
  }
  if (strcmp(str, "&=") == 0) {
    return ampequal;
  }
  if (strcmp(str, "^=") == 0) {
    return caretequal;
  }
  if (strcmp(str, "|=") == 0) {
    return pipeequal;
  }
  if (strcmp(str, "==") == 0) {
    return equalequal;
  }
  if (strcmp(str, ",") == 0) {
    return comma;
  }
  if (strcmp(str, ";") == 0) {
    return semi;
  }
  if (strcmp(str, "[") == 0) {
    return l_square;
  }
  if (strcmp(str, "]") == 0) {
    return r_square;
  }
  if (strcmp(str, "(") == 0) {
    return l_paren;
  }
  if (strcmp(str, ")") == 0) {
    return r_paren;
  }
  if (strcmp(str, "{") == 0) {
    return l_brace;
  }
  if (strcmp(str, "}") == 0) {
    return r_brace;
  }
  if (strcmp(str, "builtin_type") == 0) {
    return builtin_type;
  }
  if (strcmp(str, "const") == 0) {
    return const_;
  }
  if (strcmp(str, "mut") == 0) {
    return mut;
  }
  if (strcmp(str, "copy") == 0) {
    return copy;
  }
  if (strcmp(str, "comment") == 0) {
    return comment;
  }
  if (strcmp(str, "struct") == 0) {
    return struct_;
  }
  if (strcmp(str, "trivial") == 0) {
    return trivial_;
  }
  if (strcmp(str, "virtual") == 0) {
    return virtual_;
  }
  if (strcmp(str, "abstract") == 0) {
    return abstract_;
  }
  if (strcmp(str, "override") == 0) {
    return override_;
  }
  if (strcmp(str, "func") == 0) {
    return func;
  }
  if (strcmp(str, "var") == 0) {
    return var;
  }
  if (strcmp(str, "alias") == 0) {
    return alias;
  }
  if (strcmp(str, "ctor") == 0) {
    return ctor;
  }
  if (strcmp(str, "dtor") == 0) {
    return dtor;
  }
  if (strcmp(str, "operator") == 0) {
    return operator_;
  }
  if (strcmp(str, "if") == 0) {
    return if_;
  }
  if (strcmp(str, "else") == 0) {
    return else_;
  }
  if (strcmp(str, "while") == 0) {
    return while_;
  }
  if (strcmp(str, "for") == 0) {
    return for_;
  }
  if (strcmp(str, "break") == 0) {
    return break_;
  }
  if (strcmp(str, "continue") == 0) {
    return continue_;
  }
  if (strcmp(str, "return") == 0) {
    return return_;
  }
  if (strcmp(str, "blank") == 0) {
    return blank;
  }
  if (strcmp(str, "eol") == 0) {
    return eol;
  }
  if (strcmp(str, "eof") == 0) {
    return eof;
  }
  if (strcmp(str, "eos") == 0) {
    return eos;
  }

  return invalid;
}

}  // namespace tok
}  // namespace cw
