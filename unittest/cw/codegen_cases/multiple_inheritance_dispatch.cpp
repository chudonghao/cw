// These are defined in another translation unit, as CW's imported declarations are.
struct Left {
  virtual int Name() const;
  int left;
  Left();
  ~Left();
};
struct Tag {
  virtual int Size() const;
  ~Tag();
};
struct Inner {
  virtual int Deep() const = 0;
  ~Inner();
};
// Tag is the primary base of Right, and Inner has a secondary vtable nested in Right's group.
struct Right : Tag, Inner {
  virtual int Name() const;
  int right;
  Right();
  ~Right();
};

// One override replaces Name in both bases. Size overrides a secondary base, so it also takes a
// new slot in the primary vtable. Deep stays abstract, so Both is abstract too.
// C++ destructors restore the base vptrs in the base destructors; CW leaves Both's dispatch in
// Both's destructor, before members are destroyed.
struct Both : Left, Right {
  int Name() const override;
  int Size() const override;
  Both();
  ~Both();
};
int Both::Name() const { return 1; }
int Both::Size() const { return 2; }
Both::Both() : Left(), Right() {}
Both::~Both() {}

// The vtable group of Child reuses the thunks of Both.
struct Child : Both {
  Child();
  ~Child();
};
Child::Child() : Both() {}
Child::~Child() {}

int ReadDeep(const Both& both) { return both.Deep(); }
// A C++ member function pointer stands for CW's virtual interface pointer.
int ViaPointer(const Both& both) {
  int (Tag::*size)() const = &Tag::Size;
  return (both.*size)();
}
int Direct(const Both& both) { return both.Right::Name(); }
