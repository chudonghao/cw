using Array = int[2];

Array& Choose(bool flag, Array& left, Array& right) { return flag ? left : right; }

// A wrapper supplies C++ value semantics for the complete array result.
struct ValueArray {
  int values[2];
};

int Value(bool flag, const ValueArray& source, unsigned long index) {
  ValueArray values = flag ? source : ValueArray{{7, 8}};
  return values.values[index];
}

int Temporary(unsigned long index) { return ValueArray{{5, 7}}.values[index]; }
