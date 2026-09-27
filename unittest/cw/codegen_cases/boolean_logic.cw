func Touch(flag &mut bool) bool {
  flag = !flag;
  flag
}

func BooleanLogic(a bool, b bool, c bool, flag &mut bool) bool {
  (a && b) && (c || Touch(flag))
}
