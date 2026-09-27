struct Root {
  int value;
};
struct Middle : Root {
  short value;
};
// This field hides the base name for explicit selection, but not for an implicit conversion.
struct Leaf : Middle {
  signed char Root;
};

Root& Select(Leaf& value) { return value; }
const Root* Pointer(Leaf* value) { return value; }
Root* Null() {
  Leaf* value = nullptr;
  return value;
}

int Explicit(Leaf* value) { return static_cast<Root&>(static_cast<Middle&>(*value)).value; }
signed char Hidden(const Leaf& value) { return value.Root; }
short Nearest(const Leaf& value) { return value.value; }
