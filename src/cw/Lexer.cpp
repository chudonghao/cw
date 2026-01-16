/// \file Lexer.cpp
/// \author Donghao Chu
/// \date 2025/01/10
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "Lexer.h"

#include <vector>

#include <boost/container/vector.hpp>
#include <boost/spirit/include/lex_lexertl.hpp>

#include "Source.h"
#include "Token.h"

#include "cw/Token.h"

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

  CharIterator() = default;

  CharIterator(const std::vector<Source>* sources, int source, int pos) : sources_(sources), source_(source), pos_(pos), line_(0), column_(0) { Normalize(); }

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
    // C++ 标准保证 content[size()] == '\0'
    return content[pos_];
  }

  pointer operator->() const {
    BOOST_ASSERT(sources_ && 0 <= source_ && source_ < static_cast<int>(sources_->size()));
    const auto& content = (*sources_)[source_].content;
    BOOST_ASSERT(0 <= pos_ && pos_ <= static_cast<int>(content.size()));
    // C++ 标准保证 content[size()] == '\0'
    return &content[pos_];
  }

  CharIterator& operator++() {
    BOOST_ASSERT(sources_ && 0 <= source_ && source_ < static_cast<int>(sources_->size()));

    // 更新行号和列号
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
    if (lhs.sources_ != rhs.sources_) return false;
    if (lhs.source_ != rhs.source_) return false;
    return lhs.pos_ == rhs.pos_;
  }

  friend bool operator!=(const CharIterator& lhs, const CharIterator& rhs) { return !(lhs == rhs); }

  int Source() const { return source_; }
  int Pos() const { return pos_; }
  int Line() const { return line_; }
  int Column() const { return column_; }

 private:
  void Normalize() {
    if (!sources_ || source_ < 0) return;

    while (source_ < static_cast<int>(sources_->size())) {
      const auto& content = (*sources_)[source_].content;
      // 允许 pos_ 指向 size() 位置（表示文件末尾的 '\0'）
      if (pos_ <= static_cast<int>(content.size())) {
        break;
      }
      // 切换到下一个源文件，重置位置和行列号
      ++source_;
      pos_ = 0;
      line_ = 0;
      column_ = 0;
    }
  }

  const std::vector<cw::Source>* sources_{nullptr};
  int source_{-1};
  int pos_{0};
  int line_{0};
  int column_{0};
};

}  // namespace

struct MultiSourceLexer : lex::lexer<lex::lexertl::lexer<lex::lexertl::token<CharIterator>>> {
  const std::vector<Source>* sources{};

  CharIterator char_iter{};
  CharIterator char_end{};
  iterator_type token_iter{};

  MultiSourceLexer() {
    const auto& rules = this->self;

    // 注释
    rules.add(R"(\/\/[^\r\n]*)", tok::comment);

    // 常量
    rules.add(R"(true|false)", tok::bool_);
    rules.add(R"([0-9]+)", tok::integer);
    rules.add(R"(\'([^'\\]|\\.+)\')", tok::integer);
    rules.add(R"(([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)([eE][+-]?[0-9]+)?)", tok::float_);
    rules.add(R"(\"([^"\\]|\\.)*\")", tok::string_literal);

    // 关键字
    rules.add(R"(struct)", tok::struct_);
    rules.add(R"(virtual)", tok::virtual_);
    rules.add(R"(func)", tok::func);
    rules.add(R"(var)", tok::var);
    rules.add(R"(alias)", tok::alias);
    rules.add(R"(if)", tok::if_);
    rules.add(R"(else)", tok::else_);
    rules.add(R"(for)", tok::for_);
    rules.add(R"(break)", tok::break_);
    rules.add(R"(continue)", tok::continue_);
    rules.add(R"(return)", tok::return_);

    // 标识符
    rules.add(R"([$_a-zA-Z\x80-\xFF][$_a-zA-Z0-9\x80-\xFF]*)", tok::identifier);

    // 运算符和界符
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

    // 界符
    rules.add(R"(\;)", tok::semi);
    rules.add(R"(\[)", tok::l_square);
    rules.add(R"(\])", tok::r_square);
    rules.add(R"(\()", tok::l_paren);
    rules.add(R"(\))", tok::r_paren);
    rules.add(R"(\{)", tok::l_brace);
    rules.add(R"(\})", tok::r_brace);

    // 空白字符
    rules.add(R"([ \t\v\f]+)", tok::blank);
    rules.add(R"(\r?\n)", tok::eol);
    rules.add(R"(\0)", tok::eof);
    rules.add(R"(.)", tok::undefined);

    token_iter = this->end();
  }

  const std::vector<Source>* Sources() const { return sources; }

  void Reset(const std::vector<Source>* sources) {
    this->sources = sources;

    char_iter = CharIterator::begin(sources);
    char_end = CharIterator::end(sources);

    token_iter = this->begin(char_iter, char_end);
  }

  bool Valid() { return token_iter != this->end(); }

  tok::TokenType Type() {
    auto& token = *token_iter;
    return static_cast<tok::TokenType>(token.id());
  }

  int Source() const { return char_iter.Source(); }

  int Pos() const { return char_iter.Pos(); }

  int Line() const { return char_iter.Line(); }

  int Column() const { return char_iter.Column(); }

  std::string_view Str() const {
    if (token_iter != this->end()) {
      auto& token = *token_iter;
      auto begin = &*token.value().begin();
      auto end = &*token.value().end();
      auto size = std::distance(begin, end);
      return std::string_view(begin, size);
    } else {
      return {};
    }
  }

  void Advance() { ++token_iter; }
};

struct Lexer::Impl {
  MultiSourceLexer multi_source_lexer{};
  cw::Token token{};

  const std::vector<Source>* Sources() const { return multi_source_lexer.Sources(); }

  void Reset(const std::vector<Source>* sources) {
    multi_source_lexer.Reset(sources);

    TakeToken();
  }

  void SkipBlankComment() {
    while (multi_source_lexer.Valid() && IsBlankOrComment(multi_source_lexer.Type())) {
      multi_source_lexer.Advance();
    }

    TakeToken();
  }

  void SkipLine() {
    for (; multi_source_lexer.Valid();) {
      bool is_line_end = multi_source_lexer.Type() == tok::eol || multi_source_lexer.Type() == tok::eof;

      multi_source_lexer.Advance();

      if (is_line_end) {
        break;
      }
    }

    TakeToken();
  }

  void Advance(bool skip_blank_comment) {
    // advance
    if (multi_source_lexer.Valid()) {
      multi_source_lexer.Advance();
    }

    // skip blank and comment
    if (skip_blank_comment) {
      while (multi_source_lexer.Valid() && IsBlankOrComment(multi_source_lexer.Type())) {
        multi_source_lexer.Advance();
      }
    }

    // take token
    TakeToken();
  }

  const cw::Token& Token() const { return token; }

 private:
  static void UpdateTokenProperty(cw::Token& token) {
    // TODO:解析属性
    switch (token.type) {
      case tok::identifier:
        token.property = IdentifierProperty{(std::string)token.source_view};
        break;
      case tok::bool_:
        break;
      default:
        token.property = NoneProperty{};
        break;
    }
  }

  void TakeToken() {
    // eos is a special token, it is not in the lexer
    if (multi_source_lexer.Valid()) {
      token.type = multi_source_lexer.Type();
    } else {
      token.type = tok::eos;
    }

    token.location.file = multi_source_lexer.Source();
    token.location.pos = multi_source_lexer.Pos();
    token.location.line = multi_source_lexer.Line();
    token.location.column = multi_source_lexer.Column();
    token.source_view = multi_source_lexer.Str();
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