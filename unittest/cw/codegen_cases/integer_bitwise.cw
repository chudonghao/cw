func UnsignedByte(left u8, right u8) u8 {
  (~left & right) | (left ^ right)
}

func SignedByte(left i8, right i8) i8 {
  (~left & right) | (left ^ right)
}

func Word(left u16, right u16) u16 {
  (~left & right) | (left ^ right)
}

func SignedWord(left i32, right i32) i32 {
  (~left & right) | (left ^ right)
}

func Wide(left u64, right u64) u64 {
  (~left & right) | (left ^ right)
}

func Mixed(left i8, right u16) u16 { left & right }

func Size(left isize, right usize) usize { ~left & right }

func InvertBeforeWidening(value u8) i32 { ~value & 256 }

func FoldedSigned() i64 { ~0x80000000 }

func FoldedUnsigned() u64 { ~18446744073709551615 }
