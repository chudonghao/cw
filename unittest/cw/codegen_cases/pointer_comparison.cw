func Equal(left *i32, right *const i32) bool {
  left == right
}

func NotEqual(left *const i32, right *i32) bool {
  left != right
}

func IsNull(pointer *i32) bool {
  pointer == null
}

func NotNull(pointer *i32) bool {
  null != pointer
}

func CallbackIsNull(callback *func (i32) i32) bool {
  callback == null
}

func EmptyCallback() *func (i32) i32 {
  null
}

func NullEqual() bool {
  null == null
}

func NullUnequal() bool {
  (null) != (null)
}

func DiscardNull() {
  (null);
}
