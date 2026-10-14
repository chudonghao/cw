// Product and Source operations are defined in another translation unit.
struct Product {
  int value;
  ~Product();
};
struct SpecialProduct : Product {
  virtual int Tag() const;
  ~SpecialProduct();
};
struct Source {
  virtual Product* Pointer() const = 0;
  virtual const Product& Reference() const = 0;
  ~Source();
};
struct SpecialSource : Source {
  SpecialProduct* Pointer() const override;
  const SpecialProduct& Reference() const override;
  SpecialSource();
  ~SpecialSource();
};
// Clang references external return-adjusting thunks provided with SpecialSource's
// definitions. CW emits private thunks beside Local's table, preserving null
// pointers and adjusting references to the Product subobject at offset 8 on this target.
// Clang's table is linkonce_odr; CW's named Local table has external linkage.
struct Local : SpecialSource {
  Local();
  ~Local();
};
Local::Local() : SpecialSource() {}
Local::~Local() {}
Product* PointerCall(const Source& value) { return value.Pointer(); }
const Product& ReferenceCall(const Source& value) { return value.Reference(); }
struct Another : SpecialSource {
  Another();
  ~Another();
};
Another::Another() : SpecialSource() {}
Another::~Another() {}
