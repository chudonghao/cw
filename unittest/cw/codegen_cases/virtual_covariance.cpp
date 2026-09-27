struct Product {
  int value;
  Product();
  ~Product();
};
Product::Product() : value(42) {}
Product::~Product() {}
struct SpecialProduct : Product {
  virtual int Tag() const;
  SpecialProduct();
  ~SpecialProduct();
};
int SpecialProduct::Tag() const { return 7; }
SpecialProduct::SpecialProduct() : Product() {}
SpecialProduct::~SpecialProduct() {}
struct Source {
  virtual Product* Pointer() const = 0;
  virtual const Product& Reference() const = 0;
  Source();
  ~Source();
};
struct SpecialSource : Source {
  SpecialProduct* target;
  SpecialProduct* Pointer() const override;
  const SpecialProduct& Reference() const override;
  explicit SpecialSource(SpecialProduct* target);
  ~SpecialSource();
};
SpecialProduct* SpecialSource::Pointer() const { return target; }
const SpecialProduct& SpecialSource::Reference() const { return *target; }
Source::Source() {}
Source::~Source() {}
SpecialSource::SpecialSource(SpecialProduct* input) : Source(), target(input) {}
SpecialSource::~SpecialSource() {}
Product* GetPointer(const Source& source) { return source.Pointer(); }
const Product& GetReference(const Source& source) { return source.Reference(); }
bool Check() {
  SpecialProduct product;
  SpecialSource source(&product), empty(nullptr);
  return GetPointer(source) == static_cast<Product*>(&product) &&
         &GetReference(source) == static_cast<Product*>(&product) && GetPointer(empty) == nullptr &&
         source.Pointer() == &product;
}

Product* ConvertPointer(SpecialProduct* product) { return product; }
const Product& ConvertReference(const SpecialProduct& product) { return product; }
