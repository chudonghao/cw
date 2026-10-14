/// \file DarwinToolChain.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "DarwinToolChain.h"

#include <cstdlib>
#include <filesystem>
#include <string>
#include <system_error>
#include <utility>
#include <vector>

#include <llvm/ADT/ScopeExit.h>
#include <llvm/ADT/SmallString.h>
#include <llvm/ADT/StringRef.h>
#include <llvm/Support/Error.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/Support/MemoryBuffer.h>
#include <llvm/Support/Path.h>
#include <llvm/Support/Program.h>

#include "cw/Diagnostic.h"
#include "cw/TargetInfo.h"

namespace fs = std::filesystem;
namespace llvm_fs = llvm::sys::fs;

namespace cw::driver {
namespace {

std::optional<std::string> QueryXcrun(const std::vector<std::string>& options, DiagnosticEngine& diagnostics) {
  llvm::SmallString<256> model;
  llvm::sys::path::system_temp_directory(true, model);
  llvm::sys::path::append(model, "cwc-tool-%%%%%%.txt");
  auto capture = llvm_fs::TempFile::create(model);
  if (!capture) {
    diagnostics.Add(kErrorDiagnostic, "cannot create tool output file: " + llvm::toString(capture.takeError()));
    return std::nullopt;
  }
  llvm::scope_exit cleanup([&] {
    if (auto error = capture->discard()) {
      diagnostics.Add(kErrorDiagnostic, "cannot remove tool output file: " + llvm::toString(std::move(error)));
    }
  });
  auto xcrun = llvm::sys::findProgramByName("xcrun");
  std::string xcrun_path;
  if (xcrun) {
    xcrun_path = xcrun.get();
  } else if (llvm_fs::is_regular_file("/usr/bin/xcrun")) {
    xcrun_path = "/usr/bin/xcrun";
  } else {
    diagnostics.Add(kErrorDiagnostic, "cannot locate xcrun: " + xcrun.getError().message());
    return std::nullopt;
  }
  std::vector<llvm::StringRef> arguments{xcrun_path};
  for (const auto& option : options) {
    arguments.emplace_back(option);
  }
  const std::optional<llvm::StringRef> redirects[] = {std::nullopt, capture->TmpName, std::nullopt};
  std::string error;
  const int result = llvm::sys::ExecuteAndWait(arguments.front(), arguments, std::nullopt, redirects, 0, 0, &error);
  if (result != 0) {
    diagnostics.Add(kErrorDiagnostic, "cannot resolve the macOS toolchain: xcrun " +
                                          (error.empty() ? "failed with exit code " + std::to_string(result) : error));
    return std::nullopt;
  }
  auto buffer = llvm::MemoryBuffer::getFile(capture->TmpName);
  if (!buffer) {
    diagnostics.Add(kErrorDiagnostic, "cannot read tool output: " + buffer.getError().message());
    return std::nullopt;
  }
  auto value = (*buffer)->getBuffer().trim();
  if (value.empty()) {
    diagnostics.Add(kErrorDiagnostic, "cannot resolve the macOS toolchain: xcrun returned an empty value");
    return std::nullopt;
  }
  return value.str();
}

bool ParseVersion(const std::string& text, const char* description, llvm::VersionTuple& version,
                  DiagnosticEngine& diagnostics) {
  // Mach-O encodes versions in 16.8.8 bits. Reject values that would be silently truncated.
  if (version.tryParse(text) || version.getBuild() || version.getMajor() > 65535 ||
      version.getMinor().value_or(0) > 255 || version.getSubminor().value_or(0) > 255 ||
      version < llvm::VersionTuple(10) || !llvm::Triple::isValidVersionForOS(llvm::Triple::MacOSX, version)) {
    diagnostics.Add(kErrorDiagnostic, "invalid " + std::string(description) + " '" + text +
                                          "': expected a supported macOS version (10.0 or later)");
    return false;
  }
  return true;
}

std::optional<std::string> FindCompilerRT(const std::string& linker, DiagnosticEngine& diagnostics) {
  // xcrun selects the toolchain; its resource directories may contain several installed Clang versions.
  const auto resources = fs::path(linker).parent_path().parent_path() / "lib" / "clang";
  llvm::VersionTuple newest;
  std::string archive;
  std::error_code error;
  for (fs::directory_iterator it(resources, error), end; !error && it != end; it.increment(error)) {
    llvm::VersionTuple version;
    if (version.tryParse(it->path().filename().string())) {
      continue;
    }
    const auto candidate = it->path() / "lib" / "darwin" / "libclang_rt.osx.a";
    if (llvm_fs::is_regular_file(candidate.string()) && (archive.empty() || newest < version)) {
      newest = version;
      archive = candidate.string();
    }
  }
  if (error || archive.empty()) {
    diagnostics.Add(kErrorDiagnostic, "cannot locate Darwin compiler-rt in '" + resources.string() + "'" +
                                          (error ? ": " + error.message() : ""));
    return std::nullopt;
  }
  return archive;
}

}  // namespace

std::optional<DarwinToolChain> DarwinToolChain::Create(const ToolChainOptions& options, const TargetInfo& target,
                                                       DiagnosticEngine& diagnostics) {
  DarwinToolChain toolchain;
  auto minimum = options.minimum_macos_version;
  if (minimum.empty()) {
    if (const char* value = std::getenv("MACOSX_DEPLOYMENT_TARGET")) {
      minimum = value;
    }
  }
  if (minimum.empty()) {
    if (!target.GetTriple().getMacOSXVersion(toolchain.minimum_version_)) {
      diagnostics.Add(kErrorDiagnostic, "cannot determine the native macOS deployment version");
      return std::nullopt;
    }
  } else if (!ParseVersion(minimum, "macOS deployment version", toolchain.minimum_version_, diagnostics)) {
    return std::nullopt;
  }
  // arm64 macOS images have a platform minimum of 11.0, matching Clang's Darwin driver behavior.
  if (target.GetTriple().getArch() == llvm::Triple::aarch64 && toolchain.minimum_version_ < llvm::VersionTuple(11)) {
    toolchain.minimum_version_ = llvm::VersionTuple(11);
  }

  toolchain.sysroot_ = options.sysroot;
  if (toolchain.sysroot_.empty()) {
    if (const char* value = std::getenv("SDKROOT")) {
      toolchain.sysroot_ = value;
    }
  }
  if (toolchain.sysroot_.empty()) {
    auto root = QueryXcrun({"--sdk", "macosx", "--show-sdk-path"}, diagnostics);
    if (!root) {
      return std::nullopt;
    }
    toolchain.sysroot_ = *root;
  }
  std::error_code error;
  const auto root = fs::absolute(toolchain.sysroot_, error);
  if (error || !llvm_fs::is_directory(root.string())) {
    diagnostics.Add(kErrorDiagnostic, "invalid macOS SDK directory '" + toolchain.sysroot_ + "'");
    return std::nullopt;
  }
  toolchain.sysroot_ = root.string();
  auto sdk_version = QueryXcrun({"--sdk", toolchain.sysroot_, "--show-sdk-version"}, diagnostics);
  if (!sdk_version || !ParseVersion(*sdk_version, "macOS SDK version", toolchain.sdk_version_, diagnostics)) {
    return std::nullopt;
  }
  auto linker = QueryXcrun({"--sdk", toolchain.sysroot_, "--find", "ld"}, diagnostics);
  if (!linker) {
    return std::nullopt;
  }
  toolchain.linker_ = *linker;
  auto compiler_rt = FindCompilerRT(toolchain.linker_, diagnostics);
  if (!compiler_rt) {
    return std::nullopt;
  }
  toolchain.compiler_rt_ = *compiler_rt;
  return toolchain;
}

bool DarwinToolChain::Link(const std::vector<std::string>& inputs, const std::string& output,
                           DiagnosticEngine& diagnostics) const {
  const auto minimum = minimum_version_.getAsString();
  const auto sdk = sdk_version_.getAsString();
  std::vector<llvm::StringRef> arguments{linker_, "-demangle", "-dynamic", "-arch",       "arm64",  "-platform_version",
                                         "macos", minimum,     sdk,        "-syslibroot", sysroot_, "-o",
                                         output};
  for (const auto& input : inputs) {
    arguments.emplace_back(input);
  }
  arguments.insert(arguments.end(), {"-lc++abi", "-lSystem", compiler_rt_});
  std::string error;
  const int result = llvm::sys::ExecuteAndWait(linker_, arguments, std::nullopt, {}, 0, 0, &error);
  if (result == -1) {
    diagnostics.Add(kErrorDiagnostic, "cannot start linker" + (error.empty() ? "" : ": " + error));
  } else if (result == -2) {
    diagnostics.Add(kErrorDiagnostic, "linker terminated abnormally");
  } else if (result != 0) {
    diagnostics.Add(kErrorDiagnostic, "linker command failed with exit code " + std::to_string(result));
  }
  return result == 0;
}

}  // namespace cw::driver
