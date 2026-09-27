func SignedByteArithmetic(left i8, right i8) i8 {
  (+left + -right) * (left - right)
}

func UnsignedWordArithmetic(left u16, right u16) u16 {
  (left + right) * (left - right)
}

func UnsignedWideArithmetic(left u64, right u64) u64 {
  (left + right) * (left - right)
}

func SignedWideNegate(value i64) i64 {
  -value
}

func MixedArithmetic(left i8, right u16) i32 {
  left + right
}

func SizeArithmetic(left isize, right usize) usize {
  left + right
}
