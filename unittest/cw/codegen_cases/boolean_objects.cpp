bool Flip(bool value) {
  value = !value;
  return value;
}

bool& Refer(bool& value) { return value; }

bool BooleanObjects() {
  bool original = true;
  const bool copied = Flip(original);
  bool& bound = Refer(original);
  bound = false;
  return copied;
}
