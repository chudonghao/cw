/// \file Exception.h
/// \author Donghao Chu
/// \date 2025/1/24
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include <ostream>
#include <stdexcept>
#include <vector>

namespace cw {

struct Source;
class Lexer;

class ParseException : public std::runtime_error {
 public:
  using std::runtime_error::runtime_error;
};

std::ostream &Dump(std::ostream &os, const std::vector<Source> &sources, const Lexer &lexer, const ParseException &e);

}  // namespace cw