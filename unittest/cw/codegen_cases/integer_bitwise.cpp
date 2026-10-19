// CW keeps narrow bitwise results at the operand width. Explicit casts account
// for C++ integer promotions; native Clang preserves low bits when narrowing.
unsigned char UnsignedByte(unsigned char left, unsigned char right) {
  auto inverted = static_cast<unsigned char>(~left);
  auto both = static_cast<unsigned char>(inverted & right);
  auto different = static_cast<unsigned char>(left ^ right);
  return static_cast<unsigned char>(both | different);
}

signed char SignedByte(signed char left, signed char right) {
  auto inverted = static_cast<signed char>(~left);
  auto both = static_cast<signed char>(inverted & right);
  auto different = static_cast<signed char>(left ^ right);
  return static_cast<signed char>(both | different);
}

unsigned short Word(unsigned short left, unsigned short right) {
  auto inverted = static_cast<unsigned short>(~left);
  auto both = static_cast<unsigned short>(inverted & right);
  auto different = static_cast<unsigned short>(left ^ right);
  return static_cast<unsigned short>(both | different);
}

int SignedWord(int left, int right) { return (~left & right) | (left ^ right); }

unsigned long long Wide(unsigned long long left, unsigned long long right) { return (~left & right) | (left ^ right); }

unsigned short Mixed(signed char left, unsigned short right) {
  return static_cast<unsigned short>(static_cast<unsigned short>(left) & right);
}

unsigned long Size(long left, unsigned long right) { return ~left & right; }

int InvertBeforeWidening(unsigned char value) { return static_cast<unsigned char>(~value) & 256; }

// CW defaults this literal to i64, independently of its hexadecimal spelling.
long long FoldedSigned() { return ~0x80000000LL; }

unsigned long long FoldedUnsigned() { return ~18446744073709551615ULL; }
