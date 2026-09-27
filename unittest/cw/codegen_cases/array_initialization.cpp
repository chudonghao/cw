int Integers(int value, unsigned long index) {
  int values[2]{value, 7};
  return values[index];
}

short Nested(short value, unsigned long outer, unsigned long inner) {
  short values[2][1];
  // CW's initialization block forms the declared array at this point.
  {
    values[0][0] = value;
    values[1][0] = 5;
  }
  return values[outer][inner];
}

bool Booleans(bool value, unsigned long index) {
  bool values[2]{value, false};
  return values[index];
}

double Floating(double value, unsigned long index) {
  double values[2]{value, 2.5};
  return values[index];
}

int* Pointers(int* value, unsigned long index) {
  int* values[2]{value, nullptr};
  return values[index];
}
