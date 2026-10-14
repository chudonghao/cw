/// \file WebAssemblyToolChain.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <optional>
#include <string>
#include <vector>

namespace cw {
class DiagnosticEngine;

namespace driver {

class WebAssemblyToolChain {
  std::string linker_;
  std::vector<std::string> options_;

 public:
  static std::optional<WebAssemblyToolChain> Create(const std::vector<std::string>& options,
                                                    const std::string& executable_directory,
                                                    DiagnosticEngine& diagnostics);

  /// \brief Links to a driver-owned output; validation precedes publication by the caller.
  bool Link(const std::vector<std::string>& inputs, const std::string& output, DiagnosticEngine& diagnostics) const;
};

}  // namespace driver
}  // namespace cw
