func AddByte(value i8, right i32) i8 { value += right }
func MixedDivide(value i8, right u8) i8 { value /= right }
func SignedDivide(value i32, right i32) i32 { value /= right }
func SignedRemainder(value i64, right i64) i64 { value %= right }
func Left(value i32, count i64) i32 { value <<= count }
func Right(value i32, count i64) i32 { value >>= count }
func ByteLeft(value u8, count i64) u8 { value <<= count }
func ByteRight(value i8, count u64) i8 { value >>= count }
func WideLeft(value u64, count i8) u64 { value <<= count }
func WideRight(value i64, count u8) i64 { value >>= count }
func FloatAdd(value i32, right f64) i32 { value += right }
func FloatMultiply(value u64, right f32) u64 { value *= right }
trivial struct Sizes { signed_value isize; unsigned_value usize; }

func main() i32 {
  var value i32 := 12;
  value += 5;
  if value != 17 { return 1; }
  value -= 2;
  if value != 15 { return 2; }
  value *= 3;
  if value != 45 { return 3; }
  value /= 4;
  if value != 11 { return 4; }
  value %= 7;
  if value != 4 { return 5; }
  value |= 8;
  if value != 12 { return 6; }
  value &= 10;
  if value != 8 { return 7; }
  value ^= 3;
  if value != 11 { return 8; }
  value <<= 33;
  if value != 22 { return 9; }
  value >>= -31;
  if value != 11 { return 10; }

  if AddByte(127, 1) != -128 || AddByte(1, 2147483647) != 0 { return 11; }
  if MixedDivide(-1, 2) != 127 { return 12; }
  if SignedDivide(-2147483648, -1) != -2147483648 { return 13; }
  if SignedRemainder(-9223372036854775808, -1) != 0 { return 14; }
  var byte i8 := 127;
  var one i8 := 1;
  byte += one;
  if byte != -128 { return 15; }
  byte *= one;
  byte /= -one;
  if byte != -128 { return 16; }
  var word u16 := 65535;
  var two u16 := 2;
  word *= two;
  if word != 65534 { return 17; }
  var wide u64 := 18446744073709551615;
  wide += 1;
  if wide != 0 { return 18; }
  wide -= 1;
  wide /= 3;
  if wide != 6148914691236517205 { return 19; }

  if Left(1, -1) != -2147483648 || Left(-2147483648, 1) != 0 { return 20; }
  if Left(3, 32) != 3 || Left(3, -32) != 3 { return 21; }
  if Left(3, 4294967296) != 3 || Left(3, -9223372036854775808) != 3 { return 22; }
  if Right(-3, 1) != -2 || Right(-3, -1) != -1 { return 23; }
  if ByteLeft(1, -1) != 128 || ByteLeft(1, 8) != 1 || ByteLeft(1, 9) != 2 { return 24; }
  if ByteRight(-3, 18446744073709551615) != -1 { return 25; }
  if WideLeft(1, -1) != 9223372036854775808 || WideLeft(1, 64) != 1 { return 26; }
  if WideRight(-3, 65) != -2 { return 27; }

  var single f32 := 8.0;
  single += 0.5; single -= 1.5; single *= 2.0; single /= 4.0;
  if single != 3.5 { return 28; }
  var double f64 := 2.0;
  var integer i64 := 3;
  double *= integer;
  if double != 6.0 { return 29; }
  if FloatAdd(1, 2.9) != 3 || FloatAdd(-1, -2.9) != -3 { return 30; }
  if FloatAdd(1, 1.0 / 0.0) != 2147483647 { return 31; }
  if FloatAdd(1, -1.0 / 0.0) != -2147483648 { return 32; }
  if FloatAdd(1, 0.0 / 0.0) != 0 { return 33; }
  if FloatMultiply(2, -1.0) != 0 || FloatMultiply(2, 0.0 / 0.0) != 0 { return 34; }
  if FloatMultiply(2, 1.0 / 0.0) != 18446744073709551615 { return 35; }

  var sizes := Sizes();
  var size_one := ~sizes.unsigned_value >> 63;
  var size_negative_one := ~sizes.signed_value;
  sizes.unsigned_value += size_one;
  sizes.unsigned_value <<= 63;
  sizes.unsigned_value >>= 63;
  if sizes.unsigned_value != size_one { return 36; }
  sizes.signed_value |= ~sizes.signed_value;
  sizes.signed_value <<= 1;
  sizes.signed_value >>= 1;
  if sizes.signed_value != size_negative_one { return 37; }
  0
}
