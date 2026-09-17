/// \file lexer_test.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include <gtest/gtest.h>

#include "cw/Lexer.h"

TEST(Lexer, TokenType) {
  cw::Lexer lexer;

  const char* content =
      "\n"
      "// comment\n"
      // Literals.
      "true false null\n"
      "123 0b1010 0o755 0xFF 'a'\n"
      "1. .33 1.0f\n"
      R"("str" "\nstr")"
      "\n"
      // Keywords.
      "struct trivial virtual abstract override func var alias const mut copy move this\n"
      "if else for while break continue return\n"
      "ctor dtor operator\n"
      // Identifiers, including non-ASCII spelling.
      "abc_123 标识符\n"
      // Operators and punctuation.
      "~ || |= | ^= ^ ? >>= >> >= > == = <<= << <= < := : /= / . -> -= -- - , "
      "+= ++ + *= * &= && & %= % != ! ; [ ] ( ) { }\n"
      // undefined
      "\1"
      "\"";

  std::vector<cw::Source> sources = {{"test.cw", content}};
  lexer.Reset(&sources);
  lexer.SkipBlankComment();

  // Literals.
  ASSERT_EQ(lexer.Token().type, cw::tok::bool_literal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::bool_literal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::null_literal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::integer_literal);  // 123
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::integer_literal);  // 0b1010
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::integer_literal);  // 0o755
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::integer_literal);  // 0xFF
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::character_literal);  // 'a'
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::float_literal);  // 1.
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::float_literal);  // .33
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::float_literal);  // 1.0f
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::string_literal);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::string_literal);
  lexer.Advance();

  // Keywords.
  ASSERT_EQ(lexer.Token().type, cw::tok::struct_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::trivial_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::virtual_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::abstract_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::override_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::func);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::var);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::alias);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::const_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::mut);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::copy);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::move_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::this_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::if_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::else_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::for_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::while_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::break_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::continue_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::return_);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::ctor);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::dtor);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::operator_);
  lexer.Advance();

  // Identifiers, including non-ASCII spelling.
  ASSERT_EQ(lexer.Token().type, cw::tok::identifier);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::identifier);
  lexer.Advance();

  // Operators and punctuation.
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
  ASSERT_EQ(lexer.Token().type, cw::tok::colonequal);
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

  // undefined
  ASSERT_EQ(lexer.Token().type, cw::tok::undefined);
  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::undefined);
  lexer.Advance();

  // eos
  ASSERT_EQ(lexer.Token().type, cw::tok::eos);
}

