func Flip(value bool) bool {
  value = !value;
  value
}

func Refer(value &mut bool) &mut bool {
  value
}

func BooleanObjects() bool {
  var original bool := true;
  var copied const bool := Flip(original);
  var bound &mut bool := Refer(original);
  bound = false;
  copied
}
