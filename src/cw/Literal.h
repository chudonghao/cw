/// \file Literal.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <optional>
#include <string_view>

#include "Token.h"

namespace cw {

/// Parses the complete source spelling of a boolean literal.
std::optional<BoolProperty> ParseBoolLiteral(std::string_view spelling);

/// Parses the complete source spelling of an integer literal.
std::optional<IntegerProperty> ParseIntegerLiteral(std::string_view spelling);

/// Decodes a character literal to its byte value.
std::optional<CharacterProperty> ParseCharacterLiteral(std::string_view spelling);

/// Parses the complete source spelling of a floating-point literal.
std::optional<FloatProperty> ParseFloatLiteral(std::string_view spelling);

/// Parses the complete source spelling of a string literal.
std::optional<StringProperty> ParseStringLiteral(std::string_view spelling);

}  // namespace cw
