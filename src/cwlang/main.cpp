/// \file main.cpp
/// \author Donghao Chu
/// \date 2025-01-06
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

#include <boost/filesystem.hpp>
#include <boost/program_options.hpp>

#include "cw/lang/Lexer.h"
#include "cw/lang/Parser.h"
#include "cw/lang/Source.h"

namespace fs = boost::filesystem;

class Compiler {
  cw::Lexer lexer;
  cw::Parser parser;

 public:
  void Compile(const std::vector<cw::Source>& sources) {
    lexer.Reset(&sources);
    parser.Reset(&lexer);

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
      if (input.empty() || input == "--") {
        return;
      }
      ReadSource(input);
    }
    std::string input;
    while (std::getline(std::cin, input)) {
      if (input.empty() || input == "--") {
        return;
      }
      ReadSource(input);
    }
  }

  // main loop
  void Run(const std::vector<std::string>& inputs_from_args) {
    CollectSources(inputs_from_args);
    compiler.Compile(sources);
  }
};

int main(int argc, char* argv[]) {
  std::vector<std::string> inputs_from_args;
  for (int i = 1; i < argc; ++i) {
    if (strcmp(argv[i], "--") == 0) {
      for (int j = i + 1; j < argc; ++j) {
        inputs_from_args.push_back(argv[j]);
      }
      argc = i;
      break;
    }
  }

  try {
    boost::program_options::options_description desc("Allowed options");
    desc.add_options()("help,h", "Display help information");
    desc.add_options()("output,o", boost::program_options::value<std::string>(), "Output file");

    boost::program_options::variables_map vm;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, desc), vm);
    boost::program_options::notify(vm);

    if (vm.count("help")) {
      std::cout << desc;
      std::cout << "Usage: cwlang [options] [-- [file1] [file2] ...]\n";
      return 0;
    }
    Machine machine;
    machine.Run(inputs_from_args);
    return 0;
  } catch (std::exception& e) {
    std::cerr << e.what() << "\n";
    return -1;
  } catch (...) {
    std::cerr << "unknown error\n";
    return -1;
  }
}