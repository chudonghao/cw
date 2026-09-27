#pragma clang fp contract(off)

double Bump(float& value) {
  value = value + 1.0f;
  return value;
}

double ReadBeforeBump(float& value) {
  // CW completes the left read and conversion before the right-side mutation.
  double left = value;
  double right = Bump(value);
  return left + right;
}

double Pair(double first, double second) { return first + second; }

double ArgumentOrder(float& value) {
  // Make CW argument evaluation order explicit.
  double first = value;
  double second = Bump(value);
  return Pair(first, second);
}

double Choose(bool flag, float left, double right) { return flag ? left : right; }

double Sum(int limit) {
  int index = 0;
  double sum = 0.0;
  while (index < limit) {
    sum = sum + index;
    index = index + 1;
  }
  return sum;
}

float& Select(bool flag, float& left, float& right) { return flag ? left : right; }

void WriteChosen(bool flag, float& left, float& right, double value) {
  Select(flag, left, right) = static_cast<float>(value);
}
