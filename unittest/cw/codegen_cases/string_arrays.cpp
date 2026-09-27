// Explicit bytes match CW's unterminated u8 arrays; trivial wrappers enable whole-array copying.
struct Array {
  unsigned char values[3];
};

static const Array Original{{'a', 'b', 'c'}};
static const Array Replacement{{'d', 'e', 'f'}};

unsigned char Copy(unsigned long index) {
  Array text = Original;
  text.values[index] = 'x';
  return static_cast<unsigned char>(text.values[index] + Original.values[index]);
}

Array& Assign(Array& target) { return target = Replacement; }

// Clang's zero-length array extension represents CW's empty string array.
struct EmptyArray {
  unsigned char values[0];
};

static const EmptyArray EmptyLiteral{};

void Empty() {
  EmptyArray text = EmptyLiteral;
  text = EmptyLiteral;
  (void)EmptyLiteral;
}
