func Signed(callback *func (i8) i8, value i8) i8 {
  callback(value)
}

func Unsigned(callback *func (u16) u16, value u16) u16 {
  callback(value)
}

func Boolean(callback *func (bool) bool, value bool) bool {
  callback(value)
}

func Floating(callback *func (f32) f64, value i32) f64 {
  callback(value)
}

func Reference(callback *func (&mut i32) &mut i32, value &mut i32) &mut i32 {
  callback(value)
}

func ReadReference(callback *func (&copy i32) &copy i32, value &copy i32) i32 {
  callback(value)
}

func MoveReference(callback *func (&move i32) &move i32, value &move i32) &move i32 {
  callback(move value)
}

func Void(callback *func (*i32) void, pointer *i32) {
  callback(pointer);
}

func Chained(factory *func () *func (i32) i32, value i32) i32 {
  factory()(value)
}
