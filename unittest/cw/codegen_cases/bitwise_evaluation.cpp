int Bump(int& value) {
  value = value + 1;
  return value;
}

// Explicit temporaries preserve CW's left-to-right reads and effects.
int AndBeforeCall(int& value) {
  int left = value;
  int right = Bump(value);
  return left & right;
}

int OrBeforeCall(int& value) {
  int left = value;
  int right = Bump(value);
  return left | right;
}

int XorBeforeCall(int& value) {
  int left = value;
  int right = Bump(value);
  return left ^ right;
}

int InvertCall(int& value) { return ~Bump(value); }

int BothCalls(int& value) {
  int left = Bump(value);
  int right = Bump(value);
  return left & right;
}

int ZeroMask(int& value) { return 0 & Bump(value); }

int AllOnesMask(int& value) { return -1 | Bump(value); }
