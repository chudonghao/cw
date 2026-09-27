int& ForwardMutable(int& value) { return value; }
const int& ForwardCopy(const int& value) { return value; }
int&& ForwardMove(int&& value) { return static_cast<int&&>(value); }

int ReplaceThenRead(int& first, const int& second) {
  first = 41;
  return second;
}

int AliasedArguments() {
  int value = 1;
  return ReplaceThenRead(value, value);
}
