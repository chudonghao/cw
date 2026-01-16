
#include <gtest/gtest.h>

#include <exception>
#include <iostream>

#include "cw/ExprParser.h"
#include "cw/Lexer.h"
#include "cw/Parser.h"
#include "cw/Source.h"
#include "cw/Diagnostic.h"

TEST(Parser, Basic) {
  cw::Lexer lexer;
  cw::Parser parser;
  cw::DiagnosticEngine diagnostic_engine;

  const char *content =
      "struct A {\n"
      "  a int32;\n"
      "  aa int32;\n"
      "}\n";

  const char *content2 =
      "\n"
      "struct A {\n"
      "\n";

  std::vector<cw::Source> sources = {
      {"test.cw", content2},
  };

  lexer.Reset(&sources);
  parser.Reset(&lexer);
  parser.SetDiagnosticEngine(&diagnostic_engine);
  
  auto ast = parser();
}
