/// \file integer_comparison_types.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

bool UnsignedEqual(unsigned long long left, unsigned long long right) { return left == right; }

bool UnsignedNotEqual(unsigned long long left, unsigned long long right) { return left != right; }

bool UnsignedLess(unsigned long long left, unsigned long long right) { return left < right; }

bool UnsignedLessEqual(unsigned long long left, unsigned long long right) { return left <= right; }

bool UnsignedGreater(unsigned long long left, unsigned long long right) { return left > right; }

bool UnsignedGreaterEqual(unsigned long long left, unsigned long long right) { return left >= right; }

// CW converts the signed byte to u16 before comparing; C++ would otherwise compare promoted ints.

bool MixedUnsignedLess(signed char left, unsigned short right) { return static_cast<unsigned short>(left) < right; }

bool MixedSignedLess(short left, unsigned char right) { return left < right; }

bool SameWidthLess(int left, unsigned int right) { return left < right; }
