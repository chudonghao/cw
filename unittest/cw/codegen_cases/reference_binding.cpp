int& Forward(int& value) { return value; }

int ReferenceBinding() {
  int value = 3;
  // C++ binds at declaration; CW separates the declaration from the binding.
  int& link = Forward(value);
  link = 19;
  return value;
}
