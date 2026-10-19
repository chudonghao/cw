struct Item {
  int value;
};

// Preserve CW's defined integer wrapping and evaluation order explicitly.
int Increment(int& value) {
  int old = value;
  value = static_cast<int>(static_cast<unsigned int>(value) + 1u);
  return old;
}
int Decrement(int& value) {
  int old = value;
  value = static_cast<int>(static_cast<unsigned int>(value) - 1u);
  return old;
}
int& Locate(int& value, int& counter) {
  Increment(counter);
  return value;
}
int& Prefix(int& value, int& counter) {
  int& target = Locate(value, counter);
  Increment(target);
  return target;
}
int Postfix(int& value, int& counter) { return Decrement(Locate(value, counter)); }
int Pair(int& value) {
  int left = Increment(value);
  int right = value;
  return static_cast<int>(static_cast<unsigned int>(left) + static_cast<unsigned int>(right));
}
int Mixed(int& value) {
  Increment(value);
  int left = value;
  int right = Increment(value);
  return static_cast<int>(static_cast<unsigned int>(left) + static_cast<unsigned int>(right));
}
int SelfAssignment(int& value) {
  int right = Increment(value);
  return value = right;
}
int Element(int (&data)[2], unsigned long& index) {
  unsigned long old_index = index++;
  return Increment(data[old_index]);
}
int Conditional(int& first, int& second, bool choose) { return Increment(choose ? first : second); }
bool ShortCircuit(int& value, bool choose) { return choose && Increment(value) == 1; }
int* Address(int& value) {
  Decrement(value);
  return &value;
}
int Chain(int& value) {
  Increment(value);
  Increment(value);
  return value;
}
void Assign(int& value) {
  Increment(value);
  value = 5;
}
int Compound(int& value) {
  int right = Increment(value);
  Increment(value);
  return value = static_cast<int>(static_cast<unsigned int>(value) + static_cast<unsigned int>(right));
}
int Field(Item& item) { return Increment(item.value); }
int Dereference(int* pointer) { return Decrement(*pointer); }
void Discard(int& value) {
  Increment(value);
  Increment(value);
  Decrement(value);
  Decrement(value);
}
