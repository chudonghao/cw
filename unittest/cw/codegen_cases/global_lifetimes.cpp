long trace = 0;
void Mark(int value) { trace = trace * 10 + value; }
bool Flag() { return true; }
struct Item {
  int value;
  Item(int value) : value(value) { Mark(value); }
  ~Item() { Mark(-value); }
};
void Observe(const Item& value) { Mark(value.value); }

// A C++ wrapper expresses CW's shared initialization block and the same object lifetimes.
struct Globals {
  Item first;
  Item second;
};
Globals values = [] {
  Item local(1);
  return Globals{Flag() ? Item(2) : Item(3), [] {
                   Observe(Item(4));
                   return Item(5);
                 }()};
}();
Item pair[2] = {Item(6), Item(7)};
