/// \file main.cpp
/// \author Donghao Chu
/// \date 2025/01/06
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

#include <boost/filesystem.hpp>
#include <boost/program_options.hpp>

#include "cw/Lexer.h"
#include "cw/Parser.h"
#include "cw/Source.h"

namespace fs = boost::filesystem;
namespace po = boost::program_options;

class Compiler {
  cw::Lexer lexer;
  cw::Parser parser;

 public:
  void Compile(const std::vector<cw::Source>& sources) {
    lexer.Reset(sources);
    parser.Reset(lexer);

    parser();
  }
};

class Machine {
  std::vector<cw::Source> sources;
  Compiler compiler;

 public:
  Machine() {}
  ~Machine() {}

  // parse one source file
  void ReadSource(const std::string& path) noexcept(false) {
    if (!fs::exists(path)) {
      throw std::runtime_error("File not found: " + path);
    }

    {
      std::ifstream ifs(path);
      std::string content((std::istreambuf_iterator<char>(ifs)), std::istreambuf_iterator<char>());

      if (!ifs) {
        throw std::runtime_error("Failed to read file: " + path);
      }

      sources.push_back({path, content});
    }
  }

  void CollectSources(const std::vector<std::string>& inputs_from_args) {
    for (const auto& input : inputs_from_args) {
      if (input.empty() || input == "-") {
        return;
      }
      ReadSource(input);
    }
    std::string input;
    while (std::getline(std::cin, input)) {
      if (input.empty() || input == "-") {
        return;
      }
      ReadSource(input);
    }
  }

  // main loop
  void Run(const std::vector<std::string>& inputs_from_args, const std::string& output_path) {
    CollectSources(inputs_from_args);
    compiler.Compile(sources);
  }
};

int main(int argc, char* argv[]) {
  try {
    po::options_description desc("Allowed options");
    desc.add_options()("help,h", "Display help information");
    desc.add_options()("output,o", po::value<std::string>(), "Output file");
    desc.add_options()("files", po::value<std::vector<std::string>>(), "Input files");

    po::positional_options_description p;
    p.add("files", -1);

    po::variables_map vm;
    po::store(po::command_line_parser(argc, argv).options(desc).positional(p).run(), vm);
    po::notify(vm);

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
    machine.Run(files_from_args, output_path);
    return 0;
  } catch (std::exception& e) {
    std::cerr << e.what() << "\n";
    return -1;
  } catch (...) {
    std::cerr << "unknown error\n";
    return -1;
  }
}