// Match CW's independent operand types and modulo counts explicitly. Unsigned
// left shifts avoid C++17 signed-shift UB. Native Clang preserves low bits on
// signed conversion and uses arithmetic signed right shifts on macOS arm64.
signed char SignedByte(signed char left, unsigned long long count) {
  return static_cast<signed char>(static_cast<unsigned int>(left) << (count & 7));
}
unsigned char UnsignedByte(unsigned char left, long long count) {
  return static_cast<unsigned char>(left >> (static_cast<unsigned long long>(count) & 7));
}
signed char SignedByteRight(signed char left, long long count) {
  return static_cast<signed char>(left >> (static_cast<unsigned long long>(count) & 7));
}
short SignedWord(short left, unsigned char count) {
  return static_cast<short>(static_cast<unsigned int>(left) << (count & 15));
}
unsigned short UnsignedWord(unsigned short left, signed char count) {
  return static_cast<unsigned short>(left >> (static_cast<unsigned int>(count) & 15));
}
int Signed32(int left, long long count) {
  return static_cast<int>(static_cast<unsigned int>(left) << (static_cast<unsigned long long>(count) & 31));
}
int Signed32Right(int left, unsigned long long count) { return left >> (count & 31); }
unsigned int Unsigned32(unsigned int left, short count) { return left << (static_cast<unsigned int>(count) & 31); }
long long Signed64(long long left, signed char count) { return left >> (static_cast<unsigned int>(count) & 63); }
unsigned long long Unsigned64(unsigned long long left, unsigned int count) { return left << (count & 63); }
long Size(long left, int count) { return left >> (static_cast<unsigned int>(count) & 63); }
unsigned long UnsignedSize(unsigned long left, unsigned char count) { return left << (count & 63); }
unsigned char FixedBySize(unsigned char left, unsigned long count) {
  return static_cast<unsigned char>(static_cast<unsigned int>(left) << (count & 7));
}
int ShiftBeforeWidening(unsigned char left) { return static_cast<unsigned char>(left << 1); }
int Literal32(unsigned long long count) { return static_cast<int>(1U << (count & 31)); }
int FoldedWideCount() { return static_cast<int>(1U << (4294967296ULL & 31)); }
int FoldedNegativeCount() { return 8 >> (static_cast<unsigned int>(-1) & 31); }
int FoldedNegativeLeft() { return static_cast<int>(static_cast<unsigned int>(-3) << 1); }
int FoldedSignBit() { return static_cast<int>(1U << 31); }
int FoldedLostBits() { return static_cast<int>((1U << 30) << 2); }
