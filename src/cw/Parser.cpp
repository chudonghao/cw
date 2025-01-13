/// \file Parser.cpp
/// \author Donghao Chu
/// \date 2025-01-10
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include "Parser.h"

namespace cw {

void Parser::Reset(Lexer* lexer) {
  lexer_ = lexer;
}

void Parser::operator()() noexcept(false) {
  // TODO: Implement parser
}

}  // namespace cw