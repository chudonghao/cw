/// \file Diagnostic.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <filesystem>
#include <iosfwd>
#include <optional>
#include <string>
#include <vector>

#include <boost/container/static_vector.hpp>

#include "Source.h"

namespace cw {

enum DiagnosticSeverity {
  kErrorDiagnostic,
  kWarningDiagnostic,
  kNoteDiagnostic,
};

struct DiagnosticHighlight {
  int column{};
  int size{};
};

struct DiagnosticLocation {
  std::filesystem::path path;
  int line{0};
  int column{0};
  std::string line_source{};
  boost::container::static_vector<DiagnosticHighlight, 5> highlights{};
};

struct Diagnostic {
  DiagnosticSeverity severity{};
  std::string message{};
  std::optional<DiagnosticLocation> location;
};

class DiagnosticEngine {
  const std::vector<Source>* sources_{};
  std::vector<Diagnostic> diagnostics_;
  bool has_errors_{};

 public:
  /// \brief Borrows source files for subsequent reports; recorded diagnostics own their display text.
  void SetSources(const std::vector<Source>* sources) { sources_ = sources; }

  void Add(DiagnosticSeverity severity, std::string message);
  void Add(DiagnosticSeverity severity, SourceLocation location, std::string message, int highlight_size = 0);
  void Add(DiagnosticSeverity severity, SourceRange range, std::string message);

  bool HasErrors() const { return has_errors_; }

  /// \brief Returns accumulated diagnostics in emission order.
  const std::vector<Diagnostic>& Diagnostics() const { return diagnostics_; }

  void Dump(std::ostream& os) const;
};

}  // namespace cw
