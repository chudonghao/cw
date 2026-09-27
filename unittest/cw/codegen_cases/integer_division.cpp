// C++ division and remainder are undefined for INT_MIN and -1. These guards
// express CW's defined results. All functions assume a nonzero divisor.
int Divide(int dividend, int divisor) {
  if (dividend == (-2147483647 - 1) && divisor == -1) {
    return -2147483647 - 1;
  }
  return dividend / divisor;
}

int Remainder(int dividend, int divisor) {
  if (divisor == -1) {
    return 0;
  }
  return dividend % divisor;
}

// Reuse the guards instead of writing undefined C++ boundary expressions.
int DivideByNegativeOne(int value) { return Divide(value, -1); }

int RemainderByNegativeOne(int value) { return Remainder(value, -1); }

int MinimumQuotient() { return Divide(-2147483647 - 1, -1); }

int MinimumRemainder() { return Remainder(-2147483647 - 1, -1); }

int SignedQuotients() { return (-7 / 3) * 100 + (7 / -3) * 10 + (-7 / -3); }

int SignedRemainders() { return (-7 % 3) * 100 + (7 % -3) * 10 + (-7 % -3); }
