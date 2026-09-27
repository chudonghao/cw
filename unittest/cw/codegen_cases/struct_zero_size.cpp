struct Empty {};

// This uses Clang's zero-length array extension. Both languages retain the element alignment.
struct Aligned {
  long long values[0];
};

struct Wrapper {
  Empty empty;
  Aligned aligned;
  Empty repeated[2];
};

struct Mixed {
  unsigned char head;
  Aligned aligned;
  unsigned char tail;
  Empty empty;
};

void Zero(unsigned long index) {
  Wrapper object{};
  Wrapper copied = object;
  copied = object;
  Empty many[2]{Empty{}, Empty{}};
  Empty& reference = many[index];
}

void Store(Mixed& value) { value.tail = 1; }

Aligned& Forward(Aligned& value, int& counter) {
  counter = counter + 1;
  return value;
}

// Use a counter that remains representable after two increments.
void Assign(Aligned& source, Aligned& target, int& counter) { Forward(target, counter) = Forward(source, counter); }

// A zero-length wrapper models the storage of CW's huge array of zero-sized Aligned elements.
struct LargeValue {
  Aligned elements[0];
};

void Large(const LargeValue& source) { LargeValue copied = source; }
