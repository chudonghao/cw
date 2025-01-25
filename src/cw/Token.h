/// \file Token.h
/// \author Donghao Chu
/// \date 2025/01/06
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include <string>
#include <variant>

#include "Source.h"

#include "ExprGrammar.h"

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

  // Identifiers
  identifier = expr::identifier,  // abc_123, etc.

  // Constants
  bool_ = expr::bool_,                    // true, false
  integer = expr::integer,                // 123, 0u, 'a', etc.
  float_ = expr::float_,                  // 1.23f, 0.0, etc.
  string_literal = expr::string_literal,  // "abc", etc.

  // Operators
  period = expr::period,                            // .
  arrow = expr::arrow,                              // ->
  amp = expr::amp,                                  // &
  ampamp = expr::ampamp,                            // &&
  star = expr::star,                                // *
  plus = expr::plus,                                // +
  plusplus = expr::plusplus,                        // ++
  minus = expr::minus,                              // -
  minusminus = expr::minusminus,                    // --
  tilde = expr::tilde,                              // ~
  exclaim = expr::exclaim,                          // !
  exclaimequal = expr::exclaimequal,                // !=
  slash = expr::slash,                              // /
  percent = expr::percent,                          // %
  less = expr::less,                                // <
  lessequal = expr::lessequal,                      // <=
  lessless = expr::lessless,                        // <<
  greater = expr::greater,                          // >
  greaterequal = expr::greaterequal,                // >=
  greatergreater = expr::greatergreater,            // >>
  caret = expr::caret,                              // ^
  pipe = expr::pipe,                                // |
  pipepipe = expr::pipepipe,                        // ||
  question = expr::question,                        // ?
  colon = expr::colon,                              // :
  coloncolon = expr::coloncolon,                    // ::
  equal = expr::equal,                              // =
  plusequal = expr::plusequal,                      // +=
  minusequal = expr::minusequal,                    // -=
  starequal = expr::starequal,                      // *=
  slashequal = expr::slashequal,                    // /=
  percentequal = expr::percentequal,                // %=
  lesslessequal = expr::lesslessequal,              // <<=
  greatergreaterequal = expr::greatergreaterequal,  // >>=
  ampequal = expr::ampequal,                        // &=
  caretequal = expr::caretequal,                    // ^=
  pipeequal = expr::pipeequal,                      // |=
  equalequal = expr::equalequal,                    // ==
  comma = expr::comma,                              // ,

  // Separators
  semi = expr::semi,          // ;
  l_square = expr::l_square,  // [
  r_square = expr::r_square,  // ]
  l_paren = expr::l_paren,    // (
  r_paren = expr::r_paren,    // )
  l_brace = expr::l_brace,    // {
  r_brace = expr::r_brace,    // }

  // 语句
  NonExprTokenStart = expr::num_symbols,

  // Keywords
  struct_,    // struct
  virtual_,   // virtual
  func,       // func
  var,        // var
  alias,      // alias
  if_,        // if
  else_,      // else
  for_,       // for
  break_,     // break
  continue_,  // continue
  return_,    // return

  // Others
  comment,  // comment
  blank,    // space \t
  eol,      // \r \n \r\n
  eof,      // EOF
  eos,      // end of sources
};

const char *to_string(TokenType type);

TokenType from_string(const char *str);

inline bool IsBlankOrComment(TokenType type) { return type == comment || type == blank || type == eol || type == eof; }

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

  template <typename T>
  const T &get() const {
    return std::get<T>(property);
  }

  bool Valid() const { return type != tok::unknown; }
};

}  // namespace cw