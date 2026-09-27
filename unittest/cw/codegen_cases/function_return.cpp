void Set(int& value) {
  value = 43;
  return;
  value = 61;
}

void Empty() {}

int ExplicitReturn() {
  int value = 1;
  Set(value);
  Empty();
  return value;
}

int ReturningBranches(bool a, bool b, bool c) {
  if (a ? !b : (b || c)) {
    return 1;
  } else {
    return 2;
  }
  return 3;
}

int TailResult(bool flag, bool other) {
  if (flag) {
    return 1;
  }
  // Explicit returns express CW's implicit tail result.
  if (other) {
    return 2;
  } else {
    return 3;
  }
}

void SetUnless(bool flag, bool& target) {
  if (flag) {
    return;
  }
  target = true;
}
