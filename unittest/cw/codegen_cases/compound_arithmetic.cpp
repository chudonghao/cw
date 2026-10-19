#include <cmath>
#include <limits>

// Explicit conversions preserve CW's computation widths and wraparound. Native
// Clang's signed narrowing and right shifts match CW on this reference target.
signed char ByteArithmetic(signed char& left, signed char right) {
  left = static_cast<signed char>(left + right);
  left = static_cast<signed char>(left - right);
  left = static_cast<signed char>(left * right);
  left = static_cast<signed char>(left / right);
  left = static_cast<signed char>(left % right);
  left &= right;
  left |= right;
  left ^= right;
  return left;
}
signed char MixedAdd(signed char& left, int right) {
  return left = static_cast<signed char>(static_cast<unsigned int>(left) + static_cast<unsigned int>(right));
}
short MixedMultiply(short& left, unsigned int right) {
  return left = static_cast<short>(static_cast<unsigned int>(left) * right);
}
int SignedDivide(int& left, int right) {
  return left = right == -1 ? static_cast<int>(0U - static_cast<unsigned int>(left)) : left / right;
}
long long SignedRemainder(long long& left, long long right) { return left = right == -1 ? 0 : left % right; }
unsigned long long UnsignedDivide(unsigned long long& left, unsigned long long right) { return left /= right; }
unsigned short UnsignedRemainder(unsigned short& left, unsigned short right) { return left %= right; }
float FloatArithmetic(float& left, float right) {
  left += right;
  left -= right;
  left *= right;
  left /= right;
  return left;
}
float FloatWriteback(float& left, double right) { return left = static_cast<float>(static_cast<double>(left) + right); }
double IntegerToFloat(double& left, long long right) { return left *= static_cast<double>(right); }

template <class Integer, class Float>
Integer Saturate(Float value) {
  if (std::isnan(value)) return 0;
  const Float upper = std::ldexp(Float(1), std::numeric_limits<Integer>::digits);
  const Float lower = std::numeric_limits<Integer>::is_signed ? -upper : Float(0);
  if (value <= lower) return std::numeric_limits<Integer>::lowest();
  if (value >= upper) return std::numeric_limits<Integer>::max();
  return static_cast<Integer>(value);
}
int FloatToInteger(int& left, double right) { return left = Saturate<int>(static_cast<double>(left) + right); }
unsigned long long UnsignedFloatToInteger(unsigned long long& left, float right) {
  return left = Saturate<unsigned long long>(static_cast<float>(left) * right);
}
signed char ByteShift(signed char& left, unsigned long long right) {
  return left = static_cast<signed char>(static_cast<unsigned int>(left) << (right & 7));
}
unsigned char ByteRight(unsigned char& left, long long right) {
  return left = static_cast<unsigned char>(left >> (static_cast<unsigned long long>(right) & 7));
}
int SignedRight(int& left, signed char right) { return left >>= static_cast<unsigned int>(right) & 31; }
unsigned short WordShift(unsigned short& left, signed char right) {
  return left = static_cast<unsigned short>(static_cast<unsigned int>(left) << (static_cast<unsigned int>(right) & 15));
}
long long WideShift(long long& left, unsigned char right) {
  return left = static_cast<long long>(static_cast<unsigned long long>(left) << (right & 63));
}
unsigned long SizeShift(unsigned long& left, int right) { return left <<= static_cast<unsigned int>(right) & 63; }
long SignedSizeRight(long& left, unsigned long long right) { return left >>= right & 63; }
unsigned char FixedBySize(unsigned char& left, unsigned long right) {
  return left = static_cast<unsigned char>(static_cast<unsigned int>(left) << (right & 7));
}
