/// \file Parser.h
/// \author Donghao Chu
/// \date 2025-01-07
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

namespace cw {

class Lexer;

class Parser {
  Lexer* lexer_{};

 public:
  void Reset(Lexer* lexer);

  void operator()() noexcept(false);
};

}  // namespace cw