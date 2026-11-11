struct Base {
  int value;
};
struct Left : Base {
  int left;
};
struct Right : Base {
  int value;
};
struct Pair : Left, Right {};
void MultipleInheritanceLookup(Pair pair) {
  pair.left;
  static_cast<Left&>(pair).value;
  static_cast<Right&>(pair).value;
  static_cast<Base&>(static_cast<Right&>(pair)).value;
}
