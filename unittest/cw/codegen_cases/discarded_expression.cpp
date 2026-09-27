const int& Touch(int& value) {
  value = 47;
  return value;
}

int DiscardedExpression() {
  int value = 1;
  Touch(value);
  return value;
}
