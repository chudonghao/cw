struct Base {
  int value;
};
struct Left : Base {};
struct Right {};
struct Pair : Left, Right {};
void Pick(const Base& object) {}
void Pick(const Left& object) {}
void MultipleInheritanceConversion(Pair& pair, Pair* pointer, Left* left) {
  Base& base = pair;
  Right* right = pointer;
  Pick(pair);
  auto same = left == pointer;
}
