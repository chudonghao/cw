struct Base {
  Base() {}
  Base(Base&&) {}
  ~Base() {}
};
Base Make() { return Base(); }
struct Derived : Base {
  Derived();
  Derived(int);
  Derived(bool);
  ~Derived() {}
};
// CW grouping parentheses preserve direct base construction.
Derived::Derived() : Base() {}
Derived::Derived(int) : Base(Make()) {}
Derived::Derived(bool condition) : Base(condition ? Base() : Make()) {}
