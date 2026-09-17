func Select(value mut i32) mut i32 {
  value
}

func Select(value copy i32) copy i32 {
  value
}

func Select(value move i32) move i32 {
  move value
}

func ReferenceBinding(value i32) {
  var link mut i32 := value;
  var fixed const i32 := value;

  Select(link);
  var owned := Select(fixed);
  Select(move value);
  Select(1);
}
