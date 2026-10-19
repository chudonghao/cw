func Left32(value i32, count i64) i32 { value << count }
func Right32(value i32, count i64) i32 { value >> count }
func UnsignedRight(value u32, count u64) u32 { value >> count }
func ByteLeft(value u8, count i64) u8 { value << count }
func ByteRight(value i8, count i64) i8 { value >> count }
func WordLeft(value u16, count i8) u16 { value << count }
func WordRight(value i16, count u8) i16 { value >> count }
func Left64(value i64, count i8) i64 { value << count }
func Right64(value u64, count i8) u64 { value >> count }
func SizeLeft(value usize, count i32) usize { value << count }
func SizeRight(value isize, count u8) isize { value >> count }
func FixedBySize(value u8, count usize) u8 { value << count }
func LiteralLeft(count u64) i64 { 1 << count }

namespace Api {
trivial struct Bits { value i32; }
func operator<<(value &copy Bits, count i64) i64 { count }
func operator>>(value &mut Bits, count i32) &mut Bits { value }
func Check() bool {
  var value := Bits();
  (value >> -1).value = 7;
  (value << -1) == -1 && (value << 64) == 64 && value.value == 7
}
}

trivial struct Sizes { signed_value isize; unsigned_value usize; }

func main() i32 {
  if Left32(3, 0) != 3 { return 1; }
  if Left32(1, 31) != -2147483648 { return 2; }
  if Left32(3, 32) != 3 { return 3; }
  if Left32(3, 33) != 6 { return 4; }
  if Left32(1, -1) != -2147483648 { return 5; }
  if Left32(3, -32) != 3 { return 6; }
  if Left32(1, -33) != -2147483648 { return 7; }
  if Left32(3, 4294967296) != 3 { return 8; }
  if Left32(1, 9223372036854775807) != -2147483648 { return 9; }
  if Left32(3, -9223372036854775808) != 3 { return 10; }
  if Left32(-3, 1) != -6 || Left32(-2147483648, 1) != 0 { return 11; }
  if Right32(-3, 1) != -2 || Right32(-3, -1) != -1 { return 12; }
  if Right32(-3, -32) != -3 || Right32(8, 33) != 4 { return 13; }
  if UnsignedRight(2147483648, 1) != 1073741824 { return 14; }
  if UnsignedRight(2147483648, 18446744073709551615) != 1 { return 15; }
  if ByteLeft(128, 1) != 0 || ByteLeft(1, 7) != 128 { return 16; }
  if ByteLeft(1, 8) != 1 || ByteLeft(1, 9) != 2 { return 17; }
  if ByteLeft(1, -1) != 128 || ByteLeft(1, -8) != 1 { return 18; }
  if ByteLeft(1, 4294967296) != 1 { return 19; }
  if ByteRight(-3, 1) != -2 || ByteRight(-3, -1) != -1 { return 20; }
  if ByteRight(-3, 8) != -3 { return 21; }
  if WordLeft(1, 15) != 32768 || WordLeft(1, 16) != 1 { return 22; }
  if WordLeft(1, -1) != 32768 || WordLeft(1, -16) != 1 { return 23; }
  if WordRight(-3, 1) != -2 || WordRight(-3, 16) != -3 { return 24; }
  if Left64(1, 63) != -9223372036854775808 { return 25; }
  if Left64(1, 64) != 1 || Left64(1, 65) != 2 { return 26; }
  if Left64(1, -1) != -9223372036854775808 || Left64(1, -64) != 1 { return 27; }
  if Right64(9223372036854775808, -1) != 1 { return 28; }
  if Right64(9223372036854775808, 64) != 9223372036854775808 { return 29; }
  var sizes := Sizes();
  var size_one := ~sizes.unsigned_value >> 63;
  var size_high_bit := size_one << 63;
  var size_expected := ~sizes.signed_value << 1;
  var size_negative := size_expected + ~sizes.signed_value;
  var size_eight := size_one << 3;
  var size_seven := size_eight - size_one;
  if SizeLeft(size_one, 64) != size_one || SizeLeft(size_one, 63) != size_high_bit { return 30; }
  if SizeRight(size_negative, 1) != size_expected { return 31; }
  if FixedBySize(1, size_eight) != 1 || FixedBySize(1, size_seven) != 128 { return 32; }
  if LiteralLeft(32) != 1 { return 33; }
  if (1 << 4294967296) != 1 || (8 >> -1) != 0 { return 34; }
  if (1 << 31) != -2147483648 || ((1 << 30) << 2) != 0 { return 35; }
  if (-3 << 1) != -6 || (-3 >> 1) != -2 { return 36; }
  if ('a' << 2) != 132 { return 37; }
  var readonly const i32 := 1 << 32;
  if readonly != 1 { return 38; }

  if !Api::Check() { return 39; }
  var value := Api::Bits();
  ::Api::operator>>(value, -1).value = 9;
  if Api::operator<<(value, -1) != -1 || value.value != 9 { return 40; }
  var shl *func (&copy Api::Bits, i64) i64 := &Api::operator<<;
  var shr *func (&mut Api::Bits, i32) &mut Api::Bits := &::Api::operator>>;
  shr(value, 32).value = 11;
  if shl(value, 64) != 64 || value.value != 11 { return 41; }
  0
}
