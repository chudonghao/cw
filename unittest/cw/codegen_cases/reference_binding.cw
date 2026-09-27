func Forward(value &mut i32) &mut i32 {
  value
}

func ReferenceBinding() i32 {
  var value i32 := 3;
  var link &mut i32;
  link := Forward(value);
  link = 19;
  value
}
