int Replace(int value) {
  value = 29;
  return value;
}

int ValueParameters() {
  int value = 17;
  Replace(value);
  return value;
}
