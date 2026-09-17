trivial struct Base {
  inherited i32;
  hidden i16;
}

trivial struct Value : Base {
  own u32;
  hidden i64;
}

func Make() Value {
  Make()
}

func MemberAccess(value Value, pointer *Value, const_pointer *const Value) {
  value.own;
  value.inherited;
  value.hidden;
  (move value).own;
  Make().own;
  pointer->own;
  const_pointer->own;
}
