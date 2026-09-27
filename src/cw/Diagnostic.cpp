/// \file Diagnostic.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "Diagnostic.h"

#include <ostream>
#include <utility>

namespace cw {

void DiagnosticEngine::Add(DiagnosticSeverity severity, std::string message) {
  auto& diagnostic = diagnostics_.emplace_back();
  diagnostic.severity = severity;
  diagnostic.message = std::move(message);
  has_errors_ |= severity == kErrorDiagnostic;
}

void DiagnosticEngine::Add(DiagnosticSeverity severity, SourceLocation location, std::string message,
                           int highlight_size) {
  Add(severity, std::move(message));
  if (!sources_ || location.file < 0 || location.file >= static_cast<int>(sources_->size())) {
    return;
  }
  const Source& source = (*sources_)[location.file];
  auto& diagnostic_location = diagnostics_.back().location.emplace();
  diagnostic_location.path = source.path;
  diagnostic_location.line = location.line;
  diagnostic_location.column = location.column;
  diagnostic_location.line_source = LineSource(source, location.pos);
  auto& highlight = diagnostic_location.highlights.emplace_back();
  highlight.column = location.column;
  highlight.size = highlight_size;
}

void DiagnosticEngine::Add(DiagnosticSeverity severity, SourceRange range, std::string message) {
  int size = 0;
  if (range.IsValid() && range.end.file == range.begin.file && range.end.line == range.begin.line &&
      range.end.pos > range.begin.pos) {
    size = range.end.pos - range.begin.pos;
  }
  Add(severity, range.begin, std::move(message), size);
}

void DiagnosticEngine::Dump(std::ostream& os) const {
  // Use Clang-style locations and caret lines: https://clang.llvm.org/diagnostics.html
  for (const auto& diag : diagnostics_) {
    const auto& location = diag.location;
    if (location) {
      os << location->path.string() << ":" << (location->line + 1) << ":" << (location->column + 1) << ": ";
    }

    switch (diag.severity) {
      case kErrorDiagnostic:
        os << "error: ";
        break;
      case kWarningDiagnostic:
        os << "warning: ";
        break;
      case kNoteDiagnostic:
        os << "note: ";
        break;
    }

    os << diag.message << "\n";

    if (location && !location->line_source.empty()) {
      os << location->line_source << "\n";

      // Even a zero-width range gets a caret to locate missing syntax.
      int pos = 0;
      for (const auto& hl : location->highlights) {
        while (pos < hl.column) {
          os << ' ';
          pos++;
        }
        if (hl.size > 0) {
          os << '^';
          pos++;
          for (int i = 1; i < hl.size; i++) {
            os << '~';
            pos++;
          }
        } else {
          os << '^';
          pos++;
        }
      }
      os << "\n";
    }
  }
}

}  // namespace cw
