int IntegerCopy() {
  int source = 17;
  const int copied = source;
  source = 29;
  return copied;
}

int NegativeInteger() { return -1; }
