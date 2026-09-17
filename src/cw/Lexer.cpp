/// \file Lexer.cpp
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "Lexer.h"

#include <utility>
#include <vector>

#include <boost/container/vector.hpp>
#include <boost/spirit/include/lex_lexertl.hpp>

#include "Literal.h"
#include "Source.h"
#include "Token.h"

namespace lex = boost::spirit::lex;

namespace cw {

namespace {

class CharIterator {
 public:
  using value_type = char;
  using reference = const char&;
  using pointer = const char*;
  using difference_type = std::ptrdiff_t;
  using iterator_category = std::forward_iterator_tag;

 private:
  const std::vector<cw::Source>* sources_{nullptr};
  int source_{-1};
  int pos_{0};
  int line_{0};
  int column_{0};

 public:
  CharIterator() = default;

  CharIterator(const std::vector<Source>* sources, int source, int pos)
      : sources_(sources), source_(source), pos_(pos), line_(0), column_(0) {
    Normalize();
  }

  static CharIterator begin(const std::vector<Source>* sources) {
    BOOST_ASSERT(sources);
    if (sources->empty()) {
      return end(sources);
    }
    return CharIterator(sources, 0, 0);
  }

  static CharIterator end(const std::vector<Source>* sources) {
    BOOST_ASSERT(sources);
    return CharIterator(sources, sources->size(), 0);
  }

  reference operator*() const {
    BOOST_ASSERT(sources_ && 0 <= source_ && source_ < static_cast<int>(sources_->size()));
    const auto& content = (*sources_)[source_].content;
    BOOST_ASSERT(0 <= pos_ && pos_ <= static_cast<int>(content.size()));
    // std::string exposes its terminating NUL at content[size()].
    return content[pos_];
  }

  pointer operator->() const {
    BOOST_ASSERT(sources_ && 0 <= source_ && source_ < static_cast<int>(sources_->size()));
    const auto& content = (*sources_)[source_].content;
    BOOST_ASSERT(0 <= pos_ && pos_ <= static_cast<int>(content.size()));
    // std::string exposes its terminating NUL at content[size()].
    return &content[pos_];
  }

  CharIterator& operator++() {
    BOOST_ASSERT(sources_ && 0 <= source_ && source_ < static_cast<int>(sources_->size()));

    const auto& content = (*sources_)[source_].content;
    if (pos_ < static_cast<int>(content.size())) {
      char ch = content[pos_];
      if (ch == '\n') {
        ++line_;
        column_ = 0;
      } else {
        ++column_;
      }
    }

    ++pos_;
    Normalize();
    return *this;
  }

  CharIterator operator++(int) {
    CharIterator tmp = *this;
    ++(*this);
    return tmp;
  }

  friend bool operator==(const CharIterator& lhs, const CharIterator& rhs) {
    if (lhs.sources_ != rhs.sources_) {
      return false;
    }
    if (lhs.source_ != rhs.source_) {
      return false;
    }
    return lhs.pos_ == rhs.pos_;
  }

  friend bool operator!=(const CharIterator& lhs, const CharIterator& rhs) { return !(lhs == rhs); }

  int Source() const { return source_; }
  int Pos() const { return pos_; }
  int Line() const { return line_; }
  int Column() const { return column_; }

 private:
  void Normalize() {
    if (!sources_ || source_ < 0) {
      return;
    }

    while (source_ < static_cast<int>(sources_->size())) {
      const auto& content = (*sources_)[source_].content;
      // Expose one NUL per file so the lexer emits eof before moving to the next source.
      if (pos_ <= static_cast<int>(content.size())) {
        break;
      }
      ++source_;
      pos_ = 0;
      line_ = 0;
      column_ = 0;
    }
  }
};

}  // namespace

struct MultiSourceLexer : lex::lexer<lex::lexertl::lexer<lex::lexertl::token<CharIterator>>> {
  MultiSourceLexer() {
    const auto& rules = this->self;

    // Line comments.
    rules.add(R"(\/\/[^\r\n]*)", tok::comment);

    // Literal spellings; decoding is deferred until a token is selected.
    rules.add(R"(true|false)", tok::bool_literal);
    rules.add(R"(0[bB][01]+)", tok::integer_literal);         // Binary: 0b1010
    rules.add(R"(0[oO][0-7]+)", tok::integer_literal);        // Octal: 0o755
    rules.add(R"(0[xX][0-9a-fA-F]+)", tok::integer_literal);  // Hex: 0xFF
    rules.add(R"([0-9]+)", tok::integer_literal);             // Decimal: 123
    rules.add(R"(\'([^'\\]|\\.+?)\')", tok::character_literal);
    rules.add(R"(([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)([eE][+-]?[0-9]+)?[fF]?)", tok::float_literal);
    rules.add(R"(\"([^"\\]|\\.)*\")", tok::string_literal);

