// Struct values.
struct Byte {
  unsigned char value;
};
struct Odd {
  unsigned char bytes[3];
};
struct Pair {
  long first;
  long second;
};
struct Pointers {
  int* first;
  int* second;
};
struct Block {
  long values[3];
};

Byte Small(Byte value) { return value; }
Odd Three(Odd value) { return value; }
Pair TwoWords(Pair value) { return value; }
Pointers Addresses(Pointers value) { return value; }
Block Structure(Block value) { return value; }
Odd CopyThree(const Odd& value) { return Three(value); }

// Array values. Trivial wrappers preserve CW's whole-array value semantics.
struct NineBytes {  // CW: [9] u8.
  unsigned char values[9];
};
struct ThreeWords {  // CW: [3] i64.
  long values[3];
};
struct Booleans {  // CW: [2] bool.
  bool values[2];
};

NineBytes Nine(NineBytes value) { return value; }
ThreeWords Large(ThreeWords value) { return value; }
Booleans Boolean(Booleans value) { return value; }
NineBytes CopyNine(const NineBytes& value) { return Nine(value); }
