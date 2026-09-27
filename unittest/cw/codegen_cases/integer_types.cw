func Signed8(value i8) i8 {
  value
}

func Unsigned8(value u8) u8 {
  value
}

func Signed16(value i16) i16 {
  value
}

func Unsigned16(value u16) u16 {
  value
}

func Signed32(value i32) i32 {
  value
}

func Unsigned32(value u32) u32 {
  value
}

func Signed64(value i64) i64 {
  value
}

func Unsigned64(value u64) u64 {
  value
}

func SignedSize(value isize) isize {
  value
}

func UnsignedSize(value usize) usize {
  value
}

func ForwardSigned8(value i8) i8 {
  Signed8(value)
}

func ForwardUnsigned8(value u8) u8 {
  value.Unsigned8()
}

func ForwardSigned16(value i16) i16 {
  value.Signed16()
}

func ForwardUnsigned16(value u16) u16 {
  Unsigned16(value)
}

func ForwardNarrow(value i64) u8 {
  Unsigned8(value)
}
