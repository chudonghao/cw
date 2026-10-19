func Byte(value i32) u8 { u8(value) }
func Signed(value u32) i32 { i32(value) }
func Size(value i32) usize { usize(value) }
func FloatSize(value f64) usize { usize(value) }
func FloatByte(value f64) u8 { u8(value) }
func FloatSigned(value f64) i8 { i8(value) }
func Round(value i64) f32 { f32(value) }
func Narrow(value f64) f32 { f32(value) }
func Same(value f64) f64 { f64(value) }
func Advance(value &mut i32) i32 { i32(value++) }
func Discard(value &mut i32) { f64(value++); }
func Select(value i32) i32 { 1 }
func Select(value i64) i32 { 2 }

var global := usize(3);
func main() i32 {
  if u8(300) != 44u8 || Byte(300) != 44u8 { return 1; }
  if i32(4294967295u32) != -1 || Signed(4294967295u32) != -1 { return 2; }
  if usize(-1) != ~0usize || Size(-1) != ~0usize { return 3; }
  if usize(-1.0) != 0usize || FloatSize(-1.0) != 0usize { return 4; }
  if u8(300.0) != 255u8 || FloatByte(300.0) != 255u8 { return 5; }
  if i8(-300.0) != -128i8 || FloatSigned(-300.0) != -128i8 { return 6; }
  if FloatSigned(3.9) != 3i8 || FloatSigned(-3.9) != -3i8 { return 7; }
  if f32(16777217i64) != 16777216.0f32 || Round(16777217i64) != 16777216.0f32 { return 8; }
  if f32(1.000000059604644775390625) != 1.0f32 { return 9; }
  if Narrow(1.000000059604644775390625) != 1.0f32 { return 10; }
  if Narrow(1.000000178813934326171875) != 1.0000002384185791015625f32 { return 11; }
  if f32(1e-300) != 0.0f32 || Narrow(1e-300) != 0.0f32 { return 12; }
  if !(f32(1e300) > 3e38f32) || !(Narrow(1e300) > 3e38f32) { return 13; }
  var infinity := 1.0 / 0.0;
  var nan := 0.0 / 0.0;
  if i8(infinity) != 127i8 || FloatSigned(infinity) != 127i8 { return 14; }
  if i8(-infinity) != -128i8 || FloatSigned(-infinity) != -128i8 { return 15; }
  if u8(infinity) != 255u8 || FloatByte(infinity) != 255u8 { return 16; }
  if u8(-infinity) != 0u8 || FloatByte(-infinity) != 0u8 { return 17; }
  if i8(nan) != 0i8 || FloatSigned(nan) != 0i8 || FloatByte(nan) != 0u8 { return 18; }
  if FloatSize(infinity) != ~0usize || FloatSize(nan) != 0usize { return 19; }
  if !(1.0f32 / f32() > 0.0f32) || !(1.0 / f64() > 0.0) { return 20; }
  if !(1.0 / Same(-0.0) < 0.0) { return 21; }
  if i32() != 0 || usize() != 0usize { return 22; }
  var x := 4;
  if Advance(x) != 4 || x != 5 { return 23; }
  Discard(x);
  if x != 6 { return 24; }
  var saved := i32(x);
  x = 9;
  if saved != 6 { return 25; }
  if Select(i32(1i64)) != 1 || Select(i64(Select(1))) != 2 { return 26; }
  if f64(0.1f32) == f64(0.1) { return 27; }
  if i8(-((128i16))) != -128i8 { return 28; }
  var array := [usize(3)] i32 {1, 2, 3};
  if array[usize(1)] != 2 || global != 3usize { return 29; }
  var flag := true;
  i32(flag ? x++ : ++x);
  if x != 10 { return 30; }
  var z := 0;
  i32(z = 7);
  if z != 7 { return 31; }
  if f32(1e-45) == 0.0f32 || Narrow(1e-45) == 0.0f32 { return 32; }
  if !(f32(nan) != f32(nan)) { return 33; }
  if !(1.0f32 / Narrow(-1e-300) < 0.0f32) { return 34; }
  return 0;
}
