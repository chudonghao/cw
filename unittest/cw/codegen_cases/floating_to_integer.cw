func Signed8(value f64) i8 {
  value
}

func Unsigned8(value f64) u8 {
  value
}

func Signed16(value f64) i16 {
  value
}

func Unsigned16(value f64) u16 {
  value
}

func Signed32(value f64) i32 {
  value
}

func Unsigned32(value f64) u32 {
  value
}

func Signed64(value f64) i64 {
  value
}

func Unsigned64(value f64) u64 {
  value
}

func SignedSingle(value f32) i32 {
  value
}

func UnsignedSingle(value f32) u64 {
  value
}

func Fraction() i32 {
  -3.9
}

func ClampByte() u8 {
  300.0
}

func ClampSignedByte() i8 {
  128.0
}

func ClampNegative() u8 {
  -0.5
}

func NaNToZero() i32 {
  0.0 / 0.0
}

func PositiveInfinity() i64 {
  1.0 / 0.0
}

func NegativeInfinity() i64 {
  -1.0 / 0.0
}

func UnsignedInfinity() u64 {
  1.0 / 0.0
}

func UnsignedNegativeInfinity() u64 {
  -1.0 / 0.0
}

func SignedUpperBoundary() i64 {
  9223372036854775808.0
}

func UnsignedUpperBoundary() u64 {
  18446744073709551616.0
}

func NegativeZero() i32 {
  -0.0
}

func ViaInteger() u8 {
  var value i32 := 300.0;
  value
}
