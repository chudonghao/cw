/// \file main.cpp
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include <unistd.h>

#include <algorithm>
#include <csignal>
#include <cstdint>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <memory>
#include <optional>
#include <string>
#include <system_error>
#include <utility>
#include <vector>

#include <llvm/ADT/ScopeExit.h>
#include <llvm/ADT/SmallString.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/Error.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/Support/MemoryBuffer.h>
#include <llvm/Support/Path.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/Target/TargetMachine.h>
#include <llvm/TargetParser/Triple.h>

#include "DarwinToolChain.h"
#include "DriverOptions.h"
#include "WebAssemblyToolChain.h"
#include "cw/ASTContext.h"
#include "cw/Backend.h"
#include "cw/CodeGen.h"
#include "cw/Diagnostic.h"
#include "cw/Interface.h"
#include "cw/Lexer.h"
#include "cw/Parser.h"
#include "cw/Sema.h"
#include "cw/Source.h"

namespace fs = std::filesystem;
namespace llvm_fs = llvm::sys::fs;

namespace {

struct LinkInput {
  enum class Kind { Source, File, Option, LinkerOption };

  Kind kind;
  std::string value;
};

struct CompileOptions {
  std::vector<std::string> inputs;
  std::vector<LinkInput> link_inputs;
  cw::driver::ToolChainOptions toolchain;
  std::string target;
  std::string output;
  cw::BackendOutputKind kind{cw::BackendOutputKind::Object};
  bool link{};
};

struct InputFile {
  std::string path;
  llvm_fs::UniqueID identity;
};

std::string GetExecutableDirectory(const char* argv0) {
  const auto executable = llvm_fs::getMainExecutable(
      argv0, reinterpret_cast<void*>(reinterpret_cast<std::intptr_t>(&GetExecutableDirectory)));
  return llvm::sys::path::parent_path(executable).str();
}

bool ReadSources(const CompileOptions& options, std::vector<cw::Source>& sources, std::vector<InputFile>& input_files,
                 cw::DiagnosticEngine& diagnostics) {
  for (const auto& path : options.inputs) {
    if (path == "-") {
      llvm_fs::file_status status;
      if (auto error = llvm_fs::status(STDIN_FILENO, status)) {
        diagnostics.Add(cw::kErrorDiagnostic, "cannot inspect input '-': " + error.message());
        return false;
      }
      if (llvm_fs::is_regular_file(status)) {
        input_files.push_back({path, status.getUniqueID()});
      }
      auto buffer = llvm::MemoryBuffer::getSTDIN();
      if (!buffer) {
        diagnostics.Add(cw::kErrorDiagnostic, "cannot read input '-': " + buffer.getError().message());
        return false;
      }
      sources.push_back({path, (*buffer)->getBuffer().str()});
      continue;
    }

    int fd;
    auto error = llvm_fs::openFileForRead(path, fd);
    if (error) {
      diagnostics.Add(cw::kErrorDiagnostic, "cannot open input '" + path + "': " + error.message());
      return false;
    }
    llvm_fs::file_status status;
    error = llvm_fs::status(fd, status);
    if (error || llvm_fs::is_directory(status)) {
      if (!error) {
        error = std::make_error_code(std::errc::is_a_directory);
      }
      ::close(fd);
      diagnostics.Add(cw::kErrorDiagnostic, "cannot read input '" + path + "': " + error.message());
      return false;
    }
    auto buffer = llvm::MemoryBuffer::getOpenFile(fd, path, status.getSize(), true, true);
    ::close(fd);
    if (!buffer) {
      diagnostics.Add(cw::kErrorDiagnostic, "cannot read input '" + path + "': " + buffer.getError().message());
      return false;
    }
    input_files.push_back({path, status.getUniqueID()});
    sources.push_back({path, (*buffer)->getBuffer().str()});
  }
  return true;
}

bool CheckProgramEntry(cw::ASTContext& context, cw::DiagnosticEngine& diagnostics) {
  const auto* i32 = context.GetBuiltinType(cw::BuiltinTypeKind::I32);
  const auto* argv_type = context.GetPointerType(
      cw::QualType(context.GetPointerType(cw::QualType(context.GetBuiltinType(cw::BuiltinTypeKind::U8)))));
  const cw::FunctionDecl* entry = nullptr;
  const auto check_function = [&](const cw::FunctionDecl& function) {
    if (function.name != "main") return;
    if (entry) {
      diagnostics.Add(cw::kErrorDiagnostic, function.name_range, "program entry 'main' must not be overloaded");
      diagnostics.Add(cw::kNoteDiagnostic, entry->name_range, "previous entry is here");
      return;
    }
    entry = &function;
    const auto* type = function.type.GetTypePtr()->AsFunctionType();
    const auto& parameters = type->GetParameterTypes();
    if (!context.GetTargetInfo().IsWasm32() &&
        (type->GetReturnType() != i32 ||
         !(parameters.empty() || (parameters.size() == 2 && parameters[0] == i32 && parameters[1] == argv_type)))) {
      diagnostics.Add(cw::kErrorDiagnostic, function.name_range,
                      "program entry must have signature 'func main() i32' or 'func main(argc i32, argv **u8) i32'");
    }
  };
  for (const auto& declaration : context.GetTranslationUnitDecl()->Decls) {
    if (declaration->GetKind() == cw::NodeKind::VarGroupDecl) {
      for (const auto& variable : static_cast<const cw::VarGroupDecl&>(*declaration).Vars) {
        if (variable->name == "main") {
          diagnostics.Add(cw::kErrorDiagnostic, variable->name_range, "program entry 'main' must be a function");
        }
      }
    } else if (declaration->GetKind() == cw::NodeKind::FunctionDecl) {
      check_function(static_cast<const cw::FunctionDecl&>(*declaration));
    } else if (declaration->GetKind() == cw::NodeKind::StructDecl &&
               declaration->modifier == cw::DeclModifier::Import) {
      const auto& structure = static_cast<const cw::StructDecl&>(*declaration);
      if (!structure.VirtualDecl) continue;
      for (const auto& slot : structure.VirtualDecl->Functions) {
        // An imported concrete slot without an independent declaration still
        // names an ordinary implementation in its enclosing namespace.
        if (!slot->is_abstract && !slot->implementation) check_function(*slot);
      }
    }
  }
  // The linker diagnoses a missing entry, including when an external object supplies it.
  return !diagnostics.HasErrors();
}

std::unique_ptr<llvm::Module> GenerateModule(const std::vector<cw::Source>& sources, cw::DiagnosticEngine& diagnostics,
                                             llvm::LLVMContext& llvm_context, const cw::TargetInfo& target_info,
                                             const llvm::TargetMachine& target, std::string* interface_text) {
  cw::ASTContext ast_context(target_info);
  cw::Lexer lexer;
  cw::Parser parser;
  cw::Sema sema;

  lexer.Reset(&sources);
  parser.SetLexer(&lexer);
  parser.SetASTContext(&ast_context);
  parser.SetDiagnosticEngine(&diagnostics);
  parser();
  if (diagnostics.HasErrors()) {
    return nullptr;
  }

  sema.SetDiagnosticEngine(&diagnostics);
  sema.SetASTContext(&ast_context);
  sema();
  if (diagnostics.HasErrors()) {
    return nullptr;
  }
  if (!CheckProgramEntry(ast_context, diagnostics)) {
    return nullptr;
  }
  if (interface_text) {
    llvm::raw_string_ostream output(*interface_text);
    cw::EmitInterface(*ast_context.GetTranslationUnitDecl(), output);
  }
  cw::CodeGen codegen;
  codegen.SetASTContext(&ast_context);
  codegen.SetDiagnosticEngine(&diagnostics);
  codegen.SetLLVMContext(&llvm_context);
  codegen.SetTargetMachine(&target);
  return codegen(sources.front().path.string());
}

const InputFile* FindInputFile(const llvm_fs::file_status& output, const std::vector<InputFile>& inputs) {
  for (const auto& input : inputs) {
    // Also protect the source's current path if it was replaced after reading.
    llvm_fs::file_status current;
    if (output.getUniqueID() == input.identity ||
        (input.path != "-" && !llvm_fs::status(input.path, current) && current.getUniqueID() == output.getUniqueID())) {
      return &input;
    }
  }
  return nullptr;
}

bool CheckOutputIdentity(const std::string& path, const llvm_fs::file_status& status,
                         const std::vector<InputFile>& inputs, cw::DiagnosticEngine& diagnostics) {
  if (const auto* input = FindInputFile(status, inputs)) {
    diagnostics.Add(cw::kErrorDiagnostic, "output '" + path + "' refers to input '" + input->path + "'");
    return false;
  }
  return true;
}

bool HasLinkerOptions(const CompileOptions& options) {
  return std::any_of(options.link_inputs.begin(), options.link_inputs.end(),
                     [](const LinkInput& input) { return input.kind == LinkInput::Kind::LinkerOption; });
}

std::vector<std::string> GetLinkerOptions(const CompileOptions& options) {
  std::vector<std::string> linker_options;
  for (const auto& input : options.link_inputs) {
    if (input.kind == LinkInput::Kind::LinkerOption) {
      linker_options.push_back(input.value);
    }
  }
  return linker_options;
}

bool FinishOutput(llvm::raw_fd_ostream& output, const std::string& path, bool close,
                  cw::DiagnosticEngine& diagnostics) {
  output.flush();
  if (close) {
    output.close();
  }
  if (!output.has_error()) {
    return true;
  }
  diagnostics.Add(cw::kErrorDiagnostic, "cannot write output '" + path + "': " + output.error().message());
  output.clear_error();
  return false;
}

void RemoveIncompleteOutput(const std::string& path, const llvm_fs::file_status& opened,
                            const std::vector<InputFile>& inputs, cw::DiagnosticEngine& diagnostics) {
  llvm_fs::file_status current;
  if (auto error = llvm_fs::status(path, current)) {
    if (error != std::errc::no_such_file_or_directory) {
      diagnostics.Add(cw::kErrorDiagnostic, "cannot inspect incomplete output '" + path + "': " + error.message());
    }
    return;
  }
  if (!llvm_fs::is_regular_file(current) || current.getUniqueID() != opened.getUniqueID() ||
      FindInputFile(current, inputs)) {
    return;
  }
  if (auto error = llvm_fs::remove(path)) {
    diagnostics.Add(cw::kErrorDiagnostic, "cannot remove incomplete output '" + path + "': " + error.message());
  }
}

struct OutputFile {
  std::string path;
  int fd{-1};  // Owned by stream once opened.
  std::unique_ptr<llvm::raw_fd_ostream> stream;
  llvm_fs::file_status identity;
  std::string cleanup_path;
  bool remove_on_failure{};
};

bool OpenOutput(OutputFile& file, const std::vector<InputFile>& inputs, cw::DiagnosticEngine& diagnostics) {
  llvm_fs::file_status status;
  auto error = llvm_fs::status(file.path, status);
  if (error && error != std::errc::no_such_file_or_directory) {
    diagnostics.Add(cw::kErrorDiagnostic, "cannot inspect output '" + file.path + "': " + error.message());
    return false;
  }
  if (!error && !CheckOutputIdentity(file.path, status, inputs, diagnostics)) {
    return false;
  }
  const bool existed = !error;

  // Open all outputs without truncating, then check their actual identities together.
  error = llvm_fs::openFileForWrite(file.path, file.fd, llvm_fs::CD_OpenAlways);
  if (error) {
    diagnostics.Add(cw::kErrorDiagnostic, "cannot open output '" + file.path + "': " + error.message());
    return false;
  }
  file.stream = std::make_unique<llvm::raw_fd_ostream>(file.fd, true);
  error = llvm_fs::status(file.fd, file.identity);
  if (error) {
    diagnostics.Add(cw::kErrorDiagnostic, "cannot inspect output '" + file.path + "': " + error.message());
    return false;
  }
  if (!CheckOutputIdentity(file.path, file.identity, inputs, diagnostics)) {
    return false;
  }

  if (llvm_fs::is_regular_file(file.identity)) {
    file.remove_on_failure = !existed;
    // Follow output symlinks for cleanup, and only remove this same file on failure.
    llvm::SmallString<256> resolved;
    error = llvm_fs::real_path(file.path, resolved);
    if (!error) {
      file.cleanup_path = resolved.str().str();
      llvm_fs::file_status resolved_status;
      error = llvm_fs::status(file.cleanup_path, resolved_status);
      if (!error && resolved_status.getUniqueID() != file.identity.getUniqueID()) {
        error = std::make_error_code(std::errc::state_not_recoverable);
      }
    }
    if (error) {
      diagnostics.Add(cw::kErrorDiagnostic, "cannot prepare output '" + file.path + "': " + error.message());
      return false;
    }
  }
  return true;
}

bool WriteOutput(const CompileOptions& options, const std::vector<InputFile>& inputs, llvm::Module& module,
                 llvm::TargetMachine& target, const std::string& interface_text, cw::DiagnosticEngine& diagnostics) {
  if (options.output == "-") {
    llvm_fs::file_status status;
    if (auto error = llvm_fs::status(STDOUT_FILENO, status)) {
      diagnostics.Add(cw::kErrorDiagnostic, "cannot inspect output '-': " + error.message());
      return false;
    }
    if (!CheckOutputIdentity(options.output, status, inputs, diagnostics)) {
      return false;
    }
    llvm::raw_fd_ostream output(STDOUT_FILENO, false);
    const bool generated = cw::EmitBackendOutput(module, target, options.kind, output, diagnostics);
    const bool finished = FinishOutput(output, options.output, false, diagnostics);
    return generated && finished;
  }

  std::vector<OutputFile> outputs;
  outputs.push_back({options.output});
  if (options.kind == cw::BackendOutputKind::Object) {
    const auto interface_path = fs::path(options.output).replace_extension(".cwi");
    if (interface_path.lexically_normal() == fs::path(options.output).lexically_normal()) {
      diagnostics.Add(cw::kErrorDiagnostic,
                      "object and interface outputs refer to the same path '" + options.output + "'");
      return false;
    }
    outputs.push_back({interface_path.string()});
  }

  bool success = false;
  llvm::scope_exit cleanup([&] {
    // Free every output descriptor before retrying cleanup path resolution.
    for (auto& file : outputs) {
      if (file.stream) {
        FinishOutput(*file.stream, file.path, true, diagnostics);
        file.stream.reset();
      }
    }
    if (success) return;
    for (auto& file : outputs) {
      if (!file.remove_on_failure) continue;
      if (file.cleanup_path.empty()) {
        llvm::SmallString<256> resolved;
        if (auto error = llvm_fs::real_path(file.path, resolved)) {
          if (error != std::errc::no_such_file_or_directory) {
            diagnostics.Add(cw::kErrorDiagnostic,
                            "cannot resolve incomplete output '" + file.path + "': " + error.message());
          }
          continue;
        }
        file.cleanup_path = resolved.str().str();
      }
      RemoveIncompleteOutput(file.cleanup_path, file.identity, inputs, diagnostics);
    }
  });

  for (auto& file : outputs) {
    if (!OpenOutput(file, inputs, diagnostics)) return false;
  }
  if (outputs.size() == 2 && outputs[0].identity.getUniqueID() == outputs[1].identity.getUniqueID()) {
    diagnostics.Add(cw::kErrorDiagnostic,
                    "outputs '" + outputs[0].path + "' and '" + outputs[1].path + "' refer to the same file");
    return false;
  }
  for (auto& file : outputs) {
    if (!CheckOutputIdentity(file.path, file.identity, inputs, diagnostics)) return false;
    if (!llvm_fs::is_regular_file(file.identity)) continue;
    file.remove_on_failure = true;
    if (auto error = llvm_fs::resize_file(file.fd, 0)) {
      diagnostics.Add(cw::kErrorDiagnostic, "cannot prepare output '" + file.path + "': " + error.message());
      return false;
    }
  }

  const bool generated = cw::EmitBackendOutput(module, target, options.kind, *outputs[0].stream, diagnostics);
  if (generated && outputs.size() == 2) *outputs[1].stream << interface_text;
  bool finished = true;
  for (auto& file : outputs) {
    if (!FinishOutput(*file.stream, file.path, true, diagnostics)) finished = false;
    file.stream.reset();
  }
  success = generated && finished && !diagnostics.HasErrors();
  return success;
}

void DiscardTemporaryFile(llvm_fs::TempFile& file, cw::DiagnosticEngine& diagnostics) {
  if (auto error = file.discard()) {
    diagnostics.Add(cw::kErrorDiagnostic,
                    "cannot remove temporary file '" + file.TmpName + "': " + llvm::toString(std::move(error)));
  }
}

bool CloseTemporaryFile(llvm_fs::TempFile& file, cw::DiagnosticEngine& diagnostics) {
  if (auto error = llvm_fs::closeFile(file.FD)) {
    diagnostics.Add(cw::kErrorDiagnostic, "cannot close temporary file '" + file.TmpName + "': " + error.message());
    return false;
  }
  return true;
}

bool CheckLinkOutput(const std::string& path, const std::vector<InputFile>& inputs, cw::DiagnosticEngine& diagnostics) {
  llvm_fs::file_status status;
  auto error = llvm_fs::status(path, status);
  if (error == std::errc::no_such_file_or_directory) {
    return true;
  }
  if (error) {
    diagnostics.Add(cw::kErrorDiagnostic, "cannot inspect output '" + path + "': " + error.message());
    return false;
  }
  if (!llvm_fs::is_regular_file(status)) {
    diagnostics.Add(cw::kErrorDiagnostic, "executable output '" + path + "' must be a regular file");
    return false;
  }
  return CheckOutputIdentity(path, status, inputs, diagnostics);
}

bool PrepareLinkInputs(const CompileOptions& options, const std::string& object, std::vector<InputFile>& inputs,
                       std::vector<std::string>& arguments, cw::DiagnosticEngine& diagnostics) {
  bool object_added = false;
  for (const auto& input : options.link_inputs) {
    if (input.kind == LinkInput::Kind::Source) {
      // All frontend inputs form one object, placed at the first frontend input.
      if (!object_added) {
        arguments.push_back(object);
        object_added = true;
      }
    } else if (input.kind == LinkInput::Kind::Option || input.kind == LinkInput::Kind::LinkerOption) {
      arguments.push_back(input.value);
    } else {
      std::error_code error;
      auto path = fs::absolute(input.value, error).string();
      llvm_fs::file_status status;
      if (!error) {
        error = llvm_fs::status(path, status);
      }
      if (error || !llvm_fs::is_regular_file(status)) {
        diagnostics.Add(cw::kErrorDiagnostic, "cannot read link input '" + input.value + "'" +
                                                  (error ? ": " + error.message() : ": not a regular file"));
        return false;
      }
      inputs.push_back({path, status.getUniqueID()});
      // Absolute paths also prevent a filename beginning with '-' from becoming a linker option.
      arguments.push_back(std::move(path));
    }
  }
  return true;
}

bool LinkExecutable(const std::vector<std::string>& arguments, const std::string& output,
                    const std::vector<InputFile>& inputs, const cw::driver::DarwinToolChain& toolchain,
                    cw::DiagnosticEngine& diagnostics) {
  // Keep source and linker inputs protected, including their aliases, before asking ld to write anything.
  if (!CheckLinkOutput(output, inputs, diagnostics)) {
    return false;
  }
  std::error_code error;
  auto destination = fs::absolute(output, error);
  if (!error) {
    destination = fs::weakly_canonical(destination, error);
  }
  if (error) {
    diagnostics.Add(cw::kErrorDiagnostic, "cannot resolve output '" + output + "': " + error.message());
    return false;
  }

  // ld owns its output writes. Publish a successful image with a same-directory rename,
  // so link failures cannot damage an existing output or require guessing which file ld created.
  auto image = llvm_fs::TempFile::create((destination.parent_path() / ".cwc-%%%%%%").string());
  if (!image) {
    diagnostics.Add(cw::kErrorDiagnostic,
                    "cannot prepare executable output '" + output + "': " + llvm::toString(image.takeError()));
    return false;
  }
  llvm::scope_exit discard_image([&] { DiscardTemporaryFile(*image, diagnostics); });
  if (!CloseTemporaryFile(*image, diagnostics) || !toolchain.Link(arguments, image->TmpName, diagnostics)) {
    return false;
  }
  if (!CheckLinkOutput(output, inputs, diagnostics) ||
      !CheckLinkOutput(destination.string(), inputs, diagnostics)) {
    return false;
  }
  if (auto error = llvm_fs::rename(image->TmpName, destination.string())) {
    diagnostics.Add(cw::kErrorDiagnostic, "cannot publish executable '" + output + "': " + error.message());
    return false;
  }
  return true;
}

bool LinkWebAssembly(const CompileOptions& options, const std::vector<InputFile>& inputs, llvm::Module& module,
                     llvm::TargetMachine& target, const cw::driver::WebAssemblyToolChain& toolchain,
                     cw::DiagnosticEngine& diagnostics) {
  if (!CheckLinkOutput(options.output, inputs, diagnostics)) {
    return false;
  }
  std::error_code error;
  auto destination = fs::absolute(options.output, error);
  if (!error) {
    destination = fs::weakly_canonical(destination, error);
  }
  if (error) {
    diagnostics.Add(cw::kErrorDiagnostic, "cannot resolve output '" + options.output + "': " + error.message());
    return false;
  }

  llvm::SmallString<256> model;
  llvm::sys::path::system_temp_directory(true, model);
  llvm::sys::path::append(model, "cwc-%%%%%%.wasm.o");
  auto object = llvm_fs::TempFile::create(model);
  if (!object) {
    diagnostics.Add(cw::kErrorDiagnostic, "cannot create temporary object: " + llvm::toString(object.takeError()));
    return false;
  }
  llvm::scope_exit discard_object([&] { DiscardTemporaryFile(*object, diagnostics); });
  {
    llvm::raw_fd_ostream stream(object->FD, false);
    const bool generated = cw::EmitBackendOutput(module, target, cw::BackendOutputKind::Object, stream, diagnostics);
    const bool finished = FinishOutput(stream, object->TmpName, false, diagnostics);
    if (!generated || !finished) {
      return false;
    }
  }
  if (!CloseTemporaryFile(*object, diagnostics)) {
    return false;
  }

  auto image = llvm_fs::TempFile::create((destination.parent_path() / ".cwc-%%%%%%.wasm").string());
  if (!image) {
    diagnostics.Add(cw::kErrorDiagnostic,
                    "cannot prepare Wasm output '" + options.output + "': " + llvm::toString(image.takeError()));
    return false;
  }
  llvm::scope_exit discard_image([&] { DiscardTemporaryFile(*image, diagnostics); });
  if (!CloseTemporaryFile(*image, diagnostics) || !toolchain.Link({object->TmpName}, image->TmpName, diagnostics)) {
    return false;
  }
  if (!CheckLinkOutput(options.output, inputs, diagnostics) ||
      !CheckLinkOutput(destination.string(), inputs, diagnostics)) {
    return false;
  }
  if (auto publish_error = llvm_fs::rename(image->TmpName, destination.string())) {
    diagnostics.Add(cw::kErrorDiagnostic,
                    "cannot publish Wasm output '" + options.output + "': " + publish_error.message());
    return false;
  }
  return true;
}

bool Compile(const CompileOptions& options, const std::string& executable_directory,
             cw::DiagnosticEngine& diagnostics) {
  std::vector<cw::Source> sources;
  std::vector<InputFile> input_files;
  if (!ReadSources(options, sources, input_files, diagnostics)) {
    return false;
  }
  diagnostics.SetSources(&sources);
  llvm::scope_exit release_sources([&] { diagnostics.SetSources(nullptr); });
  auto target_info = options.target.empty() ? cw::TargetInfo::CreateNative() : cw::TargetInfo::Create(options.target);
  if (!target_info) {
    diagnostics.Add(cw::kErrorDiagnostic, "unsupported target '" +
                                              (options.target.empty() ? std::string("native") : options.target) +
                                              "'; expected macOS arm64 or wasm32-unknown-unknown");
    return false;
  }
  const bool wasm_link = options.link && target_info->IsWasm32();
  if (wasm_link) {
    for (const auto& input : options.link_inputs) {
      if (input.kind != LinkInput::Kind::Source && input.kind != LinkInput::Kind::LinkerOption) {
        diagnostics.Add(cw::kErrorDiagnostic, "Wasm executable output accepts CW source files only; link input '" +
                                                  input.value + "' is not supported");
        return false;
      }
    }
  } else if (options.link && HasLinkerOptions(options)) {
    diagnostics.Add(cw::kErrorDiagnostic, "linker options are not supported for native output");
    return false;
  }
  if (!options.target.empty() && !target_info->GetTriple().isMacOSX() &&
      (!options.toolchain.sysroot.empty() || !options.toolchain.minimum_macos_version.empty())) {
    diagnostics.Add(cw::kErrorDiagnostic, "macOS toolchain options require a macOS target");
    return false;
  }

  std::optional<cw::driver::DarwinToolChain> darwin_toolchain;
  std::optional<cw::driver::WebAssemblyToolChain> wasm_toolchain;
  llvm::VersionTuple minimum_version;
  if (options.link) {
    if (wasm_link) {
      wasm_toolchain =
          cw::driver::WebAssemblyToolChain::Create(GetLinkerOptions(options), executable_directory, diagnostics);
      if (!wasm_toolchain || diagnostics.HasErrors()) {
        return false;
      }
    } else {
      darwin_toolchain = cw::driver::DarwinToolChain::Create(options.toolchain, *target_info, diagnostics);
      if (!darwin_toolchain || diagnostics.HasErrors()) {
        return false;
      }
      minimum_version = darwin_toolchain->GetMinimumOSVersion();
    }
  }
  std::optional<llvm_fs::TempFile> object;
  llvm::scope_exit discard_object([&] {
    if (object) DiscardTemporaryFile(*object, diagnostics);
  });
  if (!sources.empty()) {
    auto target = cw::CodeGen::CreateTarget(*target_info, diagnostics, minimum_version);
    llvm::LLVMContext llvm_context;
    std::string interface_text;
    auto module = target ? GenerateModule(
                               sources, diagnostics, llvm_context, *target_info, *target,
                               !options.link && options.kind == cw::BackendOutputKind::Object ? &interface_text : nullptr)
                         : nullptr;
    if (!module) {
      return false;
    }
    if (darwin_toolchain) {
      module->setSDKVersion(darwin_toolchain->GetSDKVersion());
    }
    if (!options.link) {
      return WriteOutput(options, input_files, *module, *target, interface_text, diagnostics);
    }
    if (wasm_link) {
      return LinkWebAssembly(options, input_files, *module, *target, *wasm_toolchain, diagnostics);
    }

    llvm::SmallString<256> model;
    llvm::sys::path::system_temp_directory(true, model);
    llvm::sys::path::append(model, "cwc-%%%%%%.o");
    auto temporary = llvm_fs::TempFile::create(model);
    if (!temporary) {
      diagnostics.Add(cw::kErrorDiagnostic, "cannot create temporary object: " + llvm::toString(temporary.takeError()));
      return false;
    }
    object = std::move(*temporary);
    {
      llvm::raw_fd_ostream stream(object->FD, false);
      const bool generated = cw::EmitBackendOutput(*module, *target, cw::BackendOutputKind::Object, stream, diagnostics);
      const bool finished = FinishOutput(stream, object->TmpName, false, diagnostics);
      if (!generated || !finished) {
        return false;
      }
    }
    if (!CloseTemporaryFile(*object, diagnostics)) {
      return false;
    }
  }
  std::vector<std::string> arguments;
  if (!PrepareLinkInputs(options, object ? object->TmpName : "", input_files, arguments, diagnostics)) {
    return false;
  }
  return LinkExecutable(arguments, options.output, input_files, *darwin_toolchain, diagnostics);
}

}  // namespace

