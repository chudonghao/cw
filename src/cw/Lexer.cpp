/// \file Lexer.cpp
/// \author Donghao Chu
/// \date 2025-01-10
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include "Lexer.h"

namespace cw {

void Lexer::Reset(const std::vector<Source>* sources) {
  sources_ = sources;
}

}  // namespace cw