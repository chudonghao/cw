#pragma once

#include <filesystem>
#include <string>
#include <vector>

#include <boost/container/static_vector.hpp>

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

struct Diagnostic {
  std::filesystem::path path;
  int line{0};
  int column{0};
  DiagnosticSeverity severity{};
  std::string message{};
  std::string line_source{};
  boost::container::static_vector<DiagnosticHighlight, 5> highlights{};
};

class DiagnosticEngine {
  std::vector<Diagnostic> diagnostics_;

 public:
  DiagnosticEngine();

  void Add(DiagnosticSeverity severity, std::filesystem::path path, int line, int column, std::string message, std::string line_source, int size);

  void Dump(std::ostream &os) const;
};

}  // namespace cw
