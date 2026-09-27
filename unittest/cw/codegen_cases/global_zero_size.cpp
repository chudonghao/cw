long trace = 0;
void Mark(int value) { trace = trace * 10 + value; }
struct Empty {
  Empty() { Mark(1); }
  Empty(const Empty& other) { Mark(2); }
  ~Empty() { Mark(-1); }
};

Empty empty;
Empty pair[2];
// Clang's zero-length extension and a wrapper express CW's whole-array copy.
Empty none[0];
struct Matrix {
  Empty elements[2][0];
};
Matrix nested;
const Matrix& Source() {
  Mark(3);
  return nested;
}
Matrix copied = Source();
