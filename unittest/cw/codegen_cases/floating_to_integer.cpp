#include <cmath>
#include <limits>

// Handle CW's NaN and saturation rules before any C++ floating-integral cast.
// Powers of two keep the exclusive upper bound exact, including for i64/u64.
template <class Integer, class Float>
Integer Saturate(Float value) {
  if (std::isnan(value)) {
    return 0;
  }
  const Float upper = std::ldexp(Float(1), std::numeric_limits<Integer>::digits);
  const Float lower = std::numeric_limits<Integer>::is_signed ? -upper : Float(0);
  if (value <= lower) {
    return std::numeric_limits<Integer>::lowest();
  }
  if (value >= upper) {
    return std::numeric_limits<Integer>::max();
  }
  return static_cast<Integer>(value);
}

signed char Signed8(double value) { return Saturate<signed char>(value); }

unsigned char Unsigned8(double value) { return Saturate<unsigned char>(value); }

short Signed16(double value) { return Saturate<short>(value); }

unsigned short Unsigned16(double value) { return Saturate<unsigned short>(value); }

int Signed32(double value) { return Saturate<int>(value); }

unsigned int Unsigned32(double value) { return Saturate<unsigned int>(value); }

long Signed64(double value) { return Saturate<long>(value); }

unsigned long Unsigned64(double value) { return Saturate<unsigned long>(value); }

int SignedSingle(float value) { return Saturate<int>(value); }

unsigned long UnsignedSingle(float value) { return Saturate<unsigned long>(value); }

int Fraction() { return Saturate<int>(-3.9); }

unsigned char ClampByte() { return Saturate<unsigned char>(300.0); }

signed char ClampSignedByte() { return Saturate<signed char>(128.0); }

unsigned char ClampNegative() { return Saturate<unsigned char>(-0.5); }

int NaNToZero() { return Saturate<int>(0.0 / 0.0); }

long PositiveInfinity() { return Saturate<long>(1.0 / 0.0); }

long NegativeInfinity() { return Saturate<long>(-1.0 / 0.0); }

unsigned long UnsignedInfinity() { return Saturate<unsigned long>(1.0 / 0.0); }

unsigned long UnsignedNegativeInfinity() { return Saturate<unsigned long>(-1.0 / 0.0); }

long SignedUpperBoundary() { return Saturate<long>(9223372036854775808.0); }

unsigned long UnsignedUpperBoundary() { return Saturate<unsigned long>(18446744073709551616.0); }

int NegativeZero() { return Saturate<int>(-0.0); }

unsigned char ViaInteger() {
  int value = Saturate<int>(300.0);
  return static_cast<unsigned char>(value);
}
