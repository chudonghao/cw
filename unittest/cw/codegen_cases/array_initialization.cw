func Integers(value i32, index usize) i32 {
  var values [2] i32 := [2] i32 { value, 7 };
  values[index]
}

func Nested(value i16, outer usize, inner usize) i16 {
  var values [2] [1] i16 := {
    values := [2] [1] i16 { { value }, { 5 } };
  }
  values[outer][inner]
}

func Booleans(value bool, index usize) bool {
  var values [2] bool := [2] bool { value, false };
  values[index]
}

func Floating(value f64, index usize) f64 {
  var values [2] f64 := [2] f64 { value, 2.5 };
  values[index]
}

func Pointers(value *i32, index usize) *i32 {
  var values [2] *i32 := [2] *i32 { value, null };
  values[index]
}
