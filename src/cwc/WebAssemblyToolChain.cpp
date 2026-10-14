/// \file WebAssemblyToolChain.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "WebAssemblyToolChain.h"

#include <algorithm>
#include <iterator>
#include <string>
#include <vector>

#include <llvm/ADT/StringRef.h>
#include <llvm/BinaryFormat/Wasm.h>
#include <llvm/Support/Endian.h>
#include <llvm/Support/MemoryBuffer.h>
#include <llvm/Support/Program.h>

#include "cw/Diagnostic.h"

namespace cw::driver {
namespace {

enum class OptionValue { None, Joined, SeparateOrJoined, OptionalJoined };

struct LinkerOption {
  llvm::StringLiteral name;
  OptionValue value;
};

// Keep passthrough options within the source-only, final-module boundary. Options that
// read files, redirect output, or select another link mode would bypass driver guarantees.
constexpr LinkerOption kLinkerOptions[] = {
    {"--no-entry", OptionValue::None},
    {"--entry", OptionValue::SeparateOrJoined},
    {"-e", OptionValue::SeparateOrJoined},
    {"--export", OptionValue::SeparateOrJoined},
    {"--export-if-defined", OptionValue::SeparateOrJoined},
    {"--export-all", OptionValue::None},
    {"--export-dynamic", OptionValue::None},
    {"--no-export-dynamic", OptionValue::None},
    {"--undefined", OptionValue::SeparateOrJoined},
    {"--import-undefined", OptionValue::None},
    {"--allow-undefined", OptionValue::None},
    {"--unresolved-symbols", OptionValue::SeparateOrJoined},
    {"--error-unresolved-symbols", OptionValue::None},
    {"--warn-unresolved-symbols", OptionValue::None},
    {"--gc-sections", OptionValue::None},
    {"--no-gc-sections", OptionValue::None},
    {"--export-memory", OptionValue::OptionalJoined},
    {"--import-memory", OptionValue::OptionalJoined},
    {"--export-table", OptionValue::None},
    {"--import-table", OptionValue::None},
    {"--initial-memory", OptionValue::Joined},
    {"--max-memory", OptionValue::Joined},
    {"--initial-heap", OptionValue::Joined},
    {"--global-base", OptionValue::Joined},
    {"--table-base", OptionValue::Joined},
    {"--stack-first", OptionValue::None},
    {"--no-stack-first", OptionValue::None},
    {"--no-growable-memory", OptionValue::None},
    {"--growable-table", OptionValue::None},
    {"--strip-all", OptionValue::None},
    {"--strip-debug", OptionValue::None},
};

bool CheckOptions(const std::vector<std::string>& options, DiagnosticEngine& diagnostics) {
  // LLD expands response files before parsing options, even in an option's value position.
  for (const auto& option : options) {
    if (llvm::StringRef(option).starts_with("@")) {
      diagnostics.Add(kErrorDiagnostic, "Wasm linking does not support response files: '" + option + "'");
      return false;
    }
  }
  for (std::size_t i = 0; i < options.size(); ++i) {
    const llvm::StringRef argument = options[i];
    const auto split = argument.split('=');
    const auto name = split.first;
    const auto value = split.second;
    const bool joined = name.size() != argument.size();
    const auto* option = std::find_if(std::begin(kLinkerOptions), std::end(kLinkerOptions),
                                      [&](const LinkerOption& candidate) { return name == candidate.name; });
    if (option == std::end(kLinkerOptions) || (joined && option->value == OptionValue::None)) {
      diagnostics.Add(kErrorDiagnostic, "unsupported Wasm linker option '" + argument.str() + "'");
      return false;
    }
    if (option->value == OptionValue::SeparateOrJoined && !joined) {
      if (++i < options.size() && !options[i].empty() && !llvm::StringRef(options[i]).starts_with("-")) {
        continue;
      }
    } else if ((joined && !value.empty()) ||
               (!joined && (option->value == OptionValue::None || option->value == OptionValue::OptionalJoined))) {
      continue;
    }
    diagnostics.Add(kErrorDiagnostic, "Wasm linker option '" + name.str() + "' requires a value");
    return false;
  }
  return true;
}

bool CheckModule(const std::string& output, DiagnosticEngine& diagnostics) {
  auto buffer = llvm::MemoryBuffer::getFileSlice(output, 8, 0);
  if (!buffer) {
    diagnostics.Add(kErrorDiagnostic, "cannot read Wasm linker output: " + buffer.getError().message());
    return false;
  }
  const auto header = (*buffer)->getBuffer();
  if (header.size() != 8 || !header.starts_with(llvm::StringRef(llvm::wasm::WasmMagic, 4)) ||
      llvm::support::endian::read32le(header.data() + 4) != llvm::wasm::WasmVersion) {
    diagnostics.Add(kErrorDiagnostic, "linker output is not a WebAssembly module with version 1");
    return false;
  }
  return true;
}

}  // namespace

std::optional<WebAssemblyToolChain> WebAssemblyToolChain::Create(const std::vector<std::string>& options,
                                                                 const std::string& executable_directory,
                                                                 DiagnosticEngine& diagnostics) {
  if (!CheckOptions(options, diagnostics)) {
    return std::nullopt;
  }
  std::optional<std::string> linker;
  if (!executable_directory.empty()) {
    if (auto candidate = llvm::sys::findProgramByName("wasm-ld", {executable_directory})) {
      linker = *candidate;
    }
  }
  if (!linker) {
    auto path_candidate = llvm::sys::findProgramByName("wasm-ld");
    if (!path_candidate) {
      diagnostics.Add(kErrorDiagnostic, "cannot locate wasm-ld: " + path_candidate.getError().message());
      return std::nullopt;
    }
    linker = *path_candidate;
  }
  WebAssemblyToolChain toolchain;
  toolchain.linker_ = *linker;
  toolchain.options_ = options;
  return toolchain;
}

bool WebAssemblyToolChain::Link(const std::vector<std::string>& inputs, const std::string& output,
                                DiagnosticEngine& diagnostics) const {
  std::vector<llvm::StringRef> arguments{linker_, "-m", "wasm32"};
  arguments.insert(arguments.end(), options_.begin(), options_.end());
  arguments.insert(arguments.end(), inputs.begin(), inputs.end());
  arguments.insert(arguments.end(), {"-o", output});
  std::string error;
  const int result = llvm::sys::ExecuteAndWait(linker_, arguments, std::nullopt, {}, 0, 0, &error);
  if (result == -1) {
    diagnostics.Add(kErrorDiagnostic, "cannot start wasm-ld" + (error.empty() ? "" : ": " + error));
  } else if (result == -2) {
    diagnostics.Add(kErrorDiagnostic, "wasm-ld terminated abnormally");
  } else if (result != 0) {
    diagnostics.Add(kErrorDiagnostic, "wasm-ld command failed with exit code " + std::to_string(result));
  }
  return result == 0 && CheckModule(output, diagnostics);
}

}  // namespace cw::driver
