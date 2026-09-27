// CW wraps arithmetic. This sequencing reference uses inputs for which C++
// arithmetic fits and division has a nonzero divisor and representable quotient.
int Bump(int& value) {
  value = value + 1;
  return value;
}

// C++ operand order is not CW's fixed left-to-right order. Explicit temporaries
// preserve CW's value reads and calls without relying on C++ evaluation choices.
int ReadBeforeCall(int& value) {
  int left = value;
  int right = Bump(value);
  return left + right;
}

bool CompareBeforeCall(int& value) {
  int left = value;
  int right = Bump(value);
  return left == right;
}

int DivideOnce(int& value) {
  int left = Bump(value);
  int right = Bump(value);
  return left / right;
}

int RemainderSideEffect(int& value) {
  // CW defines even INT_MIN % -1 as zero; the operand's effect still happens.
  Bump(value);
  return 0;
}

int ConditionalDivisor(int& value, bool flag) {
  int left = flag ? Bump(value) : value;
  int right = flag ? -1 : Bump(value);
  return left / right;
}

bool ShortCircuitDivision(bool flag, int left, int right) { return flag && left / right > 0; }

int Consume(int value) { return value; }

int DiscardAndPass(int& value) {
  static_cast<void>(Bump(value) + 1);
  return Consume(Bump(value) * 2);
}
