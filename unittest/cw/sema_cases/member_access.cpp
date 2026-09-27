struct Base {
  int inherited;
  short hidden;
};
struct Middle : Base {};
struct Value : Middle {
  unsigned int own;
  long long hidden;
};
Value Make() { return Make(); }
void MemberAccess(Value value, Value* pointer, const Value* const_pointer) {
  value.own;
  value.inherited;
  value.hidden;
  static_cast<Value&&>(value).own;
  Make().own;
  pointer->own;
  const_pointer->own;
  static_cast<Value&&>(value).inherited;
  Make().inherited;
  pointer->inherited;
  const_pointer->inherited;
}
void ReadOnly(const Value& value) {
  value.inherited;
  static_cast<const Value&&>(value).inherited;
}
