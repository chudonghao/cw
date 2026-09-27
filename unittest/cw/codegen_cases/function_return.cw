func Set(value &mut i32) {
  value = 43;
  return;
  value = 61;
}

func Empty() void {}

func ExplicitReturn() i32 {
  var value i32 := 1;
  Set(value);
  Empty();
  return value;
}

func ReturningBranches(a bool, b bool, c bool) i32 {
  if a ? !b : (b || c) {
    return 1;
  } else {
    return 2;
  }
  return 3;
}

func TailResult(flag bool, other bool) i32 {
  if flag {
    return 1;
  }
  if other {
    2
  } else {
    3
  }
}

func SetUnless(flag bool, target &mut bool) {
  if flag {
    return;
  }
  target = true;
}
