func ForwardMutable(value &mut i32) &mut i32 {
  value
}

func ForwardCopy(value &copy i32) &copy i32 {
  value
}

func ForwardMove(value &move i32) &move i32 {
  move value
}

func ReplaceThenRead(first &mut i32, second &copy i32) i32 {
  first = 41;
  second
}

func AliasedArguments() i32 {
  var value i32 := 1;
  ReplaceThenRead(value, value)
}
