struct Base {};
struct Middle : Base {};
struct Derived : Middle {};
void Exact(const Derived*) {}
void Exact(Derived*) {}
void Near(Base*) {}
void Near(Middle*) {}
void ObjectPointerConversion(Derived* derived, Derived** nested) {
  Base* base = derived;
  const Base* readonly_base = derived;
  const Derived* readonly_derived = derived;
  const Derived* const* safe_nested = nested;
  Exact(derived);
  Near(derived);
}
