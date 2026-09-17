int Overloaded(int value) { return value; }
long Overloaded(long value) { return value; }

int (*Select(int (*callback)(int)))(int) { return callback; }

int (*FunctionAddress())(int) {
  int (*callback)(int) = &Overloaded;
  return Select(&Overloaded);
}
