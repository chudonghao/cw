struct Value {
  int number;
};

int CopyAndMove(const Value& source) {
  Value copied = source;
  Value moved = static_cast<Value&&>(copied);
  moved = source;
  moved = moved;
  return moved.number;
}

Value& Assign(Value& target, Value& middle, const Value& source) { return target = middle = source; }
