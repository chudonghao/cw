trivial struct Product {}

trivial struct SpecialProduct : Product {}

struct Factory {
  virtual {
    abstract func Pointer(this copy Factory) *Product;
    abstract func Mutable(this copy Factory) mut Product;
    abstract func Copyable(this copy Factory) copy Product;
    abstract func Movable(this copy Factory) move Product;
  }
}

struct SpecialFactory : Factory {
  virtual {
    override abstract func Pointer(this copy SpecialFactory) *SpecialProduct;
    override abstract func Mutable(this copy SpecialFactory) mut SpecialProduct;
    override abstract func Copyable(this copy SpecialFactory) copy SpecialProduct;
    override abstract func Movable(this copy SpecialFactory) move SpecialProduct;
  }
}

ctor Factory() {}

dtor Factory() {}

ctor SpecialFactory() {
  this.Factory := Factory();
}

dtor SpecialFactory() {}

func Observe(value copy Product) {}

func Observe(value copy SpecialProduct) {}

func Consume(value move Product) {}

func Consume(value move SpecialProduct) {}

func Use(factory copy Factory, special copy SpecialFactory) {
  var base_pointer *Product := factory.Pointer();
  var special_pointer *SpecialProduct := special.Pointer();
  var base_mutable mut Product := factory.Mutable();
  var special_mutable mut SpecialProduct := special.Mutable();

  Observe(factory.Copyable());
  Observe(special.Copyable());
  Consume(factory.Movable());
  Consume(special.Movable());
}
