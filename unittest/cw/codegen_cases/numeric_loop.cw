func NumericLoop(limit i32) i32 {
  var sum i32 := 0;
  var index i32 := 0;
  while index < limit {
    if index % 2 == 0 {
      sum = sum + index;
    }
    index = index + 1;
  }
  sum
}
