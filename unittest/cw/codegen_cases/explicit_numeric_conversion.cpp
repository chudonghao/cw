#include <cmath>
#include <limits>

// isize/usize use this target's long/unsigned long.
int ZeroInteger() { return int(); }
float ZeroFloat() { return float(); }
unsigned long ToSize(int value) { return static_cast<unsigned long>(value); }
// Clang's signed narrowing uses the low-bit interpretation specified by CW.
short FromSize(unsigned long value) { return short(value); }
int Same(int value) { return int(value); }
float FloatSize(unsigned long value) { return float(value); }

// C++ requires explicit guards to express CW's saturation and NaN-to-zero behavior.
long SizeFloat(double value) {
  if (std::isnan(value)) return 0;
  const double upper = std::ldexp(1.0, std::numeric_limits<long>::digits);
  if (value <= -upper) return std::numeric_limits<long>::lowest();
  if (value >= upper) return std::numeric_limits<long>::max();
  return static_cast<long>(value);
}
float NarrowFloat(double value) { return float(value); }
double WidenFloat(float value) { return double(value); }
int Advance(int& value) { return int(value++); }
void Discard(int& value) { double(value++); }
