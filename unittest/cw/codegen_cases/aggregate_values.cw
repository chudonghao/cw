// Struct values.
trivial struct Byte {
  value u8;
}
trivial struct Odd {
  bytes [3] u8;
}
trivial struct Pair {
  first i64;
  second i64;
}
trivial struct Pointers {
  first *i32;
  second *i32;
}
trivial struct Block {
  values [3] i64;
}

func Small(value Byte) Byte { value }
func Three(value Odd) Odd { value }
func TwoWords(value Pair) Pair { value }
func Addresses(value Pointers) Pointers { value }
func Structure(value Block) Block { value }
func CopyThree(value &copy Odd) Odd { Three(value) }

// Array values.
func Nine(value [9] u8) [9] u8 { value }
func Large(value [3] i64) [3] i64 { value }
func Boolean(value [2] bool) [2] bool { value }
func CopyNine(value &copy [9] u8) [9] u8 { Nine(value) }
