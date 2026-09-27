struct Item {
  int value;
  Item(int value) : value(value) {}
  Item(const Item&);
  ~Item() {}
};
void Inspect(const Item&) {}

Item Make() { return Item(1); }
Item Named() {
  // CW guarantees the named result's identity; C++ permits NRVO, used by this Clang.
  Item result(2);
  Inspect(result);
  return result;
}
Item Select(bool flag) { return flag ? Make() : Named(); }
void Results() {
  Item value = Make();
  Inspect(value);
  Named();
}
