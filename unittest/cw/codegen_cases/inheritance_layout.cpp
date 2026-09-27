struct Root {
  int number;
};
struct Middle : Root {
  unsigned char tag;
};
struct Leaf : Middle {
  unsigned char extra;
};
struct Box {
  unsigned char head;
  Leaf value;
};

int Fields(int number, unsigned char tag, unsigned char extra) {
  Leaf value{{{number}, tag}, extra};
  return value.number;
}

unsigned char* Extra(Leaf& value) { return &value.extra; }
int Element(const Leaf (&values)[2], unsigned long index) { return values[index].number; }
unsigned char* Nested(Box& value) { return &value.value.extra; }
