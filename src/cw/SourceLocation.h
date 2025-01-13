/// \file SourceLocation.h
/// \author Donghao Chu
/// \date 2025-01-06
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#pragma once

namespace cw {

struct SourceLocation {
  int file{0};
  int line{0};
  int column{0};

  SourceLocation() = default;
    
  SourceLocation(int file, int line, int column)
      : file(file), line(line), column(column) {}
};

}  // namespace cw