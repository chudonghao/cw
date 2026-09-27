struct Item { value i32; }
ctor Item(value i32) { this.value := value; }
dtor Item() {}
func Target(address *Item) *Item { address }
func Argument(value i32) i32 { value }

func ConstructAt(address *Item, value i32) *Item {
  ctor (Target(address)) Item(Argument(value))
}
func DestroyAt(address *const Item) {
  dtor (address) Item();
}
func Manual(address *Item) {
  ctor (Target(address)) Item(Argument(1));
  dtor (Target(address)) Item();
}
