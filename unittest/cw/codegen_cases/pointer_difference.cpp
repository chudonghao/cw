// CW truncates byte differences that are not element multiples. Clang's sdiv exact
// assumes both operands point into one array, so only such differences are compared.
struct Pair {
  long first;
  int second;
};

using Row = short[3];

long Elements(int* last, int* first) { return last - first; }
long Qualified(const int* last, int* first) { return last - first; }
long Bytes(unsigned char* last, const unsigned char* first) { return last - first; }
long Pairs(Pair* last, Pair* first) { return last - first; }
long Rows(Row* last, Row* first) { return last - first; }
// CW merges both sides to *const *const i32; C++ subtraction requires similar pointee types.
long Nested(int** last, const int* const* first) { return const_cast<const int* const*>(last) - first; }
