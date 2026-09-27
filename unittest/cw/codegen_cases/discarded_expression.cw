func Touch(value &mut i32) &copy i32 {
  value = 47;
  value
}

func DiscardedExpression() i32 {
  var value i32 := 1;
  Touch(value);
  value
}
