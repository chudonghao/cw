// C++ additionally stores a terminator; indices address the three content bytes in both languages.
using Text = char[4];

const Text& Borrow() { return "abc"; }

const Text* Pointer() { return &"abc"; }

unsigned char Read(const Text& value, unsigned long index) { return static_cast<unsigned char>(value[index]); }

unsigned char Use(unsigned long index) {
  unsigned char (*callback)(const Text&, unsigned long) = &Read;
  // CW's receiver call passes the literal as the first argument.
  return static_cast<unsigned char>(Read(Borrow(), index) + callback(*Pointer(), index) + Read("abc", index));
}
