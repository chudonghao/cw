func Overloaded(value i32) i32 {
  value
}

func Overloaded(value i64) i64 {
  value
}

func Select(callback *func (i32) i32) *func (i32) i32 {
  callback
}

func FunctionAddress() *func (i32) i32 {
  var callback *func (i32) i32 := &Overloaded;

  Select(&Overloaded)
}
