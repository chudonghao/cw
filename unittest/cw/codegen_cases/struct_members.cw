trivial struct Pair {
  first i32;
  second i32;
}

trivial struct Callback {
  invoke *func (i32) i32;
}

func Member(value &mut Pair, input i32) &mut i32 {
  value.second = input;
  value.second
}

func Pointer(value *Pair, input i32) *i32 {
  value->first = input;
  &value->first
}

func Call(value &copy Callback, input i32) i32 {
  (value.invoke)(input)
}

func Temporary() i32 { Pair().first }
