struct Value {
  int number;
  Value(int number) : number(number) {}
  ~Value() {}
  void operator=(const Value& source) { number = source.number; }
};

Value& Target(Value& target, Value& source, const Value& token) {
  source.number = token.number;
  return target;
}
Value Source(const Value& source) { return Value(source.number); }

int Infix() {
  Value source(1);
  Value target(0);
  Target(target, source, Value(9)) = Source(source);
  return target.number;
}
int Explicit() {
  Value source(1);
  Value target(0);
  // C++ requires member assignment; its explicit call evaluates the target before the argument.
  Target(target, source, Value(9)).operator=(Source(source));
  return target.number;
}
