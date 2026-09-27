/// \file integer_conversion_flow.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

// Native Clang's signed narrowing expresses CW's modulo conversion after the addition.
unsigned int Bump(signed char& value) {
  value = static_cast<signed char>(value + 1);
  return static_cast<unsigned int>(value);
}

// Capture and convert the left value before the right operand mutates it, as CW requires.
unsigned int ReadBeforeBump(signed char& value) {
  unsigned int before = static_cast<unsigned int>(value);
  unsigned int after = Bump(value);
  return before + after;
}

unsigned short& Locate(unsigned short& value) { return value; }

void AssignConverted(unsigned short& value, long long source) { Locate(value) = static_cast<unsigned short>(source); }

unsigned long long ReadWide(const unsigned long long& value) { return value; }

unsigned long long TemporaryWide() { return ReadWide(18446744073709551615ULL); }

short Choose(bool flag, unsigned char left, short right) { return flag ? left : right; }

// C++ promotes the narrow arithmetic; the explicit stores retain CW's modulo results.
unsigned short IntegerLoop(unsigned char limit) {
  unsigned char index = 0;
  unsigned short total = 0;
  unsigned char step = 1;
  while (index < limit) {
    total = static_cast<unsigned short>(total + index);
    index = static_cast<unsigned char>(index + step);
  }
  return total;
}
