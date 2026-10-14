/// \file DriverOptions.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <optional>
#include <string>
#include <vector>

#include "DarwinToolChain.h"

namespace llvm {
class raw_ostream;
}

namespace cw {
class DiagnosticEngine;

namespace driver {
namespace options {

// Keep custom option flags outside LLVM's four built-in driver flags.
enum DriverFlags { LinkerInput = (1 << 4) };

}  // namespace options

struct DriverItem {
  enum class Kind { Input, LibraryPath, Library, LinkerOption };

  Kind kind;
  std::string value;
};

struct DriverConfig {
  bool help{};
  bool compile_only{};
  bool assemble{};
  bool emit_llvm{};
  std::optional<std::string> target;
  std::optional<std::string> output;
  std::optional<std::string> sysroot;
  std::optional<std::string> minimum_macos_version;
  std::vector<DriverItem> items;
};

class DriverOptions {
 public:
  /// \brief Parse argv and convert the transient LLVM options to CW-owned data.
  static std::optional<DriverConfig> Parse(int argc, char* const argv[], DiagnosticEngine& diagnostics);

  /// \brief Print help generated from Options.td.
  static void PrintHelp(llvm::raw_ostream& output);
};

}  // namespace driver
}  // namespace cw
