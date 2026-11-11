// These are defined in another translation unit, as CW's imported declarations are.
struct A {
  virtual int F() const;
  int value;
  ~A();
};
// B overrides F and C does not, so the two A subobjects of D have different final overriders.
struct B : A {
  int F() const override;
  B();
  ~B();
};
struct C : A {
  virtual int G() const;
  C();
  ~C();
};

// In the secondary vtable of C, F stays A's implementation and G reaches D's override through
// a thunk. C++ restores the base vptrs in the base destructors; CW leaves D's dispatch in D's
// destructor.
struct D : B, C {
  int G() const override;
  D();
  ~D();
};
int D::G() const { return 4; }
D::D() : B(), C() {}
D::~D() {}

int ReadThroughC(const D& d) {
  const C& c = d;
  return c.F() + c.G();
}