    // Keywords precede identifiers so equal-length matches retain their keyword kind.
    rules.add(R"(null)", tok::null_literal);
    rules.add(R"(void)", tok::builtin_type);
    rules.add(R"(bool)", tok::builtin_type);
    rules.add(R"(i8)", tok::builtin_type);
    rules.add(R"(i16)", tok::builtin_type);
    rules.add(R"(i32)", tok::builtin_type);
    rules.add(R"(i64)", tok::builtin_type);
    rules.add(R"(u8)", tok::builtin_type);
    rules.add(R"(u16)", tok::builtin_type);
    rules.add(R"(u32)", tok::builtin_type);
    rules.add(R"(u64)", tok::builtin_type);
    rules.add(R"(f32)", tok::builtin_type);
    rules.add(R"(f64)", tok::builtin_type);
    rules.add(R"(isize)", tok::builtin_type);
    rules.add(R"(usize)", tok::builtin_type);
    rules.add(R"(const)", tok::const_);
    rules.add(R"(mut)", tok::mut);
    rules.add(R"(copy)", tok::copy);
    rules.add(R"(move)", tok::move_);
    rules.add(R"(this)", tok::this_);
    rules.add(R"(nonvirtual)", tok::nonvirtual_);
    rules.add(R"(struct)", tok::struct_);
    rules.add(R"(trivial)", tok::trivial_);
    rules.add(R"(virtual)", tok::virtual_);
    rules.add(R"(abstract)", tok::abstract_);
    rules.add(R"(override)", tok::override_);
    rules.add(R"(func)", tok::func);
    rules.add(R"(var)", tok::var);
    rules.add(R"(alias)", tok::alias);
    rules.add(R"(ctor)", tok::ctor);
    rules.add(R"(dtor)", tok::dtor);
    rules.add(R"(operator)", tok::operator_);
    rules.add(R"(if)", tok::if_);
    rules.add(R"(else)", tok::else_);
    rules.add(R"(while)", tok::while_);
    rules.add(R"(for)", tok::for_);
    rules.add(R"(break)", tok::break_);
    rules.add(R"(continue)", tok::continue_);
    rules.add(R"(return)", tok::return_);

    // Identifiers also accept non-ASCII source bytes.
    rules.add(R"([$_a-zA-Z\x80-\xFF][$_a-zA-Z0-9\x80-\xFF]*)", tok::identifier);

    // Operators.
    rules.add(R"(\~)", tok::tilde);
    rules.add(R"(\|\|)", tok::pipepipe);
    rules.add(R"(\|\=)", tok::pipeequal);
    rules.add(R"(\|)", tok::pipe);
    rules.add(R"(\^\=)", tok::caretequal);
    rules.add(R"(\^)", tok::caret);
    rules.add(R"(\?)", tok::question);
    rules.add(R"(\>\>\=)", tok::greatergreaterequal);
    rules.add(R"(\>\>)", tok::greatergreater);
    rules.add(R"(\>\=)", tok::greaterequal);
    rules.add(R"(\>)", tok::greater);
    rules.add(R"(\=\=)", tok::equalequal);
    rules.add(R"(\=)", tok::equal);
    rules.add(R"(\<\<\=)", tok::lesslessequal);
    rules.add(R"(\<\<)", tok::lessless);
    rules.add(R"(\<=)", tok::lessequal);
    rules.add(R"(\<)", tok::less);
    rules.add(R"(\:\=)", tok::colonequal);
    rules.add(R"(\:)", tok::colon);
    rules.add(R"(\/\=)", tok::slashequal);
    rules.add(R"(\/)", tok::slash);
    rules.add(R"(\.)", tok::period);
    rules.add(R"(\-\>)", tok::arrow);
    rules.add(R"(\-\=)", tok::minusequal);
    rules.add(R"(\-\-)", tok::minusminus);
    rules.add(R"(\-)", tok::minus);
    rules.add(R"(\,)", tok::comma);
    rules.add(R"(\+\=)", tok::plusequal);
    rules.add(R"(\+\+)", tok::plusplus);
    rules.add(R"(\+)", tok::plus);
    rules.add(R"(\*\=)", tok::starequal);
    rules.add(R"(\*)", tok::star);
    rules.add(R"(\&\=)", tok::ampequal);
    rules.add(R"(\&\&)", tok::ampamp);
    rules.add(R"(\&)", tok::amp);
    rules.add(R"(\%\=)", tok::percentequal);
    rules.add(R"(\%)", tok::percent);
    rules.add(R"(\!\=)", tok::exclaimequal);
    rules.add(R"(\!)", tok::exclaim);

    // Delimiters.
    rules.add(R"(\;)", tok::semi);
    rules.add(R"(\[)", tok::l_square);
    rules.add(R"(\])", tok::r_square);
    rules.add(R"(\()", tok::l_paren);
    rules.add(R"(\))", tok::r_paren);
    rules.add(R"(\{)", tok::l_brace);
    rules.add(R"(\})", tok::r_brace);

    // Whitespace and per-file boundaries.
    rules.add(R"([ \t\v\f]+)", tok::blank);
    rules.add(R"(\r?\n)", tok::eol);
    rules.add(R"(\0)", tok::eof);
    rules.add(R"(.)", tok::undefined);
  }
};

