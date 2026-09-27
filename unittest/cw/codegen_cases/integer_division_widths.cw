func ByteQuotient(dividend i8, divisor i8) i8 {
  dividend / divisor
}

func ByteRemainder(dividend i8, divisor i8) i8 {
  dividend % divisor
}

func WordQuotient(dividend i16, divisor i16) i16 {
  dividend / divisor
}

func WideRemainder(dividend i64, divisor i64) i64 {
  dividend % divisor
}

func SizeQuotient(dividend isize, divisor isize) isize {
  dividend / divisor
}

func UnsignedByteQuotient(dividend u8, divisor u8) u8 {
  dividend / divisor
}

func UnsignedWordRemainder(dividend u16, divisor u16) u16 {
  dividend % divisor
}

func Unsigned32Quotient(dividend u32, divisor u32) u32 {
  dividend / divisor
}

func UnsignedWideRemainder(dividend u64, divisor u64) u64 {
  dividend % divisor
}

func UnsignedSizeQuotient(dividend usize, divisor usize) usize {
  dividend / divisor
}

func UnsignedMaximumQuotient(value u64) u64 {
  value / 18446744073709551615
}

func UnsignedMaximumRemainder(value u64) u64 {
  value % 18446744073709551615
}

func MinimumQuotient() i64 {
  -9223372036854775808 / -1
}

func MinimumRemainder() i64 {
  -9223372036854775808 % -1
}
