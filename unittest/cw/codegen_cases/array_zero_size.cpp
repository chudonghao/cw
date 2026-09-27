// Clang's zero-length array extension represents CW's zero-sized arrays.
// The wrappers enable whole-array copying; their zero size is not standard C++.
struct Empty {
  int values[0];
};

Empty& Forward(Empty& value) { return value; }

void Assign(Empty& source, Empty& target) { Forward(target) = Forward(source); }

unsigned long Index(unsigned long& value) {
  value = value + value;
  return value - value;
}

void Nested(unsigned long& value) {
  Empty values[2]{{}, {}};
  Empty copied = values[Index(value)];
  values[Index(value)] = Empty{};
}

struct LargeArray {
  int values[18446744073709551615UL][0];
};

void Large(const LargeArray& source) { LargeArray copied = source; }
