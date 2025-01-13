/// \file Lexer.h
/// \author Donghao Chu
/// \date 2025-01-06
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include <vector>

#include "Source.h"

namespace cw {

class Lexer {
  const std::vector<Source>* sources_{};

 public:
  void Reset(const std::vector<Source>* sources);
};

}  // namespace cw
