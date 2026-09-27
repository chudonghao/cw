struct Product { value i32; }
ctor Product() { this.value := 42; }
dtor Product() {}
struct SpecialProduct : Product {
  virtual { func Tag(this &copy SpecialProduct) i32; }
}
func Tag(this &copy SpecialProduct) i32 { 7 }
ctor SpecialProduct() { this.Product := Product(); }
dtor SpecialProduct() {}
// The result base has no vptr; the polymorphic derived result places it at offset eight.
struct Source {
  virtual {
    abstract func Pointer(this &copy Source) *Product;
    abstract func Reference(this &copy Source) &copy Product;
  }
}
struct SpecialSource : Source {
  virtual {
    override func Pointer(this &copy SpecialSource) *SpecialProduct;
    override func Reference(this &copy SpecialSource) &copy SpecialProduct;
  }
  target *SpecialProduct;
}
func Pointer(this &copy SpecialSource) *SpecialProduct { this.target }
func Reference(this &copy SpecialSource) &copy SpecialProduct { *this.target }
ctor Source() {}
dtor Source() {}
ctor SpecialSource(target *SpecialProduct) { this.Source := Source(); this.target := target; }
dtor SpecialSource() {}
func GetPointer(source &copy Source) *Product { source.Pointer() }
func GetReference(source &copy Source) &copy Product { source.Reference() }
func Check() bool {
  var product := SpecialProduct();
  var source := SpecialSource(&product);
  var empty := SpecialSource(null);
  GetPointer(source) == &product.Product && &GetReference(source) == &product.Product &&
      GetPointer(empty) == null && source.Pointer() == &product
}

func ConvertPointer(product *SpecialProduct) *Product { product }
func ConvertReference(product &copy SpecialProduct) &copy Product { product }
