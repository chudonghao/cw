func Count(counter &mut usize) usize {
  counter += 1usize;
  counter
}
func Locate(pointer &mut *i32, calls &mut usize) &mut *i32 {
  calls += 1usize;
  pointer
}
func OffsetFirst(pointer &mut *i32, counter &mut usize) *i32 { Count(counter) + Locate(pointer, counter) }
func SourceFirst(pointer &mut *i32, counter &mut usize) *i32 { Locate(pointer, counter) += Count(counter) }
func Old(pointer &mut *i32) bool {
  var before *i32 := pointer++;
  before != pointer
}
func Discard(pointer &mut *i32, counter &mut usize) { Locate(pointer, counter)--; }
func Distance(pointer &mut *i32, counter &mut usize) isize { Locate(pointer, counter)++ - pointer }
