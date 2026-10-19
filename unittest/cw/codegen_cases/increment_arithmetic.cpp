// Explicit unsigned arithmetic expresses CW's wraparound on the reference target.
signed char SignedByte(signed char& value) {
  signed char old = value;
  value = static_cast<signed char>(static_cast<unsigned char>(value) + 1u);
  return old;
}
unsigned char UnsignedByte(unsigned char& value) { return --value; }
short SignedShort(short& value) {
  value = static_cast<short>(static_cast<unsigned short>(value) + 1u);
  return value;
}
unsigned short UnsignedShort(unsigned short& value) { return value--; }
int SignedInt(int& value) {
  int old = value;
  value = static_cast<int>(static_cast<unsigned int>(value) - 1u);
  return old;
}
unsigned int UnsignedInt(unsigned int& value) { return ++value; }
long long SignedLong(long long& value) {
  value = static_cast<long long>(static_cast<unsigned long long>(value) - 1ull);
  return value;
}
unsigned long long UnsignedLong(unsigned long long& value) { return value++; }
long SignedSize(long& value) {
  value = static_cast<long>(static_cast<unsigned long>(value) + 1ul);
  return value;
}
unsigned long UnsignedSize(unsigned long& value) { return value--; }
float Float32(float& value) { return value++; }
double Float64(double& value) { return --value; }
