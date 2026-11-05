// CW pointer difference converts both operands to their common pointer type;
// Clang keeps the original operand types and checks pointee compatibility.
void PointerArithmetic(int* pointer, const int* readonly, unsigned long count, long offset) {
  pointer + count;
  offset + readonly;
  pointer - readonly;
  pointer += count;
  ++pointer;
  pointer--;
}