struct Lexer::Impl {
  MultiSourceLexer multi_source_lexer{};
  CharIterator char_iter{};
  CharIterator char_end{};
  MultiSourceLexer::iterator_type token_iter{};
  MultiSourceLexer::iterator_type token_end{};

  const std::vector<Source>* sources_{};
  cw::Token token{};

  const std::vector<Source>* Sources() const { return sources_; }

  void Reset(const std::vector<Source>* sources) {
    sources_ = sources;
    char_iter = CharIterator::begin(sources);
    char_end = CharIterator::end(sources);
    token_iter = multi_source_lexer.begin(char_iter, char_end);
    token_end = multi_source_lexer.end();

    TakeToken();
  }

  bool IterValid() { return token_iter != token_end; }

  tok::TokenType IterType() { return static_cast<tok::TokenType>(token_iter->id()); }

  void SkipBlankComment() {
    while (IterValid() && IsBlankOrComment(IterType())) {
      ++token_iter;
    }

    TakeToken();
  }

  void SkipLine() {
    for (; IterValid();) {
      bool is_line_end = IterType() == tok::eol || IterType() == tok::eof;

      ++token_iter;

      if (is_line_end) {
        break;
      }
    }

    TakeToken();
  }

  void Advance(bool skip_blank_comment) {
    if (IterValid()) {
      ++token_iter;
    }

    if (skip_blank_comment) {
      while (IterValid() && IsBlankOrComment(IterType())) {
        ++token_iter;
      }
    }

    TakeToken();
  }

  const cw::Token& Token() const { return token; }

 private:
  template <typename Property>
  static Token::Property ToTokenProperty(std::optional<Property> property) {
    if (property) {
      return Token::Property{std::move(*property)};
    }
    return std::monostate{};
  }

  static void UpdateTokenProperty(cw::Token& token) {
    switch (token.type) {
      case tok::identifier:
        token.property = IdentifierProperty{std::string(token.source_view)};
        break;
      case tok::bool_literal:
        token.property = ToTokenProperty(ParseBoolLiteral(token.source_view));
        break;
      case tok::integer_literal:
        token.property = ToTokenProperty(ParseIntegerLiteral(token.source_view));
        break;
      case tok::character_literal:
        token.property = ToTokenProperty(ParseCharacterLiteral(token.source_view));
        break;
      case tok::float_literal:
        token.property = ToTokenProperty(ParseFloatLiteral(token.source_view));
        break;
      case tok::string_literal:
        token.property = ToTokenProperty(ParseStringLiteral(token.source_view));
        break;
      case tok::builtin_type: {
        auto kind = cw::from_string(token.source_view);
        BOOST_ASSERT(kind != BuiltinTypeKind::Invalid);
        token.property = BuiltinTypeProperty{kind};
        break;
      }
      default:
        token.property = std::monostate{};
        break;
    }
  }

  void TakeToken() {
    // eof comes from each file's NUL; eos is synthesized after all sources are exhausted.
    if (IterValid()) {
      auto char_begin = token_iter->value().begin();
      auto char_end = token_iter->value().end();

      size_t size{};
      if (char_begin.Source() == char_end.Source()) {
        size = char_end.Pos() - char_begin.Pos();
      } else {
        BOOST_ASSERT(IterType() == tok::eof);
        size = 0;
      }

      token.range.begin.file = char_begin.Source();
      token.range.begin.pos = char_begin.Pos();
      token.range.begin.line = char_begin.Line();
      token.range.begin.column = char_begin.Column();
      token.range.end.file = char_end.Source();
      token.range.end.pos = char_end.Pos();
      token.range.end.line = char_end.Line();
      token.range.end.column = char_end.Column();

      token.source_view = std::string_view(&*char_begin, size);

      token.type = IterType();
    } else {
      token.range.begin.file = char_iter.Source();
      token.range.begin.pos = char_iter.Pos();
      token.range.begin.line = char_iter.Line();
      token.range.begin.column = char_iter.Column();
      token.range.end.file = char_end.Source();
      token.range.end.pos = char_end.Pos();
      token.range.end.line = char_end.Line();
      token.range.end.column = char_end.Column();

      token.source_view = std::string_view();

      token.type = tok::eos;
    }
    UpdateTokenProperty(token);
  }
};

Lexer::Lexer() : impl_{std::make_unique<Impl>()} {}

Lexer::~Lexer() = default;

const std::vector<Source>* Lexer::Sources() const { return impl_->Sources(); }

void Lexer::Reset(const std::vector<Source>* sources) { impl_->Reset(sources); }

void Lexer::SkipBlankComment() { impl_->SkipBlankComment(); }

void Lexer::SkipLine() { impl_->SkipLine(); }

void Lexer::Advance() { impl_->Advance(true); }

void Lexer::Advance(bool skip_blank_comment) { impl_->Advance(skip_blank_comment); }

const Token& Lexer::Token() const { return impl_->Token(); }

}  // namespace cw
