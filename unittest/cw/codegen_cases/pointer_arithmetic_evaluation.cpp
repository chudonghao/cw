// Generated with -fwrapv-pointer: CW offsets wrap and may form addresses outside their storage.
unsigned long Count(unsigned long& counter) {
  counter += 1;
  return counter;
}
int*& Locate(int*& pointer, unsigned long& calls) {
  calls += 1;
  return pointer;
}
int* OffsetFirst(int*& pointer, unsigned long& counter) {
  // CW evaluates the offset operand completely before the pointer operand.
  unsigned long offset = Count(counter);
  return offset + Locate(pointer, counter);
}
int* SourceFirst(int*& pointer, unsigned long& counter) {
  // CW forms the source value before locating the target.
  unsigned long offset = Count(counter);
  return Locate(pointer, counter) += offset;
}
bool Old(int*& pointer) {
  int* before = pointer++;
  return before != pointer;
}
void Discard(int*& pointer, unsigned long& counter) { Locate(pointer, counter)--; }
long Distance(int*& pointer, unsigned long& counter) {
  // CW completes the left postfix update before reading the right operand.
  int* before = Locate(pointer, counter)++;
  return before - pointer;
}
