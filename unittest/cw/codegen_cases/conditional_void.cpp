void Write(int& target, int value) { target = value; }

int ConditionalVoid(bool flag, bool other) {
  int value = 0;
  flag ? Write(value, 1) : (other ? Write(value, 2) : Write(value, 3));
  return value;
}
