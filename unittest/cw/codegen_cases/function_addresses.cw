func Select(value i32) i32 {
  value
}

func Select(value f64) f64 {
  value
}

func Get() *func (f64) f64 {
  &Select
}

func Invoke(value f64) f64 {
  var callback *func (f64) f64 := &Select;
  callback(value)
}

func Apply(callback *func (f64) f64, value f64) f64 {
  callback(value)
}

func Pass() f64 {
  Apply(&Select, 2.5)
}

func Forward() *func (i32) i32 {
  &Later
}

func Later(value i32) i32 {
  value
}
