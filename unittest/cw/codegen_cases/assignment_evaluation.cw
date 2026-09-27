func MutatingTarget(value &mut i32) &mut i32 {
  value = 73;
  value
}

func AssignmentOrder() i32 {
  var value i32 := 11;
  MutatingTarget(value) = value;
  value
}

func Target(value &mut i32) &mut i32 {
  value
}

func AssignOnce(value &mut i32) &mut i32 {
  Target(value) = 17
}

func Change(flag &mut bool) i32 {
  flag = !flag;
  17
}

func ConditionalAssignment(flag bool) i32 {
  var left i32 := 1;
  var right i32 := 2;
  (flag ? left : right) = Change(flag);
  flag ? left : right
}
