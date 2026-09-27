func Sum(values &copy [2] i32, begin usize, end usize, step usize) i32 {
  var total := 0;
  var index := begin;
  while index < end {
    total = total + values[index];
    index = index + step;
  }
  total
}
