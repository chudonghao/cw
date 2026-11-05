// Generated with -fwrapv-pointer: CW offsets wrap and may form addresses outside their storage.
struct Pair {
  long first;
  int second;
};

using Row = short[3];
using Callback = int (*)();
// CW virtual interface pointers correspond to this target's two-word member function pointers.
using Interface = int (Pair::*)() const;

int* Forward(int* pointer, unsigned long count) { return pointer + count; }
const int* Signed(long count, const int* pointer) { return count + pointer; }
Pair* Backward(Pair* pointer, unsigned long count) { return pointer - count; }
Row* Rows(Row* pointer, long count) { return pointer - count; }
int** Nested(int** pointer, unsigned long count) { return pointer + count; }
Callback* Callbacks(Callback* pointer, unsigned long count) { return pointer + count; }
Interface* Interfaces(Interface* pointer, long count) { return pointer + count; }
void Advance(int*& pointer, unsigned long count) { pointer += count; }
Pair* Retreat(Pair*& pointer, long count) { return pointer -= count; }
int* Increment(int*& pointer) { return ++pointer; }
const unsigned char* Decrement(const unsigned char*& pointer) { return pointer--; }
