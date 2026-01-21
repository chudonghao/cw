#include "Diagnostic.h"

namespace cw {

DiagnosticEngine::DiagnosticEngine() {}

void DiagnosticEngine::Add(DiagnosticSeverity severity, std::filesystem::path path, int line, int column, std::string message, std::string line_source, int size) {
  auto &diagnostic = diagnostics_.emplace_back();
  diagnostic.severity = severity;
  diagnostic.path = std::move(path);
  diagnostic.line = line;
  diagnostic.column = column;
  diagnostic.message = std::move(message);
  diagnostic.line_source = std::move(line_source);
  auto &highlight = diagnostic.highlights.emplace_back();
  highlight.column = column;
  highlight.size = size;
}

}  // namespace cw
