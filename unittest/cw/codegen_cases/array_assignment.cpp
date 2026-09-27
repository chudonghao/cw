// C++ uses a trivial wrapper to express CW's whole-array object operations.
struct Array {
  int values[2];
};

int CopyAndMove(const Array& source, unsigned long index) {
  Array copied = source;
  Array moved = static_cast<Array&&>(copied);
  moved = source;
  moved = moved;
  return moved.values[index];
}

Array& Assign(Array& target, const Array& source) { return target = source; }

void Chain(Array& target, Array& middle, const Array& source) { target = middle = source; }
