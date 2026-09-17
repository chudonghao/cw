struct Base {
  int value;
  Base(int value) : value(value) {}
  ~Base() {}
};
struct SingleInheritance : Base {
  int own;
  SingleInheritance(int value) : Base(value), own(value) {}
  ~SingleInheritance() {}
};
int ReadBase(const SingleInheritance& value) {
  return static_cast<const Base&>(value).value;
}
int ReadBasePointer(SingleInheritance* value) {
  return static_cast<Base*>(value)->value;
}
struct Root {
  int root;
};
struct Middle : Root {};
struct Leaf : Middle {};
int ReadIndirectBase(const Leaf& value) {
  return static_cast<const Root&>(value).root;
}
int ReadExplicitBasePath(const Leaf& value) {
  return static_cast<const Root&>(static_cast<const Middle&>(value)).root;
}
