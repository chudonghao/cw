trivial struct Byte {
  value u8;
}
trivial struct Odd {
  bytes [3] u8;
}

func Small(value Byte) Byte { value }
func Three(value Odd) Odd { value }
