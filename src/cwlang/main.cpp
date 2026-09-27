/// \file main.cpp
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include <cerrno>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <memory>
#include <string>
#include <system_error>

#include <boost/program_options.hpp>

#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/Support/ToolOutputFile.h>
#include <llvm/Target/TargetMachine.h>

#include "cw/ASTContext.h"
#include "cw/CodeGen.h"
#include "cw/Diagnostic.h"
#include "cw/Lexer.h"
#include "cw/Parser.h"
#include "cw/Sema.h"
#include "cw/Source.h"

namespace fs = std::filesystem;
namespace po = boost::program_options;

class Compiler {
 public:
  bool Compile(const std::vector<cw::Source>& sources, const std::string& output_path) {
    cw::DiagnosticEngine diagnostics;
    diagnostics.SetSources(&sources);
    auto target_info = cw::TargetInfo::CreateNative();
    if (!target_info) {
      diagnostics.Add(cw::kErrorDiagnostic, "compilation currently supports only native macOS arm64");
      diagnostics.Dump(std::cerr);
      return false;
    }
    auto target = cw::CodeGen::CreateTarget(*target_info, diagnostics);
    llvm::LLVMContext llvm_context;
    auto module = target ? Generate(sources, diagnostics, llvm_context, *target_info, *target) : nullptr;
    if (module) {
      std::error_code error;
      llvm::ToolOutputFile output(output_path, error, llvm::sys::fs::OF_None);
      if (error) {
        diagnostics.Add(cw::kErrorDiagnostic, "cannot open output '" + output_path + "': " + error.message());
      } else {
        module->print(output.os(), nullptr);
        output.os().close();
        if (output.os().has_error()) {
          diagnostics.Add(cw::kErrorDiagnostic,
                          "cannot write output '" + output_path + "': " + output.os().error().message());
          output.os().clear_error();
        } else {
          output.keep();
        }
      }
    }
    diagnostics.Dump(std::cerr);
    return module && !diagnostics.HasErrors();
  }

 private:
  std::unique_ptr<llvm::Module> Generate(const std::vector<cw::Source>& sources, cw::DiagnosticEngine& diagnostics,
                                         llvm::LLVMContext& llvm_context, const cw::TargetInfo& target_info,
                                         const llvm::TargetMachine& target) {
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
    cw::CodeGen codegen;
    codegen.SetASTContext(&ast_context);
    codegen.SetDiagnosticEngine(&diagnostics);
    codegen.SetLLVMContext(&llvm_context);
    codegen.SetTargetMachine(&target);
    return codegen(sources.empty() ? "cw" : sources.front().path.string());
  }
};

class Machine {
  std::vector<cw::Source> sources_;
  Compiler compiler_;

 public:
  Machine() {}
  ~Machine() {}

  /// Reads one source file; returns false and sets ec on an input error.
  bool ReadSource(const std::string& path, std::error_code& ec) {
    if (!fs::exists(path, ec)) {
      if (!ec) {
        ec = std::make_error_code(std::errc::no_such_file_or_directory);
      }
      return false;
    }

    std::ifstream ifs(path);
    std::string content((std::istreambuf_iterator<char>(ifs)), std::istreambuf_iterator<char>());

    if (!ifs) {
      ec = errno ? std::error_code(errno, std::generic_category()) : std::make_error_code(std::errc::io_error);
      return false;
    }

    sources_.push_back({path, content});
    return true;
  }

  bool CollectSources(const std::vector<std::string>& inputs_from_args, std::error_code& ec) {
    for (const auto& input : inputs_from_args) {
      if (input.empty() || input == "-") {
        return true;
      }
      if (!ReadSource(input, ec)) {
        return false;
      }
    }
    if (!inputs_from_args.empty()) {
      return true;
    }
    std::string input;
    while (std::getline(std::cin, input)) {
      if (input.empty() || input == "-") {
        return true;
      }
      if (!ReadSource(input, ec)) {
        return false;
      }
    }
    return true;
  }

  bool Run(const std::vector<std::string>& inputs_from_args, const std::string& output_path, std::error_code& ec) {
    if (!CollectSources(inputs_from_args, ec)) {
      return false;
    }
    return compiler_.Compile(sources_, output_path);
  }
};

int main(int argc, char* argv[]) {
  po::options_description desc("Allowed options");
  desc.add_options()("help,h", "Display help information");
  desc.add_options()("output,o", po::value<std::string>(), "Output file");
  desc.add_options()("files", po::value<std::vector<std::string>>(), "Input files");

  po::positional_options_description p;
  p.add("files", -1);

  po::variables_map vm;
  // Library boundary exception: boost::program_options only reports parse
  // errors via exceptions. This try/catch is limited to command line parsing.
  try {
    po::store(po::command_line_parser(argc, argv).options(desc).positional(p).run(), vm);
    po::notify(vm);
  } catch (const po::error& e) {
    std::cerr << e.what() << "\n";
    return -1;
  }

  if (vm.count("help")) {
    std::cout << desc;
    std::cout << "Usage: cwlang [options] [file1] [file2] ...\n";
    return 0;
  }

  std::vector<std::string> files_from_args;
  if (vm.count("files")) {
    files_from_args = vm["files"].as<std::vector<std::string>>();
  }

  std::string output_path;
  if (vm.count("output")) {
    output_path = vm["output"].as<std::string>();
  }
  if (output_path.empty()) {
    std::cerr << "Output file is not specified\n";
    return -1;
  }

  Machine machine;
  std::error_code ec;
  if (!machine.Run(files_from_args, output_path, ec)) {
    if (ec) {
      std::cerr << "error: " << ec.message() << "\n";
    }
    return -1;
  }
  return 0;
}
