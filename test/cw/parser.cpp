
#include <gtest/gtest.h>

#include <boost/leaf.hpp>
#include <boost/leaf/handle_errors.hpp>
#include <exception>
#include <iostream>

#include "cw/Exception.h"
#include "cw/ExprParser.h"
#include "cw/Lexer.h"
#include "cw/Parser.h"
#include "cw/Source.h"

TEST(Parser, Basic) {
  cw::Lexer lexer;
  cw::Parser parser;

  const char *content =
      "struct A {\n"
      "  var a : int;\n"
      "  var aa : int;\n"
      "}\n";

  const char *content2 =
      "\n"
      "struct A {\n"
      "\n";

  std::vector<cw::Source> sources = {
      {"test.cw", content2},
  };

  lexer.Reset(sources);
  parser.Reset(lexer);

  auto try_ = [&]() {
    //
    auto ast = parser();
  };
  auto catch_ = [&](cw::ParseException &e) {
    //
    cw::Dump(std::cout, sources, lexer, e);
  };

  boost::leaf::try_catch(try_, catch_);
}
