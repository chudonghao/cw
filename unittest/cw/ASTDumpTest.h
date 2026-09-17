/// \file ASTDumpTest.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <regex>
#include <sstream>
#include <string>
#include <string_view>
#include <unordered_map>
#include <utility>
#include <vector>

#include <gtest/gtest.h>

#include "cw/ASTDumper.h"
#include "cw/Source.h"
#include "cw/ast.h"

namespace cw::test {

namespace detail {

/// \brief Regex and named address captures for one expected dump line.
struct AstDumpLinePattern {
  std::string regex;                       ///< Regex matching the complete line.
  std::vector<std::string> address_names;  ///< Capture names in regex group order.
};

/// \brief Builds a regex from one AST dump line with address placeholders.
inline AstDumpLinePattern BuildAstDumpLinePattern(std::string_view line) {
  constexpr std::string_view kAddressPlaceholder = "{{address}}";
  constexpr std::string_view kNamedAddressPrefix = "{{address:";
  constexpr std::string_view kRegexMetacharacters = R"(\.^$|()[]*+?{})";

  AstDumpLinePattern result;
  result.regex.reserve(line.size());
  for (std::size_t i = 0; i < line.size();) {
    if (line.substr(i, kAddressPlaceholder.size()) == kAddressPlaceholder) {
      result.regex += R"(0x[0-9a-f]+)";
      i += kAddressPlaceholder.size();
      continue;
    }

    if (line.substr(i, kNamedAddressPrefix.size()) == kNamedAddressPrefix) {
      const std::size_t name_begin = i + kNamedAddressPrefix.size();
      const std::size_t end = line.find("}}", name_begin);
      if (end != std::string_view::npos && end != name_begin) {
        result.address_names.emplace_back(line.substr(name_begin, end - name_begin));
        result.regex += R"((0x[0-9a-f]+))";
        i = end + 2;
        continue;
      }
    }

    // Only address placeholders are patterns; all other expected text must match literally.
    if (kRegexMetacharacters.find(line[i]) != std::string_view::npos) {
      result.regex.push_back('\\');
    }
    result.regex.push_back(line[i]);
    ++i;
  }
  return result;
}

}  // namespace detail

/// \brief Compares an AST dump and verifies named address identity.
inline void ExpectAstDump(Node& node, const std::vector<Source>& sources, std::string_view expected_dump) {
  std::ostringstream output;
  ASTDumper dumper(output, sources);
  dumper.Dump(node);

  // Share captures across lines so declaration references must retain address identity.
  std::unordered_map<std::string, std::string> addresses;
  std::istringstream expected_lines{std::string(expected_dump)};
  std::istringstream actual_lines(output.str());
  std::string expected_line;
  std::string actual_line;
  std::size_t line = 0;
  while (std::getline(expected_lines, expected_line)) {
    ASSERT_TRUE(std::getline(actual_lines, actual_line)) << "missing AST dump line " << line;

    const detail::AstDumpLinePattern pattern = detail::BuildAstDumpLinePattern(expected_line);
    std::smatch matches;
    ASSERT_TRUE(std::regex_match(actual_line, matches, std::regex(pattern.regex)))
        << "AST dump line " << line << "\nexpected: " << expected_line << "\nactual: " << actual_line;
    ASSERT_EQ(matches.size(), pattern.address_names.size() + 1);

    for (std::size_t i = 0; i < pattern.address_names.size(); ++i) {
      const std::string& name = pattern.address_names[i];
      const std::string address = matches[i + 1].str();
      const auto [it, inserted] = addresses.emplace(name, address);
      if (!inserted) {
        EXPECT_EQ(it->second, address) << "address placeholder '" << name << "' differs on AST dump line " << line;
      }
    }
    ++line;
  }
  EXPECT_FALSE(std::getline(actual_lines, actual_line)) << "unexpected AST dump line " << line << ": " << actual_line;
}

}  // namespace cw::test
