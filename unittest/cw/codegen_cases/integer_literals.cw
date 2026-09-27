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
