func Select(value i8) i32 { 1 }
func Select(value i16) i32 { 2 }
func Select(value i32) i32 { 3 }
func Select(value i64) i32 { 4 }
func Select(value isize) i32 { 5 }
func Select(value u8) i32 { 6 }
func Select(value u16) i32 { 7 }
func Select(value u32) i32 { 8 }
func Select(value u64) i32 { 9 }
func Select(value usize) i32 { 10 }
func Select(value f32) i32 { 11 }
func Select(value f64) i32 { 12 }

var index usize := 0usize;
func Next(value usize) usize { value + 1usize }
func Minimum() i8 { -(((128i8))) }
func NegativeZero() f32 { -0.0f32 }

func main() i32 {
  if Select(1i8) != 1 { return 1; }
  if Select(1i16) != 2 { return 2; }
  if Select(1i32) != 3 { return 3; }
  if Select(1i64) != 4 { return 4; }
  if Select(1isize) != 5 { return 5; }
  if Select(1u8) != 6 { return 6; }
  if Select(1u16) != 7 { return 7; }
  if Select(1u32) != 8 { return 8; }
  if Select(1u64) != 9 { return 9; }
  if Select(1usize) != 10 { return 10; }
  if Select(1.0f32) != 11 { return 11; }
  if Select(1.0f64) != 12 { return 12; }
  if Select(1) != 3 || Select(1.0) != 12 { return 13; }
  if Select(-128i8) != 1 || Select(-(128i8)) != 1 { return 14; }

  var values := [2usize] i32 { 10, 20 };
  var next := Next(index);
  if values[index] != 10 || values[next] != 20 { return 15; }
  if values[0usize] != 10 || next != 1usize { return 16; }
  if Minimum() != -128 || -(-128i8) != -128 { return 17; }
  if (127i8 + 1i8) != -128 || (255u8 + 1u8) != 0 { return 18; }
  if -0b10000000i8 != -128 || -0o200i8 != -128 || -0x80i8 != -128 { return 19; }
  if 0x1f32 != 7986 || 0x1f32u16 != 7986 { return 20; }
  if -9223372036854775808i64 != -9223372036854775808 { return 21; }
  if 18446744073709551615u64 != 18446744073709551615 { return 22; }
  if ~0isize != -1isize || 18446744073709551615usize != ~0usize { return 23; }
  if .5f32 != 0.5 || 1.f64 != 1.0 || 1.e3f32 != 1000.0 { return 24; }
  if 1.000000059604644775390626f32 <= 1.0f32 { return 25; }
  if !(1.0f32 / NegativeZero() < 0.0f32) { return 26; }
  if 1e-46f32 != 0.0f32 || 1e-400f64 != 0.0f64 { return 27; }
  if Select(((1i8))) != 1 || Select(+((1u8))) != 6 { return 28; }
  if ~((0u8)) != 255u8 || (((1u8)) << ((8usize))) != 1u8 { return 29; }
  if values[((0usize))] != 10 || Select(true ? ((1i8)) : ((2i8))) != 1 { return 30; }
  0
}
