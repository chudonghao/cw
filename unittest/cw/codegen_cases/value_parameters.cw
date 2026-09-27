func Replace(value i32) i32 {
  value = 29;
  value
}

func ValueParameters() i32 {
  var value i32 := 17;
  Replace(value);
  value
}
