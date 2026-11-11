namespace api {
// These are defined in another translation unit, as CW's imported declarations are.
struct First {
  virtual int One() const;
  ~First();
};
struct Second {
  virtual int Two() const;
  int value;
  ~Second();
};
// Pair overrides Two of its secondary base; the implementation is defined elsewhere.
struct Pair : First, Second {
  int Two() const override;
  Pair();
  ~Pair();
};
}  // namespace api
// The vtable group of Derived refers to the imported implementation of Two. Clang refers to the
// external receiver-adjusting thunk; CW defines a private thunk.
struct Derived : api::Pair {
  int One() const override;
  Derived();
  ~Derived();
};
int Derived::One() const { return 1; }
Derived::Derived() : Pair() {}
Derived::~Derived() {}
int CallSecond(const api::Pair& pair) { return static_cast<const api::Second&>(pair).Two(); }
