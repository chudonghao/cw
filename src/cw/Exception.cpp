/// \file Exception.cpp
/// \author Donghao Chu
/// \date 2025/1/24
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include "Exception.h"

#include <iterator>
#include <ostream>

#include "Lexer.h"

namespace cw {

std::ostream &Dump(std::ostream &os, const std::vector<Source> &sources, const Lexer &lexer, const ParseException &e) {
  auto &token = lexer.Token();
  if (!token.Valid() || sources.empty()) {
    os << e.what();
    return os;
  }

  BOOST_ASSERT(token.location.file < sources.size());

  auto &source = sources[token.location.file];
  auto &content = source.content;
  os << source.path << ":" << token.location.line + 1 << ":" << token.location.column + 1 << ": error: " << e.what() << "\n";

  auto line_pos = lexer.LinePos(token.location.line);
  BOOST_ASSERT(line_pos >= 0);

  std::string line_number = std::to_string(token.location.line + 1);

  // line info
  os << line_number << " | ";
  auto iter = std::next(content.begin(), line_pos);
  while (iter != content.end() && *iter != '\n') {
    os << *iter;
    ++iter;
  }
  os << '\n';

  std::fill_n(std::ostream_iterator<char>(os), line_number.size(), ' ');
  os << " | ";
  std::fill_n(std::ostream_iterator<char>(os), token.location.column, ' ');
  os << '^';
  std::fill_n(std::ostream_iterator<char>(os), token.location.size - 1, '~');
  os << std::endl;

  return os;
}

}  // namespace cw