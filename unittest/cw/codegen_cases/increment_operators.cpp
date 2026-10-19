namespace Api {
struct Value {
  int number;
};
Value& operator++(Value& value);
Value operator++(Value& value, int marker);
int operator--(Value value);
void operator--(Value&& value, int marker);

Value& Prefix(Value& value) { return ++value; }
Value Postfix(Value& value) { return value++; }
int ByValue(Value value) { return --value; }
void Discard(Value& value) { static_cast<Value&&>(value)--; }
Value& Locate(Value& value, int& count) {
  // CW signed increments wrap; use unsigned arithmetic for the C++ counterpart.
  count = static_cast<int>(static_cast<unsigned int>(count) + 1U);
  return value;
}
Value Once(Value& value, int& count) { return Locate(value, count)++; }
Value Nested(Value& value) { return (++value)++; }
}  // namespace Api

Api::Value Explicit(Api::Value& value, int marker) { return ::Api::operator++(value, marker); }
Api::Value Indirect(Api::Value& value, int marker) {
  Api::Value (*operation)(Api::Value&, int) = &Api::operator++;
  return operation(value, marker);
}
