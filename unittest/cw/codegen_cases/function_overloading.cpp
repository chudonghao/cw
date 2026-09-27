int Select(const int& value) { return 7; }
int Select(int& value) { return 13; }
int Select(int&& value) { return 19; }

int FunctionOverloading() {
  int value = 0;
  const int fixed = 0;
  Select(value);
  Select(fixed);
  return Select(static_cast<int&&>(value));
}
