struct Root {
  int number;
};
struct Base : Root {
  unsigned char tag;
};
struct Derived : Base {
  unsigned char own;
};

Base Make(int seed) {
  Base value{{seed}, 9};
  return value;
}

Derived Form(int seed) {
  Derived value{Make(seed), 7};
  return value;
}

unsigned char Assign(Derived& target, const Base& source) {
  Base& base = target;
  base = source;
  return target.own;
}

// C++ uses a trivial wrapper for CW's whole-array value return.
struct Array {
  Derived elements[2];
};
Array Copy(const Array& source) { return source; }

Derived Default() {
  Derived value{Base{}, 7};
  return value;
}
