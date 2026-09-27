func Address(value &mut i32) *i32 {
  &value
}

func Read(pointer *const i32) i32 {
  *pointer
}

func Write(pointer *i32, value i32) {
  *pointer = value;
}

func Toggle(pointer *bool) bool {
  *pointer = !*pointer;
  *pointer
}

func Double(pointer *f64, value f64) f64 {
  *pointer = value;
  *pointer
}

func Nested(pointer **i32, other *i32) *i32 {
  *pointer = other;
  *pointer
}

func Local() i32 {
  var value i32 := 7;
  var pointer *i32 := &value;
  *pointer = 11;
  Read(pointer)
}

func Receiver(pointer *i32) *i32 {
  pointer->Address()
}
