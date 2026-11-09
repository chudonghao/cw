/// \file Lexer.cpp
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "Lexer.h"

#include <string>
#include <string_view>
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

/// \brief Iterates over one source file's content, tracking the line and column of each position.
class CharIterator {
 public:
  using value_type = char;
  using reference = const char&;
  using pointer = const char*;
  using difference_type = std::ptrdiff_t;
  using iterator_category = std::forward_iterator_tag;

 private:
  const std::string* content_{};
  int source_{-1};
  int pos_{0};
  int line_{0};
  int column_{0};

 public:
  CharIterator() = default;

  CharIterator(const std::string& content, int source, int pos) : content_(&content), source_(source), pos_(pos) {}

  reference operator*() const {
    BOOST_ASSERT(content_ && 0 <= pos_ && pos_ < static_cast<int>(content_->size()));
    return (*content_)[pos_];
  }

  pointer operator->() const { return &**this; }

  CharIterator& operator++() {
    if (**this == '\n') {
      ++line_;
      column_ = 0;
    } else {
      ++column_;
    }
    ++pos_;
    return *this;
  }

  CharIterator operator++(int) {
    CharIterator tmp = *this;
    ++(*this);
    return tmp;
  }

  friend bool operator==(const CharIterator& lhs, const CharIterator& rhs) {
    return lhs.content_ == rhs.content_ && lhs.pos_ == rhs.pos_;
  }

  friend bool operator!=(const CharIterator& lhs, const CharIterator& rhs) { return !(lhs == rhs); }

  int Pos() const { return pos_; }
  SourceLocation Location() const { return {source_, pos_, line_, column_}; }
};

/// \brief Whitespace, comments and line breaks only separate tokens and are never returned.
bool IsTrivia(tok::TokenType type) { return type == tok::comment || type == tok::blank || type == tok::eol; }

struct LexerRules : lex::lexer<lex::lexertl::lexer<lex::lexertl::token<CharIterator>>> {
  LexerRules() {
    const auto& rules = this->self;

    // Line comments.
    rules.add(R"(\/\/[^\r\n\0]*)", tok::comment);

    // Literal spellings; decoding is deferred until a token is selected.
    rules.add(R"(true|false)", tok::bool_literal);
    rules.add(R"(0[bB][01]+([iu](8|16|32|64)|isize|usize)?)", tok::integer_literal);         // Binary: 0b1010
    rules.add(R"(0[oO][0-7]+([iu](8|16|32|64)|isize|usize)?)", tok::integer_literal);        // Octal: 0o755
    rules.add(R"(0[xX][0-9a-fA-F]+([iu](8|16|32|64)|isize|usize)?)", tok::integer_literal);  // Hex: 0xFF
    rules.add(R"([0-9]+([iu](8|16|32|64)|isize|usize)?)", tok::integer_literal);             // Decimal: 123
    rules.add(R"(\'([^'\\\0]|\\[^\n\0]+?)\')", tok::character_literal);
    rules.add(R"((([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)([eE][+\-]?[0-9]+)?|[0-9]+[eE][+\-]?[0-9]+)(f32|f64)?)",
              tok::float_literal);
    rules.add(R"(\"([^"\\\0]|\\[^\n\0])*\")", tok::string_literal);

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
    rules.add(R"(namespace)", tok::namespace_);
    rules.add(R"(export)", tok::export_);
    rules.add(R"(import)", tok::import_);
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
    rules.add(R"(\:\:)", tok::coloncolon);
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

    // Whitespace. U+0000 is not a source character anywhere, so comments and literals above stop before it.
    rules.add(R"([ \t\v\f]+)", tok::blank);
    rules.add(R"(\r?\n)", tok::eol);
    rules.add(R"(\0)", tok::undefined);
    rules.add(R"(.)", tok::undefined);
  }
};

/// \brief Returns the rules shared by every Lexer; lexertl builds their state machine once, on first use.
const LexerRules& GetLexerRules() {
  static const LexerRules rules;
  return rules;
}

}  // namespace

struct Lexer::Impl {
  const std::vector<Source>* sources_{};
  int source_{};              ///< Source being lexed; equals the source count once all are exhausted.
  CharIterator char_iter_{};  ///< Position within the current source; token_iter_ advances it.
  CharIterator char_end_{};   ///< End of the current source's content.
  LexerRules::iterator_type token_iter_{};
  LexerRules::iterator_type token_end_{};
  SourceLocation source_end_{};  ///< End of the last token consumed in the current source.
  cw::Token token_{};

  const std::vector<Source>* Sources() const { return sources_; }

  void Reset(const std::vector<Source>* sources) {
    BOOST_ASSERT(sources);
    sources_ = sources;
    StartSource(0);
    SkipTrivia();
    TakeToken();
  }

  void Advance() {
    if (AtEndOfSources()) {
      return;
    }
    if (token_iter_ != token_end_) {
      Step();
    } else {
      // Only an explicit advance leaves a source's eof for the next source.
      StartSource(source_ + 1);
    }
    SkipTrivia();
    TakeToken();
  }

  const cw::Token& Token() const { return token_; }

 private:
  bool AtEndOfSources() const { return !sources_ || source_ >= static_cast<int>(sources_->size()); }

  tok::TokenType IterType() const { return static_cast<tok::TokenType>(token_iter_->id()); }

  void StartSource(int source) {
    source_ = source;
    token_iter_ = token_end_ = {};
    if (AtEndOfSources()) {
      return;
    }
    const std::string& content = (*sources_)[source_].content;
    char_iter_ = CharIterator(content, source_, 0);
    char_end_ = CharIterator(content, source_, static_cast<int>(content.size()));
    token_iter_ = GetLexerRules().begin(char_iter_, char_end_);
    token_end_ = GetLexerRules().end();
    source_end_ = char_iter_.Location();
  }

  void Step() {
    source_end_ = token_iter_->value().end().Location();
    ++token_iter_;
  }

  void SkipTrivia() {
    while (token_iter_ != token_end_ && IsTrivia(IterType())) {
      Step();
    }
  }

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
    if (AtEndOfSources()) {
      // eos follows the last source's eof and is anchored past the last source.
      const SourceLocation end{sources_ ? static_cast<int>(sources_->size()) : 0, 0, 0, 0};
      token_.range = {end, end};
      token_.source_view = std::string_view();
      token_.type = tok::eos;
    } else if (token_iter_ == token_end_) {
      // Each source ends with one zero-width eof after its last token.
      const std::string& content = (*sources_)[source_].content;
      token_.range = {source_end_, source_end_};
      token_.source_view = std::string_view(content.data() + content.size(), 0);
      token_.type = tok::eof;
    } else {
      const auto& value = token_iter_->value();
      token_.range = {value.begin().Location(), value.end().Location()};
      token_.source_view = std::string_view(&*value.begin(), value.end().Pos() - value.begin().Pos());
      token_.type = IterType();
    }
    UpdateTokenProperty(token_);
  }
};

Lexer::Lexer() : impl_{std::make_unique<Impl>()} {}

Lexer::~Lexer() = default;

const std::vector<Source>* Lexer::Sources() const { return impl_->Sources(); }

void Lexer::Reset(const std::vector<Source>* sources) { impl_->Reset(sources); }

void Lexer::Advance() { impl_->Advance(); }

const Token& Lexer::Token() const { return impl_->Token(); }

}  // namespace cw
