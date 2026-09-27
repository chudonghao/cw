// CW wraps the accumulator; this C++ reference requires its sum to fit in int.
int NumericLoop(int limit) {
  int sum = 0;
  int index = 0;
  while (index < limit) {
    if (index % 2 == 0) {
      sum = sum + index;
    }
    index = index + 1;
  }
  return sum;
}
