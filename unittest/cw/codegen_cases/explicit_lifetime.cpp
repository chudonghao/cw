#include <new>

struct Item {
  int value;
  Item(int value) : value(value) {}
  ~Item() {}
};
Item* Target(Item* address) { return address; }
int Argument(int value) { return value; }

Item* ConstructAt(Item* address, int value) { return new (Target(address)) Item(Argument(value)); }
void DestroyAt(const Item* address) { address->~Item(); }
void Manual(Item* address) {
  new (Target(address)) Item(Argument(1));
  Target(address)->~Item();
}
