/// \file Source.h
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <filesystem>
#include <string>
#include <string_view>

namespace cw {

/// \brief Source location for diagnostics.
struct SourceLocation {
  int file{-1};  ///< Source file index, or -1 when invalid.
  int pos{};     ///< Byte position in the source file.
  int line{};    ///< Line number (0-based).
  int column{};  ///< Column number (0-based).

  /// \brief Returns whether this location refers to a source file.
  bool IsValid() const { return file >= 0; }
};

/// \brief Half-open character source range [begin, end).
struct SourceRange {
  SourceLocation begin{};  ///< First included character.
  SourceLocation end{};    ///< Position immediately after the last included character.

  /// \brief Returns whether both half-open range endpoints are valid.
  bool IsValid() const { return begin.IsValid() && end.IsValid(); }
};

/// \brief Source file content.
struct Source {
  std::filesystem::path path;  ///< File path.
  std::string content;         ///< File content.
};

std::string_view LineSource(const Source& source, int pos);

}  // namespace cw
