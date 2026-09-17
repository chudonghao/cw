trivial struct Callable {}

func operator()(object mut Callable, value i32) i32 {
  value
}

func operator()(object copy Callable, value i32) i32 {
  value
}

func operator()(object mut Callable, value i64) i64 {
  value
}

func CallableObject(object mut Callable, fixed copy Callable, narrow i32, wide i64) i64 {
  object(narrow);
  fixed(narrow);
  operator ()(object, narrow);

  var operation *func (mut Callable, i32) i32 := &operator ();
  operation(object, narrow);

  object(wide)
}

func InvokePointer(pointer *Callable, narrow i32) i32 {
  (*pointer)(narrow)
}
