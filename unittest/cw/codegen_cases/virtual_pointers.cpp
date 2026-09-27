struct Item {
  int value;
  virtual int First() const;
  virtual int Second() const;
  explicit Item(int value);
  ~Item();
};
int Item::First() const { return value; }
int Item::Second() const { return value + 10; }
Item::Item(int input) : value(input) {}
Item::~Item() {}
using Pointer = int (Item::*)() const;
Pointer Identity(Pointer pointer) { return pointer; }
const Item& Replace(Pointer& pointer, const Item& item) {
  pointer = &Item::Second;
  return item;
}
int DirectFirst(const Item& item) { return item.Item::First(); }
int Invoke(const Item& item) {
  Pointer pointer = Identity(&Item::First);
  auto copied = pointer;
  auto direct = &DirectFirst;
  // CW captures the unbound callee before evaluating its receiver argument.
  auto saved = pointer;
  int result = (Replace(pointer, item).*saved)();
  return result + (item.*pointer)() + (item.*copied)() + direct(item);
}
int Entry() {
  Item first(3), second(7);
  return Invoke(first) + Invoke(second);
}
bool Empty() {
  Pointer pointer = nullptr;
  return pointer == nullptr;
}
bool Present() {
  Pointer pointer = &Item::First;
  return nullptr != pointer;
}
