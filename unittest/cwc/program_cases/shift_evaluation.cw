func Bump(value &mut i32) i32 {
  value = value + 1;
  value
}

func main() i32 {
  var value i32 := 1;
  var left := value << Bump(value);
  if left != 4 || value != 2 { return 1; }

  value = 1;
  var right := value >> Bump(value);
  if right != 0 || value != 2 { return 2; }

  value = 1;
  var both := Bump(value) << Bump(value);
  if both != 16 || value != 3 { return 3; }

  value = 1;
  var zero := 0 << Bump(value);
  if zero != 0 || value != 2 { return 4; }

  value = 1;
  var unchanged := Bump(value) >> (Bump(value) * 32);
  if unchanged != 2 || value != 3 { return 5; }
  0
}
