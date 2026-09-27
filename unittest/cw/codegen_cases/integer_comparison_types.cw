func UnsignedEqual(left u64, right u64) bool {
  left == right
}

func UnsignedNotEqual(left u64, right u64) bool {
  left != right
}

func UnsignedLess(left u64, right u64) bool {
  left < right
}

func UnsignedLessEqual(left u64, right u64) bool {
  left <= right
}

func UnsignedGreater(left u64, right u64) bool {
  left > right
}

func UnsignedGreaterEqual(left u64, right u64) bool {
  left >= right
}

func MixedUnsignedLess(left i8, right u16) bool {
  left < right
}

func MixedSignedLess(left i16, right u8) bool {
  left < right
}

func SameWidthLess(left i32, right u32) bool {
  left < right
}
