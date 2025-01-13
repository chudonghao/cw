/// \file Token.h
/// \author Donghao Chu
/// \date 2025-01-06
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include <string>
#include <variant>

#include "SourceLocation.h"

namespace cw {

namespace tok {

// Token type
// 1. Keyword (one word, one code)
// 2. Identifier (multi-word, one code)
// 3. Constant (one type, one code)
// 4. Operator (one word, one code/one type, one code)
// 5. Separator (one word, one code)
enum TokenType {
  unknown,  // unknown
  comment,  // comment

  // Keywords
  struct_,    // struct
  func,       // func
  var,        // var
  align,      // align
  if_,        // if
  else_,      // else
  for_,       // for
  break_,     // break
  continue_,  // continue
  return_,    // return

  // Identifiers
  identifier,  // abc_123, etc.

  // Constants
  bool_,           // true, false
  integer,         // 123, 0u, etc.
  float_,          // 1.23f, 0.0, etc.
  string_literal,  // "abc", etc.

  // Operators
  period,        // .
  arrow,         // ->
  amp,           // &
  ampamp,        // &&
  star,          // *
  plus,          // +
  plusplus,      // ++
  minus,         // -
  minusminus,    // --
  tilde,         // ~
  exclaim,       // !
  exclaimequal,  // !=
  slash,         // /
  percent,       // %
  less,          // <
  lessequal,     // <=
  greater,       // >
  greaterequal,  // >=
  caret,         // ^
  pipe,          // |
  pipepipe,      // ||
  question,      // ?
  colon,         // :
  equal,         // =
  equalequal,    // ==
  comma,         // ,

  // Separators
  semi,      // ;
  l_square,  // [
  r_square,  // ]
  l_paren,   // (
  r_paren,   // )
  l_brace,   // {
  r_brace,   // }

  // Others
  blank,  // space \t
  eol,    // \r \n \r\n
  eof,    // EOF
};

const char *to_chars(tok::TokenType type);

tok::TokenType from_chars(const char *str);

}  // namespace tok

struct NoneProperty {};

struct BoolProperty {
  bool value{false};
};

struct IntegerProperty {
  bool sign{true};
  int precision{4};  // 1, 2, 4, 8
  long long value{0};
};

struct FloatProperty {
  int precision{8};  // 4, 8
  double value{0.0};
};

struct StringProperty {
  std::string value;
};

struct IdentifierProperty {
  std::string name;
};

class Token {
 public:
  using Property = std::variant<NoneProperty, IntegerProperty, FloatProperty, StringProperty, BoolProperty, IdentifierProperty>;

  SourceLocation location{};
  tok::TokenType type{};
  Property property{};

  Token() = default;
};

}  // namespace cw