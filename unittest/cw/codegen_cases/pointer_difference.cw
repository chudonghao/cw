trivial struct Pair {
  first i64;
  second i32;
}

func Elements(last *i32, first *i32) isize { last - first }
func Qualified(last *const i32, first *i32) isize { last - first }
func Bytes(last *u8, first *const u8) isize { last - first }
func Pairs(last *Pair, first *Pair) isize { last - first }
func Rows(last *[3] i16, first *[3] i16) isize { last - first }
func Nested(last **i32, first *const *const i32) isize { last - first }
