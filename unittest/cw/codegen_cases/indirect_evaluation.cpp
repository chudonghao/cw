using Callback = int (*)(int);

int First(int value) { return value; }

// Calls in this example pass a representable negation operand.
int Other(int value) { return -value; }

int Replace(Callback& callback) {
  callback = &Other;
  return 5;
}

int Invoke(Callback& callback) {
  // Preserve the callee value before the argument changes the callback object.
  Callback target = callback;
  int value = Replace(callback);
  return target(value);
}

int Run() {
  Callback callback = &First;
  return Invoke(callback);
}

// The order example uses a value whose increment is representable.
int Mutate(int& value) {
  value = value + 1;
  return value;
}

int Arguments(int (*callback)(int, int), int& value) {
  // CW completes each argument before evaluating the next one.
  auto target = callback;
  int first = value;
  int second = Mutate(value);
  return target(first, second);
}
