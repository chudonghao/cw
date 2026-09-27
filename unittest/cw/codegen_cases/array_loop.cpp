int Sum(const int (&values)[2], unsigned long begin, unsigned long end, unsigned long step) {
  int total = 0;
  unsigned long index = begin;
  while (index < end) {
    // Inputs keep the sum representable in C++; CW's signed addition wraps.
    total = total + values[index];
    index = index + step;
  }
  return total;
}
