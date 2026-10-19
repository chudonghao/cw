func SignedLiteral() i64 {
  2147483648
}

func UnsignedLiteral() u64 {
  18446744073709551615
}

func MinimumLiteral() i64 {
  -9223372036854775808
}

func CharacterValue() u16 {
  '\xFF'
}

func CharacterArithmetic() u8 {
  '\xFF' + '\x01'
}

func TruncatedLiteral() u8 {
  257
}

func NegativeUnsignedLiteral() u64 {
  -1
}

func InferredLiteral() u64 {
  var value := 9223372036854775808;
  value
}

func ByteMinimum() i8 {
  -(((128i8)))
}

func TypedNegation() i8 {
  -(-128i8)
}

func HexadecimalSuffix() u16 {
  0x1f32u16
}

func ExplicitUnsigned() u64 {
  18446744073709551615u64
}

func WidenedByte() i64 {
  -128i8
}

func NextIndex(index usize) usize {
  index + 1usize
}

func MinimumSize() isize {
  -9223372036854775808isize
}
