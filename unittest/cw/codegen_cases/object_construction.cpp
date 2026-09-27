#include <utility>

struct Item {
  int value;
  Item(int value) : value(value) {}
  Item(const Item& other) : value(other.value) {}
  Item(Item&& other) : value(other.value) {}
  Item() : Item(7) {}
  ~Item() {}
};

void Construct() {
  Item first;
  Item copied = first;
  Item moved = std::move(first);
  Item(9);
}
