/// \file integer_arithmetic_widths.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

// CW keeps narrow arithmetic at its common type width. C++ promotes narrow operands to int.
// Native Clang's C++17 signed narrowing keeps low bits; CW defines that result directly.
signed char SignedByteArithmetic(signed char left, signed char right) {
  return static_cast<signed char>((+left + -right) * (left - right));
}

unsigned short UnsignedWordArithmetic(unsigned short left, unsigned short right) {
  auto sum = static_cast<unsigned short>(left + right);
  auto difference = static_cast<unsigned short>(left - right);
  return static_cast<unsigned short>(static_cast<unsigned int>(sum) * difference);
}

unsigned long long UnsignedWideArithmetic(unsigned long long left, unsigned long long right) {
  return (left + right) * (left - right);
}

// Unsigned subtraction avoids C++ signed overflow at the minimum value.
long long SignedWideNegate(long long value) {
  return static_cast<long long>(0ULL - static_cast<unsigned long long>(value));
}

// CW's common type is u16; make both that conversion and the wrapping addition explicit.
int MixedArithmetic(signed char left, unsigned short right) {
  return static_cast<unsigned short>(static_cast<unsigned short>(left) + right);
}

unsigned long SizeArithmetic(long left, unsigned long right) { return left + right; }
