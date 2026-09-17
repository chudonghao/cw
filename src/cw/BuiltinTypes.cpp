/// \file BuiltinTypes.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "BuiltinTypes.h"

namespace cw {

const char* to_string(BuiltinTypeKind kind) {
  switch (kind) {
    case BuiltinTypeKind::Invalid:
      return "invalid";
    case BuiltinTypeKind::Void:
      return "void";
    case BuiltinTypeKind::Bool:
      return "bool";
    case BuiltinTypeKind::I8:
      return "i8";
    case BuiltinTypeKind::I16:
      return "i16";
    case BuiltinTypeKind::I32:
      return "i32";
    case BuiltinTypeKind::I64:
      return "i64";
    case BuiltinTypeKind::U8:
      return "u8";
    case BuiltinTypeKind::U16:
      return "u16";
    case BuiltinTypeKind::U32:
      return "u32";
    case BuiltinTypeKind::U64:
      return "u64";
    case BuiltinTypeKind::F32:
      return "f32";
    case BuiltinTypeKind::F64:
      return "f64";
    case BuiltinTypeKind::ISize:
      return "isize";
    case BuiltinTypeKind::USize:
      return "usize";
  }
  return "invalid";
}

BuiltinTypeKind from_string(std::string_view spelling) {
  if (spelling == "void") {
    return BuiltinTypeKind::Void;
  }
  if (spelling == "bool") {
    return BuiltinTypeKind::Bool;
  }
  if (spelling == "i8") {
    return BuiltinTypeKind::I8;
  }
  if (spelling == "i16") {
    return BuiltinTypeKind::I16;
  }
  if (spelling == "i32") {
    return BuiltinTypeKind::I32;
  }
  if (spelling == "i64") {
    return BuiltinTypeKind::I64;
  }
  if (spelling == "u8") {
    return BuiltinTypeKind::U8;
  }
  if (spelling == "u16") {
    return BuiltinTypeKind::U16;
  }
  if (spelling == "u32") {
    return BuiltinTypeKind::U32;
  }
  if (spelling == "u64") {
    return BuiltinTypeKind::U64;
  }
  if (spelling == "f32") {
    return BuiltinTypeKind::F32;
  }
  if (spelling == "f64") {
    return BuiltinTypeKind::F64;
  }
  if (spelling == "isize") {
    return BuiltinTypeKind::ISize;
  }
  if (spelling == "usize") {
    return BuiltinTypeKind::USize;
  }
  return BuiltinTypeKind::Invalid;
}

}  // namespace cw
