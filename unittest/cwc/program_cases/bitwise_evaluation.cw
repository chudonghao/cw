func Bump(value &mut i32) i32 {
  value = value + 1;
  value
}

func main() i32 {
  var value i32 := 1;
  var both := value & Bump(value);
  if both != 0 || value != 2 { return 1; }

  value = 1;
  var either := value | Bump(value);
  if either != 3 || value != 2 { return 2; }

  value = 1;
  var different := value ^ Bump(value);
  if different != 3 || value != 2 { return 3; }

  value = 1;
  var inverted := ~Bump(value);
  if inverted != -3 || value != 2 { return 4; }

  value = 1;
  var calls := Bump(value) & Bump(value);
  if calls != 2 || value != 3 { return 5; }

  value = 1;
  var zero := 0 & Bump(value);
  if zero != 0 || value != 2 { return 6; }

  value = 1;
  var ones := -1 | Bump(value);
  if ones != -1 || value != 2 { return 7; }
  0
}
