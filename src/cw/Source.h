/// \file Source.h
/// \author Donghao Chu
/// \date 2025/01/07
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

#include <string>

namespace cw {

struct Source {
  std::string path;
  std::string content;
};

struct SourceLocation {
  int file{0};
  int line{0};
  int column{0};
  int size{0};
};

}  // namespace cw