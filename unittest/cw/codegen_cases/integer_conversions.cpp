/// \file integer_conversions.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

// CW conversions keep low bits or extend using the source signedness.
// Out-of-range conversions to signed types are implementation-defined in C++17;
// this native Clang reference uses the same low-bit interpretation as CW.

long long SignExtend(signed char value) { return static_cast<long long>(value); }

long long ZeroExtend(unsigned char value) { return static_cast<long long>(value); }

unsigned long long SignExtendToUnsigned(short value) { return static_cast<unsigned long long>(value); }

long long UnsignedToSignedWide(unsigned int value) { return static_cast<long long>(value); }

unsigned char NarrowUnsigned(long long value) { return static_cast<unsigned char>(value); }

short NarrowSigned(unsigned long long value) { return static_cast<short>(value); }

unsigned int SameWidth(int value) { return static_cast<unsigned int>(value); }

unsigned long SizeToUnsigned(long value) { return static_cast<unsigned long>(value); }

long SizeToSigned(unsigned long value) { return static_cast<long>(value); }

int UnsignedAsSignedByte(unsigned char value) {
  signed char byte = static_cast<signed char>(value);
  return byte;
}

int SignedAsUnsignedByte(signed char value) {
  unsigned char byte = static_cast<unsigned char>(value);
  return byte;
}
