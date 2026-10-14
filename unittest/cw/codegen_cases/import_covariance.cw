import struct Product { value i32; }
import dtor Product();
import struct SpecialProduct : Product {
  virtual { func Tag(this &copy SpecialProduct) i32; }
}
import dtor SpecialProduct();
import struct Source {
  virtual {
    abstract func Pointer(this &copy Source) *Product;
    abstract func Reference(this &copy Source) &copy Product;
  }
}
import dtor Source();
import struct SpecialSource : Source {
  virtual {
    override func Pointer(this &copy SpecialSource) *SpecialProduct;
    override func Reference(this &copy SpecialSource) &copy SpecialProduct;
  }
}
import ctor SpecialSource();
import dtor SpecialSource();
struct Local : SpecialSource {}
ctor Local() { this.SpecialSource := SpecialSource(); }
dtor Local() {}
func PointerCall(value &copy Source) *Product { value.Pointer() }
func ReferenceCall(value &copy Source) &copy Product { value.Reference() }
// Both local tables must reuse the same pointer/reference return-adjusting entries.
struct Another : SpecialSource {}
ctor Another() { this.SpecialSource := SpecialSource(); }
dtor Another() {}
