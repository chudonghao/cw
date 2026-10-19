/// \file literal_test.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include <cstdint>

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

  EXPECT_TRUE(llvm::APSInt::isSameValue(value->value, llvm::APSInt("18446744073709551616")));

  auto large = cw::ParseIntegerLiteral("0x100000000000000000000000000000000");
  ASSERT_TRUE(large);
  EXPECT_TRUE(llvm::APSInt::isSameValue(large->value, llvm::APSInt("340282366920938463463374607431768211456")));

  EXPECT_FALSE(cw::ParseIntegerLiteral("0x"));
  EXPECT_FALSE(cw::ParseIntegerLiteral("0b2"));
}

TEST(Literal, PreservesIntegerSuffixAndExactValue) {
  auto minimum_magnitude = cw::ParseIntegerLiteral("128i8");
  ASSERT_TRUE(minimum_magnitude);
  EXPECT_EQ(minimum_magnitude->suffix, cw::BuiltinTypeKind::I8);
  EXPECT_EQ(minimum_magnitude->value.getZExtValue(), 128);

  auto overflow = cw::ParseIntegerLiteral("18446744073709551616usize");
  ASSERT_TRUE(overflow);
  EXPECT_EQ(overflow->suffix, cw::BuiltinTypeKind::USize);
  EXPECT_TRUE(llvm::APSInt::isSameValue(overflow->value, llvm::APSInt("18446744073709551616")));

  auto binary = cw::ParseIntegerLiteral("0b11111111u8");
  ASSERT_TRUE(binary);
  EXPECT_EQ(binary->suffix, cw::BuiltinTypeKind::U8);
  EXPECT_EQ(binary->value.getZExtValue(), 255);

  auto octal = cw::ParseIntegerLiteral("0o100000i16");
  ASSERT_TRUE(octal);
  EXPECT_EQ(octal->suffix, cw::BuiltinTypeKind::I16);
  EXPECT_EQ(octal->value.getZExtValue(), 32768);

  auto hexadecimal = cw::ParseIntegerLiteral("0x1f32");
  ASSERT_TRUE(hexadecimal);
  EXPECT_EQ(hexadecimal->suffix, cw::BuiltinTypeKind::Invalid);
  EXPECT_EQ(hexadecimal->value.getZExtValue(), 7986);

  auto suffixed_hexadecimal = cw::ParseIntegerLiteral("0x1f32u16");
  ASSERT_TRUE(suffixed_hexadecimal);
  EXPECT_EQ(suffixed_hexadecimal->suffix, cw::BuiltinTypeKind::U16);
  EXPECT_EQ(suffixed_hexadecimal->value.getZExtValue(), 7986);
}

TEST(Literal, RejectsInvalidIntegerSuffixes) {
  EXPECT_FALSE(cw::ParseIntegerLiteral("1f32"));
  EXPECT_FALSE(cw::ParseIntegerLiteral("1f64"));
  EXPECT_FALSE(cw::ParseIntegerLiteral("0b1f32"));
  EXPECT_FALSE(cw::ParseIntegerLiteral("0o1f64"));
  EXPECT_FALSE(cw::ParseIntegerLiteral("1I32"));
  EXPECT_FALSE(cw::ParseIntegerLiteral("1_i32"));
  EXPECT_FALSE(cw::ParseIntegerLiteral("1 i32"));
  EXPECT_FALSE(cw::ParseIntegerLiteral("1u128"));
  EXPECT_FALSE(cw::ParseIntegerLiteral("1bool"));
  EXPECT_FALSE(cw::ParseIntegerLiteral("-1i8"));
  EXPECT_FALSE(cw::ParseIntegerLiteral("0xi8"));
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
  ASSERT_EQ(&double_value->value.getSemantics(), &llvm::APFloat::IEEEdouble());
  EXPECT_EQ(double_value->value.bitcastToAPInt().getZExtValue(), 0x40091eb851eb851fULL);

  auto float_value = cw::ParseFloatLiteral("3.14f32");
  ASSERT_TRUE(float_value);
  ASSERT_EQ(&float_value->value.getSemantics(), &llvm::APFloat::IEEEsingle());
  EXPECT_EQ(float_value->value.bitcastToAPInt().getZExtValue(), 0x4048f5c3U);

  auto explicit_double = cw::ParseFloatLiteral("3.14f64");
  ASSERT_TRUE(explicit_double);
  ASSERT_EQ(&explicit_double->value.getSemantics(), &llvm::APFloat::IEEEdouble());
  EXPECT_EQ(explicit_double->value.bitcastToAPInt(), double_value->value.bitcastToAPInt());

  EXPECT_FALSE(cw::ParseFloatLiteral("not-a-float"));
}

TEST(Literal, RejectsInvalidFloatingSuffixesAndNumberForms) {
  EXPECT_FALSE(cw::ParseFloatLiteral("1.0f"));
  EXPECT_FALSE(cw::ParseFloatLiteral("1.0F"));
  EXPECT_FALSE(cw::ParseFloatLiteral("1.0F32"));
  EXPECT_FALSE(cw::ParseFloatLiteral("1.0_f32"));
  EXPECT_FALSE(cw::ParseFloatLiteral("1.0i32"));
  EXPECT_FALSE(cw::ParseFloatLiteral("1e3u64"));
  EXPECT_FALSE(cw::ParseFloatLiteral("1f32"));
  EXPECT_FALSE(cw::ParseFloatLiteral("1f64"));
  EXPECT_FALSE(cw::ParseFloatLiteral("0x1p0"));
  EXPECT_FALSE(cw::ParseFloatLiteral("0x1.8p1f32"));
  EXPECT_FALSE(cw::ParseFloatLiteral("-1.0f32"));
}

TEST(Literal, ParsesStringLiteralEscapes) {
  auto value = cw::ParseStringLiteral(R"("line\n\x41")");
  ASSERT_TRUE(value);
  EXPECT_EQ(value->value, "line\nA");
  EXPECT_FALSE(cw::ParseStringLiteral("not-a-string"));
}

TEST(Literal, RoundsFloatingLiteralsDirectlyToTheirFormat) {
  const struct {
    const char* spelling;
    std::uint64_t bits;
  } cases[] = {
      // Nearest-even ties, and a value that double rounding would round down.
      {"1.000000059604644775390625f32", 0x3f800000U},
      {"1.000000059604644775390626f32", 0x3f800001U},
      {"1.000000178813934326171875f32", 0x3f800002U},
      {"1.00000000000000011102230246251565404236316680908203125", 0x3ff0000000000000ULL},
      {"1.00000000000000011102230246251565404236316680908203126", 0x3ff0000000000001ULL},
      {"1e-45f32", 1},
      {"1e-46f32", 0},
      {"5e-324", 1},
      {"1e-400", 0},
      // Overflow remains available for Sema to diagnose on the literal node.
      {"1e40f32", 0x7f800000U},
      {"1e400", 0x7ff0000000000000ULL},
  };
  for (const auto& test : cases) {
    SCOPED_TRACE(test.spelling);
    const auto value = cw::ParseFloatLiteral(test.spelling);
    ASSERT_TRUE(value);
    EXPECT_EQ(value->value.bitcastToAPInt().getZExtValue(), test.bits);
  }
}
