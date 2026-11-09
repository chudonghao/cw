/// \file Lexer.h
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <memory>
#include <vector>

#include "Source.h"
#include "Token.h"

namespace cw {

/// \brief Splits sources into tokens one source at a time.
///
/// Whitespace, comments and line breaks only separate tokens and are never returned. Each source ends
/// with one zero-width eof, and eos follows the last source's eof.
class Lexer {
  struct Impl;
  std::unique_ptr<Impl> impl_{};

 public:
  Lexer();

  ~Lexer();

  const std::vector<Source>* Sources() const;

  /// \brief Starts at the first token of \p sources.
  void Reset(const std::vector<Source>* sources);

  /// \brief Advances to the next token; only an explicit advance leaves a source's eof.
  void Advance();

  const Token& Token() const;
};

}  // namespace cw