TEST(Lexer, TokenRangeSourceView) {
  cw::Lexer lexer;

  const char* content =
      "true false\n"  // line 0: true(0-4), false(5-10)
      "123 0xFF\n"    // line 1: 123(0-3), 0xFF(4-8)
      "3.14 1.0f\n"   // line 2: 3.14(0-4), 1.0f(5-9)
      R"("hello")"    // line 3: "hello"(0-7)
      "\n"
      "foo\n"    // line 4: foo(0-3)
      "+ ++\n";  // line 5: +(0-1), ++(2-4)

  std::vector<cw::Source> sources = {{"test.cw", content}};
  lexer.Reset(&sources);
  lexer.SkipBlankComment();

  // line 0: true
  {
    auto& t = lexer.Token();
    EXPECT_EQ(t.source_view, "true");
    EXPECT_EQ(t.range.begin.line, 0);
    EXPECT_EQ(t.range.begin.column, 0);
    EXPECT_EQ(t.range.end.line, 0);
    EXPECT_EQ(t.range.end.column, 4);
  }

  // line 0: false
  lexer.Advance();
  {
    auto& t = lexer.Token();
    EXPECT_EQ(t.source_view, "false");
    EXPECT_EQ(t.range.begin.line, 0);
    EXPECT_EQ(t.range.begin.column, 5);
    EXPECT_EQ(t.range.end.line, 0);
    EXPECT_EQ(t.range.end.column, 10);
  }

  // line 1: 123
  lexer.Advance();
  {
    auto& t = lexer.Token();
    EXPECT_EQ(t.source_view, "123");
    EXPECT_EQ(t.range.begin.line, 1);
    EXPECT_EQ(t.range.begin.column, 0);
    EXPECT_EQ(t.range.end.line, 1);
    EXPECT_EQ(t.range.end.column, 3);
  }

  // line 1: 0xFF
  lexer.Advance();
  {
    auto& t = lexer.Token();
    EXPECT_EQ(t.source_view, "0xFF");
    EXPECT_EQ(t.range.begin.line, 1);
    EXPECT_EQ(t.range.begin.column, 4);
    EXPECT_EQ(t.range.end.line, 1);
    EXPECT_EQ(t.range.end.column, 8);
  }

  // line 2: 3.14
  lexer.Advance();
  {
    auto& t = lexer.Token();
    EXPECT_EQ(t.source_view, "3.14");
    EXPECT_EQ(t.range.begin.line, 2);
    EXPECT_EQ(t.range.begin.column, 0);
    EXPECT_EQ(t.range.end.line, 2);
    EXPECT_EQ(t.range.end.column, 4);
  }

  // line 2: 1.0f
  lexer.Advance();
  {
    auto& t = lexer.Token();
    EXPECT_EQ(t.source_view, "1.0f");
    EXPECT_EQ(t.range.begin.line, 2);
    EXPECT_EQ(t.range.begin.column, 5);
    EXPECT_EQ(t.range.end.line, 2);
    EXPECT_EQ(t.range.end.column, 9);
  }

  // line 3: "hello"
  lexer.Advance();
  {
    auto& t = lexer.Token();
    EXPECT_EQ(t.source_view, "\"hello\"");
    EXPECT_EQ(t.range.begin.line, 3);
    EXPECT_EQ(t.range.begin.column, 0);
    EXPECT_EQ(t.range.end.line, 3);
    EXPECT_EQ(t.range.end.column, 7);
  }

  // line 4: foo
  lexer.Advance();
  {
    auto& t = lexer.Token();
    EXPECT_EQ(t.source_view, "foo");
    EXPECT_EQ(t.range.begin.line, 4);
    EXPECT_EQ(t.range.begin.column, 0);
    EXPECT_EQ(t.range.end.line, 4);
    EXPECT_EQ(t.range.end.column, 3);
  }

  // line 5: +
  lexer.Advance();
  {
    auto& t = lexer.Token();
    EXPECT_EQ(t.source_view, "+");
    EXPECT_EQ(t.range.begin.line, 5);
    EXPECT_EQ(t.range.begin.column, 0);
    EXPECT_EQ(t.range.end.line, 5);
    EXPECT_EQ(t.range.end.column, 1);
  }

  // line 5: ++
  lexer.Advance();
  {
    auto& t = lexer.Token();
    EXPECT_EQ(t.source_view, "++");
    EXPECT_EQ(t.range.begin.line, 5);
    EXPECT_EQ(t.range.begin.column, 2);
    EXPECT_EQ(t.range.end.line, 5);
    EXPECT_EQ(t.range.end.column, 4);
  }

  lexer.Advance();
  ASSERT_EQ(lexer.Token().type, cw::tok::eos);
}

