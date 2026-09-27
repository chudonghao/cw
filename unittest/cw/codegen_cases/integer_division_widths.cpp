/// \file integer_division_widths.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

// All divisors are nonzero. The signed cases explicitly preserve CW's MIN / -1 and MIN % -1 results.

signed char ByteQuotient(signed char dividend, signed char divisor) {
  if (dividend == -128 && divisor == -1) {
    return dividend;
  }
  return dividend / divisor;
}

signed char ByteRemainder(signed char dividend, signed char divisor) {
  if (divisor == -1) {
    return 0;
  }
  return dividend % divisor;
}

short WordQuotient(short dividend, short divisor) {
  if (dividend == -32768 && divisor == -1) {
    return dividend;
  }
  return dividend / divisor;
}

long long WideRemainder(long long dividend, long long divisor) {
  if (divisor == -1) {
    return 0;
  }
  return dividend % divisor;
}

long SizeQuotient(long dividend, long divisor) {
  if (dividend == (-9223372036854775807L - 1) && divisor == -1) {
    return dividend;
  }
  return dividend / divisor;
}

unsigned char UnsignedByteQuotient(unsigned char dividend, unsigned char divisor) { return dividend / divisor; }

unsigned short UnsignedWordRemainder(unsigned short dividend, unsigned short divisor) { return dividend % divisor; }

unsigned int Unsigned32Quotient(unsigned int dividend, unsigned int divisor) { return dividend / divisor; }

unsigned long long UnsignedWideRemainder(unsigned long long dividend, unsigned long long divisor) {
  return dividend % divisor;
}

unsigned long UnsignedSizeQuotient(unsigned long dividend, unsigned long divisor) { return dividend / divisor; }

unsigned long long UnsignedMaximumQuotient(unsigned long long value) { return value / 18446744073709551615ULL; }

unsigned long long UnsignedMaximumRemainder(unsigned long long value) { return value % 18446744073709551615ULL; }

// CW defines these boundaries; the corresponding C++ division and remainder would be undefined.
long long MinimumQuotient() { return (-9223372036854775807LL - 1); }

long long MinimumRemainder() { return 0; }
