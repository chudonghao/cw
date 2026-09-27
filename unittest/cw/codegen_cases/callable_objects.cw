trivial struct Callable { value i32; }
trivial struct Derived : Callable { extra i32; }

func operator()(object &mut Callable, value i32) i32 {
  object.value = value;
  object.value
}
func operator()(object &copy Callable, value i32) i32 { object.value + value }

func Invoke(object &mut Derived, value i32) i32 {
  operator ()(object, value);
  object(value)
}
func Read(object &copy Derived, value i32) i32 { object(value) }
func Pointer(object *Callable, value i32) i32 { (*object)(value) }
func Temporary(value i32) i32 { Callable()(value) }
