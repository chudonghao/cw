trivial struct CallbackHolder {
  callback *func (i16) i32;
  factory *func () *func (i16) i32;
}

func FunctionPointerCall(holder CallbackHolder, callback *func (i16) i32, value i8) i32 {
  callback(value);
  (holder.factory)()(value);
  (holder.callback)(value)
}
