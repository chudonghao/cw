/// \file Lexer.h
/// \author Donghao Chu
/// \date 2025/01/06
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include <vector>

#include "Source.h"
#include "Token.h"

namespace cw {

class Lexer {
  struct LexerImpl;
  std::unique_ptr<LexerImpl> impl_{};

  Token token_[2]{};

 public:
  Lexer();

  ~Lexer();

  void Reset(const std::vector<Source>& sources);

  void Advance();

  const Token& Token(int k = 0) const;

  int LinePos(int line) const;

 private:
  const std::vector<Source>& Sources() const;

  void SkipBlankAndShift();
};

}  // namespace cw
