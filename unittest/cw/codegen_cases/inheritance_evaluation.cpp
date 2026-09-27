struct Base {
  int number;
};
struct Derived : Base {
  int own;
};

void Assign(Derived& (*source)(int&), Derived& (*target)(int&), int& counter) {
  // Capture the source object before locating the target, matching CW's assignment order.
  Base& value = source(counter);
  static_cast<Base&>(target(counter)) = value;
}
Base* Convert(Derived* (*callback)(int&), int& counter) { return callback(counter); }
int Temporary(Derived (*callback)(int&), int& counter) { return callback(counter).number; }
