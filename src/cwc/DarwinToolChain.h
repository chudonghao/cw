/// \file DarwinToolChain.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#pragma once

#include <optional>
#include <string>
#include <vector>

#include <llvm/Support/VersionTuple.h>

namespace cw {
class DiagnosticEngine;
class TargetInfo;

namespace driver {

struct ToolChainOptions {
  std::string sysroot;
  std::string minimum_macos_version;
};

/// \brief Resolves the selected macOS toolchain without invoking a compiler driver.
class DarwinToolChain {
  std::string linker_;
  std::string sysroot_;
  std::string compiler_rt_;
  llvm::VersionTuple minimum_version_;
  llvm::VersionTuple sdk_version_;

 public:
  static std::optional<DarwinToolChain> Create(const ToolChainOptions& options, const TargetInfo& target,
                                               DiagnosticEngine& diagnostics);

  const llvm::VersionTuple& GetMinimumOSVersion() const { return minimum_version_; }
  const llvm::VersionTuple& GetSDKVersion() const { return sdk_version_; }

  /// \brief Links ordered arguments to a driver-owned output; file publication belongs to the caller.
  bool Link(const std::vector<std::string>& inputs, const std::string& output, DiagnosticEngine& diagnostics) const;
};

}  // namespace driver
}  // namespace cw
