struct Item {
  int value;
};

// Use unsigned computation to express CW's defined i32 wraparound in C++17.
int& Add(int& target, int rhs) {
  target = static_cast<int>(static_cast<unsigned int>(target) + static_cast<unsigned int>(rhs));
  return target;
}
int& Multiply(int& target, int rhs) {
  target = static_cast<int>(static_cast<unsigned int>(target) * static_cast<unsigned int>(rhs));
  return target;
}
int& Locate(int& value, int& counter) {
  Add(counter, 1);
  return value;
}
int& Change(int& value, int& source) {
  source = 9;
  return value;
}
int Capture(int& value, int& source) {
  int rhs = source;
  int& lhs = Change(value, source);
  return Add(lhs, rhs);
}
int& Once(int& value, int& counter) {
  int rhs = value = 2;
  int& lhs = Locate(value, counter);
  return Add(lhs, rhs);
}
int ReadAfterRight(int& value) {
  int rhs = value = 2;
  return Add(value, rhs);
}
int& Chain(int& value) { return Multiply(Add(value, 2), 3); }
int RightAssociated(int& left, int& right) {
  int rhs = Multiply(right, 2);
  return Add(left, rhs);
}
int* Address(int& value) { return &Add(value, 2); }
int Field(Item& value) { return Add(value.value, 3); }
int Element(int (&value)[2], unsigned long index) {
  int rhs = value[index] = 2;
  return Add(value[index], rhs);
}
int& Conditional(int& first, int& second, bool choose) { return Add(choose ? first : second, 3); }
void Discard(int& value) {
  Add(value, 2);
  value = static_cast<int>(static_cast<unsigned int>(value) << (32 & 31));
}