TEST(Lexer, TokenProperty) {
  cw::Lexer lexer;

  const char* content =
      // Bool
      "true false\n"
      // Integer: decimal, binary, octal, hex; then character
      "123 0 0b1010 0B1111 0o755 0O17 0xFF 0XAB 0x10000000000000000 'a' '\\n' '\\x41'\n"
      // Float: double, float
      "3.14 1.0f 2.5e10 1.5e-3F\n"
      // String: basic, escapes
      R"("hello" "world\ntest" "tab\there" "quote\"inside" "backslash\\" "\x41\x42")"
      "\n"
      // Identifier
      "foo bar_123\n";

  std::vector<cw::Source> sources = {{"test.cw", content}};
  lexer.Reset(&sources);
  lexer.SkipBlankComment();

  // === Bool ===
  EXPECT_EQ(lexer.Token().get<cw::BoolProperty>().value, true);
  lexer.Advance();
  EXPECT_EQ(lexer.Token().get<cw::BoolProperty>().value, false);
  lexer.Advance();

  // === Integer ===
  // 123 (decimal) -> exact integer
  EXPECT_EQ(lexer.Token().get<cw::IntegerProperty>().value, 123);
  lexer.Advance();
  // 0 (decimal) -> exact integer
  EXPECT_EQ(lexer.Token().get<cw::IntegerProperty>().value, 0);
  lexer.Advance();
  // 0b1010 (binary) -> exact integer
  EXPECT_EQ(lexer.Token().get<cw::IntegerProperty>().value, 0b1010);
  lexer.Advance();
  // 0B1111 (binary) -> exact integer
  EXPECT_EQ(lexer.Token().get<cw::IntegerProperty>().value, 0b1111);
  lexer.Advance();
  // 0o755 (octal) -> exact integer
  EXPECT_EQ(lexer.Token().get<cw::IntegerProperty>().value, 0755);
  lexer.Advance();
  // 0O17 (octal) -> exact integer
  EXPECT_EQ(lexer.Token().get<cw::IntegerProperty>().value, 017);
  lexer.Advance();
  // 0xFF (hex) -> exact integer
  EXPECT_EQ(lexer.Token().get<cw::IntegerProperty>().value, 0xFF);
  lexer.Advance();
  // 0XAB (hex) -> exact integer
  EXPECT_EQ(lexer.Token().get<cw::IntegerProperty>().value, 0xAB);
  lexer.Advance();
  // 2^64 remains exact rather than overflowing uint64_t.
  boost::multiprecision::cpp_int two_to_64 = 1;
  two_to_64 <<= 64;
  EXPECT_EQ(lexer.Token().get<cw::IntegerProperty>().value, two_to_64);
  lexer.Advance();
  // 'a' (char) -> uint8_t character property
  EXPECT_EQ(lexer.Token().get<cw::CharacterProperty>().value, 'a');
  lexer.Advance();
  // '\n' (escape char) -> uint8_t
  EXPECT_EQ(lexer.Token().get<cw::CharacterProperty>().value, '\n');
  lexer.Advance();
  // '\x41' (hex char) -> uint8_t
  EXPECT_EQ(lexer.Token().get<cw::CharacterProperty>().value, 0x41);
  lexer.Advance();

  // === Float ===
  // 3.14 (double)
  {
    auto& prop = lexer.Token().get<cw::FloatProperty>();
    EXPECT_TRUE(std::holds_alternative<double>(prop.value));
    EXPECT_DOUBLE_EQ(std::get<double>(prop.value), 3.14);
  }
  lexer.Advance();
  // 1.0f (float)
  {
    auto& prop = lexer.Token().get<cw::FloatProperty>();
    EXPECT_TRUE(std::holds_alternative<float>(prop.value));
    EXPECT_FLOAT_EQ(std::get<float>(prop.value), 1.0f);
  }
  lexer.Advance();
  // 2.5e10 (double with exponent)
  {
    auto& prop = lexer.Token().get<cw::FloatProperty>();
    EXPECT_TRUE(std::holds_alternative<double>(prop.value));
    EXPECT_DOUBLE_EQ(std::get<double>(prop.value), 2.5e10);
  }
  lexer.Advance();
  // 1.5e-3F (float with exponent)
  {
    auto& prop = lexer.Token().get<cw::FloatProperty>();
    EXPECT_TRUE(std::holds_alternative<float>(prop.value));
    EXPECT_FLOAT_EQ(std::get<float>(prop.value), 1.5e-3f);
  }
  lexer.Advance();

  // === String ===
  // "hello"
  EXPECT_EQ(lexer.Token().get<cw::StringProperty>().value, "hello");
  lexer.Advance();
  // "world\ntest"
  EXPECT_EQ(lexer.Token().get<cw::StringProperty>().value, "world\ntest");
  lexer.Advance();
  // "tab\there"
  EXPECT_EQ(lexer.Token().get<cw::StringProperty>().value, "tab\there");
  lexer.Advance();
  // "quote\"inside"
  EXPECT_EQ(lexer.Token().get<cw::StringProperty>().value, "quote\"inside");
  lexer.Advance();
  // "backslash\\"
  EXPECT_EQ(lexer.Token().get<cw::StringProperty>().value, "backslash\\");
  lexer.Advance();
  // "\x41\x42" = "AB"
  EXPECT_EQ(lexer.Token().get<cw::StringProperty>().value, "AB");
  lexer.Advance();

  // === Identifier ===
  EXPECT_EQ(lexer.Token().get<cw::IdentifierProperty>().name, "foo");
  lexer.Advance();
  EXPECT_EQ(lexer.Token().get<cw::IdentifierProperty>().name, "bar_123");
  lexer.Advance();

  // eos
  ASSERT_EQ(lexer.Token().type, cw::tok::eos);
}
