/// \file Lexer.cpp
/// \author Donghao Chu
/// \date 2025/01/10
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include "Lexer.h"

#include <boost/container/vector.hpp>
#include <boost/spirit/include/lex_lexertl.hpp>
#include <vector>
#include "Source.h"
#include "Token.h"
#include "cw/Token.h"

namespace lex = boost::spirit::lex;

namespace cw {

struct Lexer::LexerImpl : lex::lexer<lex::lexertl::lexer<>> {
  const std::vector<Source>* sources_{};

  int source_{0};
  int line_{0};
  int column_{0};
  const char* content_begin_{};
  const char* content_iter_{};
  const char* content_end_{};
  iterator_type token_iter_{};
  std::vector<int> line_pos_vec_{};

  LexerImpl() {
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

    token_iter_ = this->end();
  }

  void Reset(const std::vector<Source>& sources) {
    sources_ = &sources;

    ResetTokenIter(0);
  }

  void ResetTokenIter(int source) {
    source_ = source;
    line_ = 0;
    column_ = 0;
    line_pos_vec_.clear();
    if (source_ < sources_->size()) {
      content_begin_ = (*sources_)[source_].content.c_str();
      content_iter_ = content_begin_;
      content_end_ = content_begin_ + (*sources_)[source_].content.size() + 1;
      token_iter_ = this->begin(content_iter_, content_end_);
      line_pos_vec_.push_back(0);
    } else {
      content_begin_ = nullptr;
      content_iter_ = nullptr;
      content_end_ = nullptr;
      token_iter_ = this->end();
    }
  }

  bool Valid() {
    if (!sources_) return false;
    if (source_ >= sources_->size()) return false;
    return token_iter_ != this->end();
  }

  tok::TokenType Type() {
    if (!Valid()) return tok::eos;
    auto& token = *token_iter_;
    return static_cast<tok::TokenType>(token.id());
  }

  int Source() const { return source_; }

  int Line() const { return line_; }

  int Column() const { return column_; }

  int Pos() const { return content_iter_ - content_begin_; }

  int Size() const {
    if (token_iter_ != this->end()) {
      auto& token = *token_iter_;
      return token.value().size();
    }
    return 0;
  }

  std::string_view Str() const {
    if (token_iter_ != this->end()) {
      auto& token = *token_iter_;
      return std::string_view(token.value().begin(), token.value().size());
    } else {
      return {};
    }
  }

  void Advance() {
    if (token_iter_ != this->end()) {
      auto& token = *token_iter_;
      if (token.id() == tok::eol) {
        ++line_;
        column_ = 0;
        line_pos_vec_.push_back(std::distance(content_begin_, content_iter_));
      } else {
        column_ += token.value().size();
      }
      ++token_iter_;
    }
    if (token_iter_ == this->end()) {
      ResetTokenIter(source_ + 1);
    }
  }
};

Lexer::Lexer() : impl_{std::make_unique<LexerImpl>()} {}

Lexer::~Lexer() = default;

void Lexer::Reset(const std::vector<Source>& sources) {
  impl_->Reset(sources);

  //   ↓
  // 0 1
  SkipBlankAndShift();

  impl_->Advance();

  // ↓ ↓
  // 0 1
  SkipBlankAndShift();
}

void Lexer::Advance() {
  impl_->Advance();

  SkipBlankAndShift();
}

const Token& Lexer::Token(int k) const {
  BOOST_ASSERT(k <= 1);
  return token_[k];
}

int Lexer::LinePos(int line) const {
  if (line < 0 || line >= impl_->line_pos_vec_.size()) return -1;
  return impl_->line_pos_vec_[line];
}

void Lexer::SkipBlankAndShift() {
  while (IsBlankOrComment(impl_->Type())) {
    impl_->Advance();
  }

  token_[0] = std::move(token_[1]);

  auto type = impl_->Type();
  if (type != tok::unknown) {
    token_[1].type = type;
    token_[1].location.file = impl_->Source();
    token_[1].location.line = impl_->Line();
    token_[1].location.column = impl_->Column();
    token_[1].location.size = impl_->Size();

    // TODO:解析属性
    switch (token_[1].type) {
      case tok::identifier:
        token_[1].property = IdentifierProperty{(std::string)impl_->Str()};
        break;
      case tok::bool_:
        // TODO
        break;
      default:
        break;
    }
  } else {
    token_[1] = {};
  }
}

}  // namespace cw