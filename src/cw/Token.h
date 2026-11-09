/// \file Token.h
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstdint>
#include <string>
#include <variant>

#include <llvm/ADT/APFloat.h>
#include <llvm/ADT/APSInt.h>

#include "BuiltinTypes.h"
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
  identifier,  // abc_123, etc.

  // Constants
  null_literal,       // null
  bool_literal,       // true, false
  integer_literal,    // 123, 0xFF, etc.
  character_literal,  // 'a', '\n', etc.
  float_literal,      // 1.23f32, 0.0, etc.
  string_literal,     // "abc", etc.

  // Keyword operators
  move_,      // move value
  operator_,  // operator function name

  // Type keywords
  builtin_type,  // void, bool, i8, etc.

  // Reserved object expression
  this_,  // current object

  // Keyword-led calls
  ctor,         // ctor (address) T(arguments)
  dtor,         // dtor (address) T()
  nonvirtual_,  // explicit non-virtual named call

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
  coloncolon,           // ::
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

  // Keywords
  const_,      // const
  mut,         // mut
  copy,        // copy
  struct_,     // struct
  trivial_,    // trivial
  virtual_,    // virtual
  abstract_,   // abstract
  override_,   // override
  func,        // func
  var,         // var
  alias,       // alias
  namespace_,  // namespace
  export_,     // export
  import_,     // import
  if_,         // if
  else_,       // else
  while_,      // while
  for_,        // for
  break_,      // break
  continue_,   // continue
  return_,     // return

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

}  // namespace tok

struct BoolProperty {
  bool value{false};
};

struct IntegerProperty {
  llvm::APSInt value{1, true};
  BuiltinTypeKind suffix{};
};

struct CharacterProperty {
  uint8_t value{};
};

struct FloatProperty {
  llvm::APFloat value{llvm::APFloat::IEEEdouble()};
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
