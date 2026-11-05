trivial struct Pair {
  first i64;
  second i32;
}

func Forward(pointer *i32, count usize) *i32 { pointer + count }
func Signed(count isize, pointer *const i32) *const i32 { count + pointer }
func Backward(pointer *Pair, count usize) *Pair { pointer - count }
func Rows(pointer *[3] i16, count isize) *[3] i16 { pointer - count }
func Nested(pointer **i32, count usize) **i32 { pointer + count }
func Callbacks(pointer **func () i32, count usize) **func () i32 { pointer + count }
func Interfaces(pointer *virtual *func (&copy Pair) i32, count isize) *virtual *func (&copy Pair) i32 {
  pointer + count
}
func Advance(pointer &mut *i32, count usize) { pointer += count; }
func Retreat(pointer &mut *Pair, count isize) *Pair { pointer -= count }
func Increment(pointer &mut *i32) *i32 { ++pointer }
func Decrement(pointer &mut *const u8) *const u8 { pointer-- }
