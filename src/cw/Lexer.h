/// \file Lexer.h
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <vector>

#include "Source.h"
#include "Token.h"

namespace cw {

class Lexer {
  struct Impl;
  std::unique_ptr<Impl> impl_{};

 public:
  Lexer();

  ~Lexer();

  const std::vector<Source>* Sources() const;

  void Reset(const std::vector<Source>* sources);

  void SkipBlankComment();

  void SkipLine();

  /// Advances past the current token, skipping whitespace and comments.
  void Advance();

  void Advance(bool skip_blank_comment);

  const Token& Token() const;
};

}  // namespace cw
