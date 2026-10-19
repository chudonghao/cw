long long trace = 0;
struct Base {
  int value;
  explicit Base(int value) : value(value) {}
  Base(const Base& source) : value(source.value) {}
  ~Base() {}
};
struct Item : Base {
  explicit Item(int value) : Base{value} {}
  Item(const Item& source) : Base(source) { trace = trace * 10 + 2; }
  Item(Item&& source) : Base(source) { trace = trace * 10 + 3; }
  ~Item() { trace = trace * 10 + 4; }
};
struct Receipt { ~Receipt() { trace = trace * 10 + 6; } };
// C++ does not permit CW's nonmember assignment or whole-array assignment syntax.
// These helpers and loops preserve the selected conversions and per-element full-expressions.
Receipt Assign(Base& target, Item source) {
  target.value = source.value;
  trace = trace * 10 + 5;
  return Receipt{};
}
void Copy(Item (&target)[2], const Item (&source)[2]) {
  for (int i = 0; i < 2; ++i) Assign(target[i], source[i]);
}
void Move(Item (&target)[2], Item (&&source)[2]) {
  for (int i = 0; i < 2; ++i) Assign(target[i], static_cast<Item&&>(source[i]));
}
void Nested(Item (&target)[1][2], const Item (&source)[1][2]) {
  for (int i = 0; i < 1; ++i)
    for (int j = 0; j < 2; ++j) Assign(target[i][j], source[i][j]);
}
void Zero(Item (&target)[0], const Item (&source)[0]) {}
namespace ByValue {
int Assign(Item target, const Base& source) { target.value = source.value; return 7; }
void Copy(Item (&target)[2], const Item (&source)[2]) {
  for (int i = 0; i < 2; ++i) ByValue::Assign(target[i], source[i]);
}
}
