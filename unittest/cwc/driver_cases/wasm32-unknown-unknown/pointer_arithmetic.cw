trivial struct Pair { first i64; second i32; }
func Offset(pointer *Pair, count usize) *Pair { pointer - count }
func Step(pointer &mut *i32) *i32 { pointer++ }
func Distance(last *Pair, first *Pair) isize { last - first }
