struct Product {};
struct SpecialProduct : Product {};

struct Factory {
  virtual Product* Pointer() const = 0;
  virtual Product& Mutable() const = 0;
  virtual const Product& Copyable() const = 0;
  virtual Product&& Movable() const = 0;
};

struct SpecialFactory : Factory {
  SpecialProduct* Pointer() const override = 0;
  SpecialProduct& Mutable() const override = 0;
  const SpecialProduct& Copyable() const override = 0;
  SpecialProduct&& Movable() const override = 0;
};

void Observe(const Product&) {}
void Observe(const SpecialProduct&) {}
void Consume(Product&&) {}
void Consume(SpecialProduct&&) {}

void Use(const Factory& factory, const SpecialFactory& special) {
  Product* base_pointer = factory.Pointer();
  SpecialProduct* special_pointer = special.Pointer();
  Product& base_mutable = factory.Mutable();
  SpecialProduct& special_mutable = special.Mutable();
  Observe(factory.Copyable());
  Observe(special.Copyable());
  Consume(factory.Movable());
  Consume(special.Movable());
}
