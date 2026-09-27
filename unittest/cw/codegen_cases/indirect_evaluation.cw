func First(value i32) i32 {
  value
}

func Other(value i32) i32 {
  -value
}

func Replace(callback &mut *func (i32) i32) i32 {
  callback = &Other;
  5
}

func Invoke(callback &mut *func (i32) i32) i32 {
  callback(Replace(callback))
}

func Run() i32 {
  var callback *func (i32) i32 := &First;
  Invoke(callback)
}

func Mutate(value &mut i32) i32 {
  value = value + 1;
  value
}

func Arguments(callback *func (i32, i32) i32, value &mut i32) i32 {
  callback(value, Mutate(value))
}
