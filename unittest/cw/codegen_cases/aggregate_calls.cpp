struct Value {
  long values[3];
};

Value Make(signed char value, int& counter) {
  counter = counter + 1;
  return {{value, 2, 3}};
}

Value Forward(signed char value, int& counter) { return Make(value, counter); }
Value Indirect(Value (*callback)(signed char, int&), signed char value, int& counter) {
  return callback(value, counter);
}
void Discard(signed char value, int& counter) { Make(value, counter); }
long Element(signed char value, int& counter, unsigned long index) { return Make(value, counter).values[index]; }
Value& Reference(Value& value) { return value; }
Value CopyReference(Value& value) { return Reference(value); }

Value Identity(Value value) { return value; }
Value Nested(signed char value, int& counter) { return Identity(Make(value, counter)); }
