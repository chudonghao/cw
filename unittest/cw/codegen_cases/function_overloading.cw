func Select(value &copy i32) i32 {
  7
}

func Select(value &mut i32) i32 {
  13
}

func Select(value &move i32) i32 {
  19
}

func FunctionOverloading() i32 {
  var value i32 := 0;
  var fixed const i32 := 0;
  Select(value);
  Select(fixed);
  Select(move value)
}
