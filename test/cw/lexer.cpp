
#include <gtest/gtest.h>

#include "cw/Lexer.h"


TEST(Lexer, Basic) {
  cw::Lexer lexer;

  const char *content =
      "\n"
      "// comment\n"
      "true\n"
      "false\n"
      "123\n"
      "1111111111111111111\n"
      "1.\n"
      ".33\n"
      R"("str" "\nstr")"
      "\n"
      "struct\n"
      "virtual\n"
      "func\n"
      "var\n"
      "alias\n"
      "if\n"
      "else\n"
      "for\n"
      "break\n"
      "continue\n"
      "return\n"

      "abc_123\n"
      "标识符\n"

      "~\n"
      "||\n"
      "|=\n"
      "|\n"
      "^=\n"
      "^\n"
      "?\n"
      ">>=\n"
      ">>\n"
      ">=\n"
      ">\n"
      "==\n"
      "=\n"
      "<<=\n"
      "<<\n"
      "<=\n"
      "<\n"
      "::\n"
      ":\n"
      "/=\n"
      "/\n"
      ".\n"
      "->\n"
      "-=\n"
      "--\n"
      "-\n"
      ",\n"
      "+=\n"
      "++\n"
      "+\n"
      "*=\n"
      "*\n"
      "&=\n"
      "&&\n"
      "&\n"
      "%=\n"
      "%\n"
      "!=\n"
      "!\n"
      ";\n"
      "[\n"
      "]\n"
      "(\n"
      ")\n"
      "{\n"
      "}\n"
      "";

  std::vector<cw::Source> sources = {
      {"test.cw", content},
  };

  lexer.Reset(sources);
  ASSERT_EQ(lexer.Token().type, cw::tok::bool_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::bool_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::integer);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::integer);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::float_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::float_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::string_literal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::string_literal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::struct_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::virtual_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::func);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::var);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::alias);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::if_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::else_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::for_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::break_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::continue_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::return_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::identifier);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::identifier);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::tilde);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::pipepipe);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::pipeequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::pipe);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::caretequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::caret);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::question);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::greatergreaterequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::greatergreater);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::greaterequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::greater);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::equalequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::equal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::lesslessequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::lessless);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::lessequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::less);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::coloncolon);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::colon);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::slashequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::slash);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::period);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::arrow);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::minusequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::minusminus);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::minus);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::comma);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::plusequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::plusplus);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::plus);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::starequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::star);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::ampequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::ampamp);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::amp);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::percentequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::percent);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::exclaimequal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::exclaim);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::semi);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::l_square);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::r_square);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::l_paren);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::r_paren);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::l_brace);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::r_brace);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::unknown);
}
