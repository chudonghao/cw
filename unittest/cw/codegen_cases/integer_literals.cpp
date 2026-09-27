/// \file integer_literals.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

// CW character literals are u8. C++ integer promotions and explicit casts express the same byte results.

long long SignedLiteral() { return 2147483648LL; }

unsigned long long UnsignedLiteral() { return 18446744073709551615ULL; }

long long MinimumLiteral() { return (-9223372036854775807LL - 1); }

unsigned short CharacterValue() { return static_cast<unsigned char>('\xFF'); }

unsigned char CharacterArithmetic() { return static_cast<unsigned char>(255u + 1u); }

unsigned char TruncatedLiteral() { return static_cast<unsigned char>(257); }

unsigned long long NegativeUnsignedLiteral() { return static_cast<unsigned long long>(-1); }

unsigned long long InferredLiteral() {
  auto value = 9223372036854775808ULL;
  return value;
}
