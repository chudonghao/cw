func Readonly(value *i32) *const i32 {
  value
}

func DeepReadonly(value **i32) *const *const i32 {
  value
}

func ReadReference(value &copy *i32) *i32 {
  value
}

func ForwardReference(value &mut *i32) &mut *i32 {
  value
}

func Replace(target &mut *i32, source *i32) {
  target = source;
}

func Take(left &copy *i32, right &move *i32) bool {
  left == right
}

func Temporary() bool {
  Take(null, null)
}
