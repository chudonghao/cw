/// \file Literal.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "Literal.h"

#include <algorithm>
#include <utility>

#include <llvm/ADT/StringRef.h>
#include <llvm/Support/Error.h>

namespace cw {

namespace {

std::optional<unsigned> DigitValue(char c) {
  if (c >= '0' && c <= '9') {
    return static_cast<unsigned>(c - '0');
  }
  if (c >= 'a' && c <= 'f') {
    return static_cast<unsigned>(c - 'a' + 10);
  }
  if (c >= 'A' && c <= 'F') {
    return static_cast<unsigned>(c - 'A' + 10);
  }
  return std::nullopt;
}

}  // namespace

std::optional<BoolProperty> ParseBoolLiteral(std::string_view spelling) {
  if (spelling == "true") {
    return BoolProperty{true};
  }
  if (spelling == "false") {
    return BoolProperty{false};
  }
  return std::nullopt;
}

std::optional<IntegerProperty> ParseIntegerLiteral(std::string_view spelling) {
  unsigned base = 10;
  if (spelling.size() >= 2 && spelling[0] == '0') {
    if (spelling[1] == 'b' || spelling[1] == 'B') {
      base = 2;
      spelling.remove_prefix(2);
    } else if (spelling[1] == 'o' || spelling[1] == 'O') {
      base = 8;
      spelling.remove_prefix(2);
    } else if (spelling[1] == 'x' || spelling[1] == 'X') {
      base = 16;
      spelling.remove_prefix(2);
    }
  }

  if (spelling.empty()) {
    return std::nullopt;
  }

  for (char c : spelling) {
    const auto digit = DigitValue(c);
    if (!digit || *digit >= base) {
      return std::nullopt;
    }
  }

  // Grow to preserve the complete source value; language typing happens in Sema.
  llvm::APSInt value(1, true);
  if (llvm::StringRef(spelling).getAsInteger(base, static_cast<llvm::APInt&>(value))) {
    return std::nullopt;
  }
  value = value.trunc(std::max(1u, value.getActiveBits()));
  return IntegerProperty{std::move(value)};
}

std::optional<CharacterProperty> ParseCharacterLiteral(std::string_view spelling) {
  if (spelling.size() < 3 || spelling.front() != '\'' || spelling.back() != '\'') {
    return std::nullopt;
  }
  spelling.remove_prefix(1);
  spelling.remove_suffix(1);

  uint8_t value = 0;
  if (spelling.size() >= 2 && spelling[0] == '\\') {
    switch (spelling[1]) {
      case 'n':
        value = '\n';
        break;
      case 'r':
        value = '\r';
        break;
      case 't':
        value = '\t';
        break;
      case '0':
        value = '\0';
        break;
      case '\\':
        value = '\\';
        break;
      case '\'':
        value = '\'';
        break;
      case 'x': {
        const std::string_view hex = spelling.substr(2);
        if (hex.empty() || hex.size() > 2) {
          return std::nullopt;
        }
        uint8_t parsed_value = 0;
        for (char c : hex) {
          const auto digit = DigitValue(c);
          if (!digit) {
            return std::nullopt;
          }
          parsed_value = static_cast<uint8_t>(parsed_value * 16 + *digit);
        }
        value = parsed_value;
        break;
      }
      default:
        value = static_cast<uint8_t>(spelling[1]);
        break;
    }
  } else {
    value = static_cast<uint8_t>(spelling[0]);
  }
  return CharacterProperty{value};
}

std::optional<FloatProperty> ParseFloatLiteral(std::string_view spelling) {
  const bool single = !spelling.empty() && (spelling.back() == 'f' || spelling.back() == 'F');
  if (single) {
    spelling.remove_suffix(1);
  }
  if (spelling.empty() || spelling.find_first_not_of("0123456789.eE+-") != std::string_view::npos) {
    return std::nullopt;
  }

  llvm::APFloat value(single ? llvm::APFloat::IEEEsingle() : llvm::APFloat::IEEEdouble());
  auto result = value.convertFromString(llvm::StringRef(spelling), llvm::APFloat::rmNearestTiesToEven);
  if (!result) {
    llvm::consumeError(result.takeError());
    return std::nullopt;
  }
  // Preserve overflow for Sema to diagnose; inexact and underflow results are valid.
  return FloatProperty{std::move(value)};
}

std::optional<StringProperty> ParseStringLiteral(std::string_view spelling) {
  if (spelling.size() < 2 || spelling.front() != '"' || spelling.back() != '"') {
    return std::nullopt;
  }
  spelling.remove_prefix(1);
  spelling.remove_suffix(1);

  std::string value;
  value.reserve(spelling.size());

  for (size_t i = 0; i < spelling.size(); ++i) {
    if (spelling[i] == '\\' && i + 1 < spelling.size()) {
      ++i;
      switch (spelling[i]) {
        case 'n':
          value.push_back('\n');
          break;
        case 'r':
          value.push_back('\r');
          break;
        case 't':
          value.push_back('\t');
          break;
        case '0':
          value.push_back('\0');
          break;
        case '\\':
          value.push_back('\\');
          break;
        case '"':
          value.push_back('"');
          break;
        case 'x':
          if (i + 1 < spelling.size()) {
            unsigned char hex_value = 0;
            int hex_count = 0;
            while (hex_count < 2 && i + 1 < spelling.size()) {
              const auto digit = DigitValue(spelling[i + 1]);
              if (!digit) {
                break;
              }
              hex_value = static_cast<unsigned char>(hex_value * 16 + *digit);
              ++i;
              ++hex_count;
            }
            if (hex_count > 0) {
              value.push_back(static_cast<char>(hex_value));
            }
          }
          break;
        default:
          value.push_back(spelling[i]);
          break;
      }
    } else {
      value.push_back(spelling[i]);
    }
  }
  return StringProperty{std::move(value)};
}

}  // namespace cw
