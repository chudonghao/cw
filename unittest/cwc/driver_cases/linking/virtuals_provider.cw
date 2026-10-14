export struct Product { value i32; }
export ctor Product() { this.value := 42; }
export dtor Product() {}
export struct SpecialProduct : Product {
  virtual { func Tag(this &copy SpecialProduct) i32; }
}
func Tag(this &copy SpecialProduct) i32 { 7 }
export ctor SpecialProduct() { this.Product := Product(); }
export dtor SpecialProduct() {}
export struct Source {
  virtual {
    abstract func Pointer(this &copy Source) *Product;
    abstract func Reference(this &copy Source) &copy Product;
  }
}
ctor Source() {}
export dtor Source() {}
export struct SpecialSource : Source {
  virtual {
    override func Pointer(this &copy SpecialSource) *SpecialProduct;
    override func Reference(this &copy SpecialSource) &copy SpecialProduct;
  }
  target *SpecialProduct;
}
export func Pointer(this &copy SpecialSource) *SpecialProduct { this.target }
func Reference(this &copy SpecialSource) &copy SpecialProduct { *this.target }
export ctor SpecialSource(target *SpecialProduct) { this.Source := Source(); this.target := target; }
export dtor SpecialSource() {}
