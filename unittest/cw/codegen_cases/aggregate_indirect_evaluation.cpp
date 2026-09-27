struct Value {
  long values[3];
};
using Callback = Value (*)(Value, int);

Value Other(Value value, int ignored) { return value; }
int Replace(Callback& callback) {
  callback = &Other;
  return 0;
}
Value Invoke(Callback& callback, const Value& value) {
  // CW captures the callee and each argument before evaluating the next one.
  Callback callee = callback;
  Value argument = value;
  int ignored = Replace(callback);
  return callee(argument, ignored);
}
