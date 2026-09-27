int& MutatingTarget(int& value) {
  value = 73;
  return value;
}

int AssignmentOrder() {
  int value = 11;
  MutatingTarget(value) = value;
  return value;
}

int& Target(int& value) { return value; }
int& AssignOnce(int& value) { return Target(value) = 17; }

int Change(bool& flag) {
  flag = !flag;
  return 17;
}

int ConditionalAssignment(bool flag) {
  int left = 1;
  int right = 2;
  (flag ? left : right) = Change(flag);
  return flag ? left : right;
}
