func SignExtend(value i8) i64 {
  value
}

func ZeroExtend(value u8) i64 {
  value
}

func SignExtendToUnsigned(value i16) u64 {
  value
}

func UnsignedToSignedWide(value u32) i64 {
  value
}

func NarrowUnsigned(value i64) u8 {
  value
}

func NarrowSigned(value u64) i16 {
  value
}

func SameWidth(value i32) u32 {
  value
}

func SizeToUnsigned(value isize) usize {
  value
}

func SizeToSigned(value usize) isize {
  value
}

func UnsignedAsSignedByte(value u8) i32 {
  var byte i8 := value;
  byte
}

func SignedAsUnsignedByte(value i8) i32 {
  var byte u8 := value;
  byte
}
