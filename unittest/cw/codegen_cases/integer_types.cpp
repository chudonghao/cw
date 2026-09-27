/// \file integer_types.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

signed char Signed8(signed char value) { return value; }

unsigned char Unsigned8(unsigned char value) { return value; }

short Signed16(short value) { return value; }

unsigned short Unsigned16(unsigned short value) { return value; }

int Signed32(int value) { return value; }

unsigned int Unsigned32(unsigned int value) { return value; }

long long Signed64(long long value) { return value; }

unsigned long long Unsigned64(unsigned long long value) { return value; }

long SignedSize(long value) { return value; }

unsigned long UnsignedSize(unsigned long value) { return value; }

signed char ForwardSigned8(signed char value) { return Signed8(value); }

unsigned char ForwardUnsigned8(unsigned char value) { return Unsigned8(value); }

short ForwardSigned16(short value) { return Signed16(value); }

unsigned short ForwardUnsigned16(unsigned short value) { return Unsigned16(value); }

unsigned char ForwardNarrow(long long value) { return Unsigned8(static_cast<unsigned char>(value)); }
