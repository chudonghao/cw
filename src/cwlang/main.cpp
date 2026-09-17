/// \file main.cpp
/// \copyright 2025 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include <cerrno>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <system_error>

#include <boost/program_options.hpp>

#include "cw/ASTContext.h"
#include "cw/Diagnostic.h"
#include "cw/Lexer.h"
#include "cw/Parser.h"
#include "cw/Sema.h"
#include "cw/Source.h"

namespace fs = std::filesystem;
namespace po = boost::program_options;

class Compiler {
  cw::Lexer lexer;
  cw::Parser parser;
  cw::Sema sema;
  cw::DiagnosticEngine diagnostic_engine;

 public:
  void Compile(const std::vector<cw::Source>* sources) {
    cw::ASTContext ast_context;

    lexer.Reset(sources);
    parser.SetLexer(&lexer);
    parser.SetASTContext(&ast_context);
    parser.SetDiagnosticEngine(&diagnostic_engine);
    parser();

    sema.SetDiagnosticEngine(&diagnostic_engine);
    sema.SetSources(sources);
    sema.SetASTContext(&ast_context);
    sema();
  }
};

class Machine {
  std::vector<cw::Source> sources;
  Compiler compiler;

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

    sources.push_back({path, content});
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
    compiler.Compile(&sources);
    return true;
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
    std::cerr << "error: " << ec.message() << "\n";
    return -1;
  }
  return 0;
}
