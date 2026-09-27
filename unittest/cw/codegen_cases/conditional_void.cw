func Write(target &mut i32, value i32) {
  target = value;
}

func ConditionalVoid(flag bool, other bool) i32 {
  var value i32 := 0;
  flag ? Write(value, 1) : (other ? Write(value, 2) : Write(value, 3));
  value
}
