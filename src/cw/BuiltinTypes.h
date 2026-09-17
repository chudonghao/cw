/// \file BuiltinTypes.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <string_view>

namespace cw {

/// \brief Kinds of built-in types recognized by the language.
enum class BuiltinTypeKind {
  Invalid,
  Void,
  Bool,
  I8,
  I16,
  I32,
  I64,
  U8,
  U16,
  U32,
  U64,
  F32,
  F64,
  ISize,
  USize,
};

/// \brief Returns the source spelling of \p kind.
const char* to_string(BuiltinTypeKind kind);

/// \brief Parses a built-in type source spelling.
///
/// \return The corresponding kind, or BuiltinTypeKind::Invalid when \p spelling
/// is not a built-in type.
BuiltinTypeKind from_string(std::string_view spelling);

}  // namespace cw
