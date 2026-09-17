/// \file literal_test.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include <gtest/gtest.h>

#include "cw/Literal.h"

TEST(Literal, ParsesBoolLiteral) {
  ASSERT_TRUE(cw::ParseBoolLiteral("true"));
  EXPECT_TRUE(cw::ParseBoolLiteral("true")->value);
  ASSERT_TRUE(cw::ParseBoolLiteral("false"));
  EXPECT_FALSE(cw::ParseBoolLiteral("false")->value);
  EXPECT_FALSE(cw::ParseBoolLiteral("True"));
}

TEST(Literal, ParsesExactIntegerLiteral) {
  auto value = cw::ParseIntegerLiteral("0x10000000000000000");
  ASSERT_TRUE(value);

  boost::multiprecision::cpp_int expected = 1;
  expected <<= 64;
  EXPECT_EQ(value->value, expected);

  EXPECT_FALSE(cw::ParseIntegerLiteral("0x"));
  EXPECT_FALSE(cw::ParseIntegerLiteral("0b2"));
}

TEST(Literal, ParsesCharacterLiteral) {
  ASSERT_TRUE(cw::ParseCharacterLiteral("'a'"));
  EXPECT_EQ(cw::ParseCharacterLiteral("'a'")->value, 'a');
  ASSERT_TRUE(cw::ParseCharacterLiteral("'\\x41'"));
  EXPECT_EQ(cw::ParseCharacterLiteral("'\\x41'")->value, 'A');
  EXPECT_FALSE(cw::ParseCharacterLiteral("'\\x'"));
}

TEST(Literal, ParsesFloatLiteralAccordingToSuffix) {
  auto double_value = cw::ParseFloatLiteral("3.14");
  ASSERT_TRUE(double_value);
  ASSERT_TRUE(std::holds_alternative<double>(double_value->value));
  EXPECT_DOUBLE_EQ(std::get<double>(double_value->value), 3.14);

  auto float_value = cw::ParseFloatLiteral("3.14f");
  ASSERT_TRUE(float_value);
  ASSERT_TRUE(std::holds_alternative<float>(float_value->value));
  EXPECT_FLOAT_EQ(std::get<float>(float_value->value), 3.14f);

  EXPECT_FALSE(cw::ParseFloatLiteral("not-a-float"));
}

TEST(Literal, ParsesStringLiteralEscapes) {
  auto value = cw::ParseStringLiteral(R"("line\n\x41")");
  ASSERT_TRUE(value);
  EXPECT_EQ(value->value, "line\nA");
  EXPECT_FALSE(cw::ParseStringLiteral("not-a-string"));
}
