int& Select(int& value) { return value; }
const int& Select(const int& value) { return value; }
int&& Select(int&& value) { return static_cast<int&&>(value); }

void ReferenceBinding(int value) {
  int& link = value;
  const int fixed = value;
  Select(link);
  auto owned = Select(fixed);
  Select(static_cast<int&&>(value));
  Select(1);
}
