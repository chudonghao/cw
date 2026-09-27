#include <utility>

struct Item {
  int value;
  Item(int value) : value(value) {}
  Item(const Item& other) : value(other.value) {}
  Item(Item&& other) : value(other.value) {}
  ~Item() {}
};
// C++ wrappers supply whole-array copying and moving, which CW supports directly.
struct Pair {
  Item elements[2];
};
struct Matrix {
  Item elements[1][2];
};
struct ZeroArray {
  Item elements[0];
};  // Clang's zero-length array extension.
void Copy(const Pair& source) { Pair value = source; }
void Move(Pair&& source) { Pair value = std::move(source); }
void Nested(const Matrix& source) { Matrix value = source; }
void Zero(const ZeroArray& source) { ZeroArray value = source; }

struct ZeroMatrix {
  Item elements[3][0];
};
const ZeroMatrix& ZeroSource(const ZeroMatrix& source, int& counter) {
  // The increment is representable in C++.
  counter = counter + 1;
  return source;
}
void NestedZero(const ZeroMatrix& source, int& counter) { ZeroMatrix value = ZeroSource(source, counter); }

struct Empty {
  Empty() {}
  Empty(const Empty& other) {}
  ~Empty() {}
};
void EmptyElements() { Empty value[2] = {Empty(), Empty()}; }
struct EmptyPair {
  Empty elements[2];
};
void CopyEmpty(const EmptyPair& source) { EmptyPair value = source; }
Empty EmptyValue(Empty value) { return Empty(); }
void Discard() { EmptyValue(Empty()); }

struct Holder {
  // CW permits zero-sized Holder elements. Give the C++ reference distinct addresses
  // so Clang's pointer-based array destruction visits every element.
  unsigned char storage{};
  Item items[0];
  Holder(const Holder& source) {}
  ~Holder() {}
};
struct HolderPair {
  Holder elements[2];
};
void Holders(const HolderPair& source) { HolderPair value = source; }