int main(int argc, char* argv[]) {
  const std::string executable_directory = GetExecutableDirectory(argv[0]);
  std::signal(SIGPIPE, SIG_IGN);
  CompileOptions options;
  cw::DiagnosticEngine diagnostics;
  const auto config = cw::driver::DriverOptions::Parse(argc, argv, diagnostics);
  if (!config) {
    diagnostics.Dump(std::cerr);
    return 1;
  }
  if (config->help) {
    cw::driver::DriverOptions::PrintHelp(llvm::outs());
    return 0;
  }

  auto fail = [&](std::string message) {
    diagnostics.Add(cw::kErrorDiagnostic, std::move(message));
    diagnostics.Dump(std::cerr);
    return 1;
  };

  if (config->target) {
    options.target = *config->target;
    if (options.target.empty()) {
      return fail("target triple must not be empty");
    }
  }
  if (config->items.empty()) {
    return fail("no input files");
  }
  if (config->compile_only && config->assemble) {
    return fail("-c and -S cannot be used together");
  }
  options.link = !config->assemble && !config->compile_only;
  if (config->assemble) {
    if (!config->emit_llvm) {
      return fail("assembly output is not supported; use -S -emit-llvm for LLVM IR");
    }
    options.kind = cw::BackendOutputKind::LLVMIR;
  } else if (config->emit_llvm) {
    return fail("LLVM bitcode output is not supported; use -S -emit-llvm for LLVM IR");
  }

  bool has_input = false;
  for (const auto& item : config->items) {
    switch (item.kind) {
      case cw::driver::DriverItem::Kind::Input: {
        has_input = true;
        const auto extension = fs::path(item.value).extension();
        const bool link_file = extension == ".o" || extension == ".a" || extension == ".dylib";
        if (link_file && !options.link) {
          return fail("link input '" + item.value + "' requires executable output");
        }
        if (!link_file) {
          options.inputs.push_back(item.value);
        }
        options.link_inputs.push_back({link_file ? LinkInput::Kind::File : LinkInput::Kind::Source, item.value});
        break;
      }
      case cw::driver::DriverItem::Kind::LibraryPath:
      case cw::driver::DriverItem::Kind::Library:
        if (!options.link || item.value.empty()) {
          return fail("library options require executable output and a nonempty value");
        }
        if (item.kind == cw::driver::DriverItem::Kind::Library) has_input = true;
        options.link_inputs.push_back(
            {LinkInput::Kind::Option,
             (item.kind == cw::driver::DriverItem::Kind::LibraryPath ? "-L" : "-l") + item.value});
        break;
      case cw::driver::DriverItem::Kind::LinkerOption:
        options.link_inputs.push_back({LinkInput::Kind::LinkerOption, item.value});
        break;
    }
  }

  if (!options.link && HasLinkerOptions(options)) {
    return fail("linker options require executable output");
  }
  if (std::count(options.inputs.begin(), options.inputs.end(), "-") > 1) {
    return fail("standard input may only be specified once");
  }
  if (!has_input) {
    return fail("no input files");
  }
  if (config->sysroot) {
    options.toolchain.sysroot = *config->sysroot;
    if (options.toolchain.sysroot.empty()) {
      return fail("toolchain options require a nonempty value");
    }
  }
  if (config->minimum_macos_version) {
    options.toolchain.minimum_macos_version = *config->minimum_macos_version;
    if (options.toolchain.minimum_macos_version.empty()) {
      return fail("toolchain options require a nonempty value");
    }
  }
  if (!options.link && (config->sysroot || config->minimum_macos_version)) {
    return fail("macOS toolchain options require executable output");
  }

  if (config->output) {
    options.output = *config->output;
    if (options.output.empty()) {
      return fail("output path must not be empty");
    }
  } else if (options.link) {
    options.output = "a.out";
  } else {
    if (options.inputs.size() != 1) {
      return fail("multiple inputs require an explicit -o output");
    }
    options.output = fs::path(options.inputs.front())
                         .filename()
                         .replace_extension(options.kind == cw::BackendOutputKind::Object ? ".o" : ".ll")
                         .string();
  }

  if (options.link && options.output == "-") {
    return fail("executable output cannot be written to standard output");
  }
  if (!options.link && options.kind == cw::BackendOutputKind::Object && options.output == "-") {
    return fail("object and interface outputs require a file path; -c -o - is not supported");
  }

  const bool success = Compile(options, executable_directory, diagnostics);
  diagnostics.Dump(std::cerr);
  return success && !diagnostics.HasErrors() ? 0 : 1;
}
