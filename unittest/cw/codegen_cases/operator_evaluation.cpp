struct Value {
  long long number;
  // The sum is representable in C++.
  long long operator()(long long value) const { return number + value; }
};
struct Empty {};

long long operator+(Value left, long long right) {
  left.number = left.number + right;
  return left.number;
}
long long Change(Value& value) {
  value.number = 9;
  return 0;
}
long long Capture(Value& value) {
  // Capture the first by-value argument before the second argument changes its source.
  Value first = value;
  long long second = Change(value);
  return first + second;
}

Value& Locate(Value& value, int& counter) {
  // The increment is representable in C++.
  counter = counter + 1;
  return value;
}
long long Invoke(Value& value, int& counter) {
  const Value& object = Locate(value, counter);
  long long argument = Change(value);
  return object(argument);
}

Empty operator!(Empty value) { return value; }
Empty MakeEmpty(int& counter) {
  counter = counter + 1;
  return Empty{};
}
void EmptyResult(int& counter) { !MakeEmpty(counter); }
