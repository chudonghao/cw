func ByteArithmetic(left &mut i8, right i8) i8 {
  left += right; left -= right; left *= right;
  left /= right; left %= right;
  left &= right; left |= right; left ^= right;
  left
}
func MixedAdd(left &mut i8, right i32) i8 { left += right }
func MixedMultiply(left &mut i16, right u32) i16 { left *= right }
func SignedDivide(left &mut i32, right i32) i32 { left /= right }
func SignedRemainder(left &mut i64, right i64) i64 { left %= right }
func UnsignedDivide(left &mut u64, right u64) u64 { left /= right }
func UnsignedRemainder(left &mut u16, right u16) u16 { left %= right }
func FloatArithmetic(left &mut f32, right f32) f32 {
  left += right; left -= right; left *= right; left /= right;
  left
}
func FloatWriteback(left &mut f32, right f64) f32 { left += right }
func IntegerToFloat(left &mut f64, right i64) f64 { left *= right }
func FloatToInteger(left &mut i32, right f64) i32 { left += right }
func UnsignedFloatToInteger(left &mut u64, right f32) u64 { left *= right }
func ByteShift(left &mut i8, right u64) i8 { left <<= right }
func ByteRight(left &mut u8, right i64) u8 { left >>= right }
func SignedRight(left &mut i32, right i8) i32 { left >>= right }
func WordShift(left &mut u16, right i8) u16 { left <<= right }
func WideShift(left &mut i64, right u8) i64 { left <<= right }
func SizeShift(left &mut usize, right i32) usize { left <<= right }
func SignedSizeRight(left &mut isize, right u64) isize { left >>= right }
func FixedBySize(left &mut u8, right usize) u8 { left <<= right }
