struct Local : SpecialSource {}
ctor Local(target *SpecialProduct) { this.SpecialSource := SpecialSource(target); }
dtor Local() {}
struct Another : SpecialSource {}
ctor Another(target *SpecialProduct) { this.SpecialSource := SpecialSource(target); }
dtor Another() {}
func Check(source &copy Source, product *Product) bool {
  source.Pointer() == product && &source.Reference() == product
}
func Nullable(source &copy Source) bool { source.Pointer() == null }
func main() i32 {
  var product := SpecialProduct();
  var local := Local(&product);
  var another := Another(&product);
  var empty := Local(null);
  var callback *func(&copy SpecialSource) *SpecialProduct := &Pointer;
  if Check(local, &product.Product) && Check(another, &product.Product) && Nullable(empty) &&
     callback(local) == &product && nonvirtual Pointer(another) == &product && product.Tag() == 7 {
    0
  } else { 1 }
}
