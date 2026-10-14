/// \file NameSyntax.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <ostream>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

#include "Source.h"

namespace cw {

enum class NameSegmentKind { Identifier, Operator };

struct NameSegment {
  std::string spelling;
  SourceRange range{};
  NameSegmentKind kind{NameSegmentKind::Identifier};
};

/// Written name, independent of the declaration it eventually resolves to.
struct NameSyntax {
  bool absolute{};
  SourceRange global_range{};
  std::vector<NameSegment> segments;

  static NameSyntax Identifier(std::string name, SourceRange range = {}) {
    return {false, {}, {{std::move(name), range, NameSegmentKind::Identifier}}};
  }
  static NameSyntax Operator(std::string name, SourceRange range = {}) {
    return {false, {}, {{std::move(name), range, NameSegmentKind::Operator}}};
  }

  bool empty() const { return segments.empty(); }
  bool IsQualified() const { return absolute || segments.size() > 1; }
  bool IsOperator() const { return !empty() && segments.back().kind == NameSegmentKind::Operator; }
  bool IsUnqualified(std::string_view name) const {
    return !IsQualified() && !empty() && segments.front().spelling == name;
  }
  const std::string& Unqualified() const {
    static const std::string empty_name;
    return empty() ? empty_name : segments.back().spelling;
  }
  SourceRange Range() const {
    if (empty()) return global_range;
    return {absolute ? global_range.begin : segments.front().range.begin, segments.back().range.end};
  }
  std::string Spelling() const {
    std::string result = absolute ? "::" : "";
    for (std::size_t index = 0; index < segments.size(); ++index) {
      if (index) result += "::";
      result += segments[index].spelling;
    }
    return result;
  }
};

inline std::ostream& operator<<(std::ostream& stream, const NameSyntax& name) { return stream << name.Spelling(); }

}  // namespace cw
