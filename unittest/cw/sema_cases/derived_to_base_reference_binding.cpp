struct Base {
  void Receive() const {}
};
struct Middle : Base {};
struct Derived : Middle {};
void Exact(const Base&) {}
void Exact(const Derived&) {}
void Near(const Base&) {}
void Near(const Middle&) {}
const Base& ReturnBase(const Derived& value) { return value; }
void DerivedToBaseReferenceBinding(Derived& value, Derived* pointer) {
  Base& base = value;
  Exact(value);
  Near(value);
  value.Receive();
  pointer->Receive();
  ReturnBase(value);
}
