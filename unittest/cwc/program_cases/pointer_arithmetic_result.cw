trivial struct Pair { first i64; second i32; }
trivial struct Bytes { head [2] u8; middle u8; tail [2] u8; }

func main() i32 {
  var values [4] i32 := [4] i32 { 10, 20, 30, 40 };
  var first *i32 := &values[0usize];
  var last *i32 := &values[3usize];
  if *(first + 2usize) != 30 || *(3isize + first) != 40 { return 1; }
  if *(last - 1usize) != 30 || *(-2isize + last) != 20 || *(last - -1isize - 2usize) != 30 { return 2; }
  if last - first != 3isize || first - last != -3isize { return 3; }

  var none *i32 := null;
  var readonly_none *const i32 := null;
  if first - first != 0isize || none - readonly_none != 0isize || none + 0usize != none { return 4; }

  var before := first - 5usize;
  var after := last + 100isize;
  if *(before + 5usize) != 10 || *(after - 100isize) != 40 { return 5; }

  var zero usize := 0usize;
  var max := ~zero;
  if (first + 1usize) + max != first || *(last + max) != 30 { return 6; }
  if (first + max) + 1usize != first { return 7; }

  var cursor := first;
  cursor += 2usize;
  if *cursor != 30 { return 8; }
  cursor -= 1isize;
  if *cursor != 20 { return 9; }
  if *cursor++ != 20 || *cursor != 30 { return 10; }
  if *--cursor != 20 || *++cursor != 30 { return 11; }
  if *cursor-- != 30 || cursor - first != 1isize { return 12; }

  var pairs [2] Pair := [2] Pair { Pair(), Pair() };
  var pair_first *Pair := &pairs[0usize];
  var pair_last *Pair := &pairs[1usize];
  if pair_last - pair_first != 1isize || pair_first + 1usize != pair_last { return 13; }

  var bytes := Bytes();
  var head *[2] u8 := &bytes.head;
  var tail *[2] u8 := &bytes.tail;
  if tail - head != 1isize || head - tail != -1isize { return 14; }
  0
}
