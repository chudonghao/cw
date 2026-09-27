struct Value {
  int number;
};

// The local expresses CW's named result; this trivial value has no cross-call address guarantee.
Value Make(int value) {
  Value result;
  result.number = value;
  return result;
}
Value Choose(bool flag, int left, int right) { return flag ? Make(left) : Make(right); }
int Read(const Value& value) { return value.number; }
int Bind(int value) { return Read(Make(value)); }
int Member(int value) { return Make(value).number; }
void Discard(bool flag, int value) { flag ? Make(value) : Make(0); }
Value& Target(Value& target, int& source) {
  source = 99;
  return target;
}
void Assign(Value& target, int& source) {
  // Preserve CW's complete right-hand result before evaluating the assignment target.
  Value result = Make(source);
  Target(target, source) = result;
}
int Take(Value value) { return value.number; }
int Receiver(const Value& value) { return Take(value); }
int Pass(int value) { return Take(Make(value)); }
Value Local(int value) {
  Value object = Make(value);
  return object;
}
