#include <utility>

struct Item {
  int value;
  Item(int value) : value(value) {}
  ~Item() {}
  void operator=(const Item& source) { value = source.value; }
  Item& operator=(Item&& source) {
    value = source.value;
    return *this;
  }
};
// C++ wrappers supply the whole-array assignment supported directly by CW.
struct Pair {
  Item elements[2];
};
struct Matrix {
  Item elements[2][2];
};
Pair& Copy(Pair& target, const Pair& source) { return target = source; }
Pair& Move(Pair& target, Pair&& source) { return target = std::move(source); }
void Nested(Matrix& target, const Matrix& source) { target = source; }

struct CopyOnly {
  int value;
  CopyOnly(int value) : value(value) {}
  ~CopyOnly() {}
  int operator=(const CopyOnly& source) {
    value = source.value;
    return 7;
  }
};
struct CopyPair {
  CopyOnly elements[2];
};
void Fallback(CopyPair& target, CopyPair&& source) { target = std::move(source); }

struct ZeroMatrix {
  Item elements[3][0];
};  // Clang's zero-length array extension.
const ZeroMatrix& ZeroSource(const ZeroMatrix& source, int& counter) {
  // The decimal trace remains representable in these examples.
  counter = counter * 10 + 1;
  return source;
}
ZeroMatrix& ZeroTarget(ZeroMatrix& target, int& counter) {
  counter = counter * 10 + 2;
  return target;
}
void NestedZero(ZeroMatrix& target, const ZeroMatrix& source, int& counter) {
  ZeroTarget(target, counter) = ZeroSource(source, counter);
}

struct Empty {
  Empty() {}
  ~Empty() {}
  void operator=(const Empty& source) {}
};
struct EmptyPair {
  Empty elements[2];
};
void EmptyElements(EmptyPair& target, const EmptyPair& source) { target = source; }
