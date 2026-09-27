struct Item { value i32; }
ctor Item(value i32) { this.value := value; }
dtor Item() {}
func Inspect(value &copy Item) {}

func Make() Item { Item(1) }
func Named() var result Item {
  result := Item(2);
  Inspect(result);
}
func Select(flag bool) Item { flag ? Make() : Named() }
func Results() {
  var value Item := { Make() }
  Inspect(value);
  Named();
}
