var trace i64 := 0;
func Mark(value i32) { trace = trace * 10 + value; }
func Flag() bool { true }
struct Item { value i32; }
ctor Item(value i32) { this.value := value; Mark(value); }
dtor Item() { Mark(-this.value); }
func Observe(value &copy Item) { Mark(value.value); }

var first Item, second Item := {
  var local := Item(1);
  if Flag() {
    first := Item(2);
  } else {
    first := Item(3);
  }
  Observe(Item(4));
  second := Item(5);
}
var pair := [2] Item { Item(6), Item(7) };
