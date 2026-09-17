/// \file Diagnostic.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "Diagnostic.h"

namespace cw {

DiagnosticEngine::DiagnosticEngine() {}

void DiagnosticEngine::Add(DiagnosticSeverity severity, std::filesystem::path path, int line, int column,
                           std::string message, std::string line_source, int size) {
  auto& diagnostic = diagnostics_.emplace_back();
  diagnostic.severity = severity;
  diagnostic.path = std::move(path);
  diagnostic.line = line;
  diagnostic.column = column;
  diagnostic.message = std::move(message);
  diagnostic.line_source = std::move(line_source);
  auto& highlight = diagnostic.highlights.emplace_back();
  highlight.column = column;
  highlight.size = size;
}

void DiagnosticEngine::Dump(std::ostream& os) const {
  // Use Clang-style locations and caret lines: https://clang.llvm.org/diagnostics.html
  for (const auto& diag : diagnostics_) {
    os << diag.path.string() << ":" << (diag.line + 1) << ":" << (diag.column + 1) << ": ";

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

    if (!diag.line_source.empty()) {
      os << diag.line_source << "\n";

      // Even a zero-width range gets a caret to locate missing syntax.
      int pos = 0;
      for (const auto& hl : diag.highlights) {
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
