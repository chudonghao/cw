/// \file Token.h
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstdint>
#include <string>
#include <variant>

#include <boost/multiprecision/cpp_int.hpp>

#include "BuiltinTypes.h"
#include "ExprGrammar.h"
#include "Source.h"

namespace cw {

namespace tok {

// Token type
// 1. Keyword (one category, one code)
// 2. Identifier (multi-word, one code)
// 3. Constant (one type, one code)
// 4. Operator (one word, one code/one type, one code)
// 5. Separator (one word, one code)
enum TokenType {
  invalid,  // invalid

  // Identifiers
  identifier = expr::identifier,  // abc_123, etc.

  // Constants
  null_literal = expr::null_literal,            // null
  bool_literal = expr::bool_literal,            // true, false
  integer_literal = expr::integer_literal,      // 123, 0xFF, etc.
  character_literal = expr::character_literal,  // 'a', '\n', etc.
  float_literal = expr::float_literal,          // 1.23f, 0.0, etc.
  string_literal = expr::string_literal,        // "abc", etc.

  // Keyword operators
  move_ = expr::move_,          // move value
  operator_ = expr::operator_,  // operator function name

  // Reserved object expression
  this_ = expr::this_,  // current object

  // Keyword-led calls
  ctor = expr::ctor_,               // ctor (address) T(arguments)
  dtor = expr::dtor_,               // dtor (address) T()
  nonvirtual_ = expr::nonvirtual_,  // explicit non-virtual named call

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
  colonequal = expr::colonequal,                    // :=
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

  // Statement keywords.
  NonExprTokenStart = expr::num_symbols,

  // Keywords
  builtin_type,  // void, bool, i8, etc.
  const_,        // const
  mut,           // mut
  copy,          // copy
  struct_,       // struct
  trivial_,      // trivial
  virtual_,      // virtual
  abstract_,     // abstract
  override_,     // override
  func,          // func
  var,           // var
  alias,         // alias
  if_,           // if
  else_,         // else
  while_,        // while
  for_,          // for
  break_,        // break
  continue_,     // continue
  return_,       // return

  // Others
  comment,  // comment
  blank,    // space \t
  eol,      // \r \n \r\n
  eof,      // EOF
  eos,      // end of sources

  undefined = 0xffff,  // undefined
};

const char* to_string(TokenType type);

TokenType from_string(const char* str);

inline bool IsBlankOrComment(TokenType type) { return type == comment || type == blank || type == eol || type == eof; }

}  // namespace tok

struct BoolProperty {
  bool value{false};
};

struct IntegerProperty {
  boost::multiprecision::cpp_int value{};
};

struct CharacterProperty {
  uint8_t value{};
};

struct FloatProperty {
  std::variant<std::monostate, float, double> value{};
};

struct StringProperty {
  std::string value;
};

struct IdentifierProperty {
  std::string name;
};

/// \brief Property carrying the kind of a built-in type keyword.
struct BuiltinTypeProperty {
  BuiltinTypeKind kind{};
};

class Token {
 public:
  using Property = std::variant<std::monostate, IntegerProperty, CharacterProperty, FloatProperty, StringProperty,
                                BoolProperty, IdentifierProperty, BuiltinTypeProperty>;

  /// Half-open character source range.
  SourceRange range{};
  /// Source text covered by this token.
  std::string_view source_view{};
  /// Token kind.
  tok::TokenType type{};
  /// Parsed token property.
  Property property{};

  Token() = default;

  template <typename T>
  const T& get() const {
    return std::get<T>(property);
  }

  bool Valid() const { return type != tok::invalid; }
};

}  // namespace cw
