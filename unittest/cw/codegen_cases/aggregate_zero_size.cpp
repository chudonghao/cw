struct Empty {};
// Clang's zero-length array extension preserves CW's zero size and alignment here.
struct Aligned {
  long values[0];
};
struct Value {
  long values[3];
};

Empty Make(int& counter) {
  counter = counter + 1;
  return {};
}
signed char Take(Empty value, signed char number) { return number; }
signed char Use(int& counter, signed char number) {
  Empty value = Make(counter);
  return Take(value, number);
}
Aligned Identity(Aligned value) { return value; }
void Form(const Aligned& value) { Aligned result = Identity(value); }
Value Mixed(Empty empty, bool flag, Value value, signed char number) { return value; }
Value Combine(const Value& value, bool flag, signed char number) { return Mixed({}, flag, value, number); }
