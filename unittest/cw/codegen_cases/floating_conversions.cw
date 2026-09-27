func Widen(value f32) f64 {
  value
}

func Narrow(value f64) f32 {
  value
}

func SignedSingle(value i64) f32 {
  value
}

func UnsignedSingle(value u64) f32 {
  value
}

func SignedDouble(value i32) f64 {
  value
}

func UnsignedDouble(value u32) f64 {
  value
}

func SignedByte(value i8) f32 {
  value
}

func UnsignedByte(value u8) f64 {
  value
}

func RoundedInteger() f32 {
  16777217
}

func NegativeInteger() f64 {
  -16777217
}

func NarrowOverflow() f32 {
  1e40
}

func NarrowUnderflow() f32 {
  -1e-300
}

func NarrowSubnormal() f32 {
  1.401298464324817e-45
}
