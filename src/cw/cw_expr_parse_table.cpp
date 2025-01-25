/// \file cw_expr_parse_table.cpp
/// \author Donghao Chu
/// \date 2025/01/14
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include <fstream>
#include <initializer_list>
#include <iostream>
#include <string>

#include <boost/program_options.hpp>

#include "cw/ExprGrammar.h"
#include "cw/lang/Grammar.h"
#include "cw/lang/GrammarAnalyzer.h"
#include "lang/LRParseTable.h"

namespace po = boost::program_options;

void print_header() {
  using namespace cw;

  lang::Grammar g = ExprGrammar();
  auto ga = lang::GrammarAnalyzer::Analyze(g, lang::GrammarAnalyzer::SLR);

  lang::LRParseTable table = ga.CreateLRParseTable();

  std::cout << "// Auto generated file, do not edit!\n";
  std::cout << "#include \"cw/lang/LRParseTable.h\"\n";
  std::cout << "namespace cw {\n";
  std::cout << "inline lang::LRParseTable ExprParseTable() {\n";
  std::cout << "  lang::LRParseTable table;\n";
  std::cout << "  table.Resize(" << table.num_states() << ", " << table.num_symbols() << ");\n";

  // fill table
  for (int s = 0; s < table.num_states(); ++s) {
    for (int i = 0; i < table.num_symbols(); ++i) {
      auto action = table(s, i);
      std::cout << "table(" << s << "," << i << ") = " << "{static_cast<lang::LRActionType>(" << action.type << "), " << action.state << "};\n";
    }
  }

  std::cout << "  return table;\n";
  std::cout << "}\n";
  std::cout << "}\n";
}

void print_table() {
  using namespace cw;

  lang::Grammar g = ExprGrammar();
  auto ga = lang::GrammarAnalyzer::Analyze(g, lang::GrammarAnalyzer::SLR);

  ga.DumpSLRParseTable(std::cout);
}

int main(int argc, char* argv[]) {
  try {
    po::options_description desc("Allowed options");
    desc.add_options()("help,h", "Print help message");
    desc.add_options()("header", "Output as C++ header");

    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    po::notify(vm);

    if (vm.count("help")) {
      std::cout << desc << "\n";
      return 1;
    }

    if (vm.count("header")) {
      print_header();
    } else {
      print_table();
    }
  } catch (std::exception& e) {
    std::cerr << "Error: " << e.what() << "\n";
    return 1;
  } catch (...) {
    std::cerr << "Unknown error!\n";
    return 1;
  }

  return 0;
}
