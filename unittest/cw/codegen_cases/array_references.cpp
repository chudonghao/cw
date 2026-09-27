using Array = int[2];

int First(const Array& value, unsigned long index) { return value[index]; }

Array& Forward(Array& value) { return value; }

Array&& ForwardMove(Array&& value) { return static_cast<Array&&>(value); }

int ThroughPointer(Array& value, unsigned long index) {
  // Use index zero and values whose sum is representable in C++.
  auto* pointer = &value;
  auto& bound = Forward(*pointer);
  int (*callbacks[1])(const Array&, unsigned long) = {&First};
  // Preserve CW's left-to-right operand evaluation; receiver calls are free-function calls.
  int left = callbacks[index](bound, index);
  int right = First(ForwardMove(static_cast<Array&&>(bound)), index);
  return left + right;
}
