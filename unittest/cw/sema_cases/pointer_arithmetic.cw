func PointerArithmetic(pointer *i32, readonly *const i32, count usize, offset isize) {
  pointer + count;
  offset + readonly;
  pointer - readonly;
  pointer += count;
  ++pointer;
  pointer--;
}
