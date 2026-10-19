int Bump(int& value) {
  value = value + 1;
  return value;
}

// Explicit temporaries preserve CW's complete left-to-right reads and effects.
// Inputs keep increments and multiplication representable in this reference.
int LeftBeforeCall(int& value) {
  int left = value;
  int right = Bump(value);
  return static_cast<int>(static_cast<unsigned int>(left) << (static_cast<unsigned int>(right) & 31));
}
int RightBeforeCall(int& value) {
  int left = value;
  int right = Bump(value);
  return left >> (static_cast<unsigned int>(right) & 31);
}
int BothCalls(int& value) {
  int left = Bump(value);
  int right = Bump(value);
  return static_cast<int>(static_cast<unsigned int>(left) << (static_cast<unsigned int>(right) & 31));
}
int ZeroLeft(int& value) { return 0 << (static_cast<unsigned int>(Bump(value)) & 31); }
int ZeroCount(int& value) {
  int left = Bump(value);
  int right = Bump(value) * 32;
  return left >> (static_cast<unsigned int>(right) & 31);
}
