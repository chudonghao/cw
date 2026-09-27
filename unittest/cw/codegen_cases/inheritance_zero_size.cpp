struct Empty {};
// Clang's zero-length array extension retains the element alignment.
struct ZeroBase {
  long long values[0];
};
struct ZeroDerived : ZeroBase {
  Empty empty;
};
struct Occupied : ZeroDerived {
  Empty empty;
  int number;
};

// Use a counter whose increment is representable in C++.
ZeroDerived Make(int& counter) {
  counter = counter + 1;
  return ZeroDerived{};
}
ZeroDerived Identity(ZeroDerived value) { return value; }

Occupied Form(int& counter) {
  Occupied value{Make(counter), Empty{}, 1};
  return value;
}

bool Same(Occupied& value) { return &value.empty == &value.ZeroDerived::empty; }
ZeroBase* Base(Occupied& value) { return &static_cast<ZeroBase&>(value); }
