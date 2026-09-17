struct Base {
  int inherited;
  short hidden;
};
struct Value : Base {
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
}
