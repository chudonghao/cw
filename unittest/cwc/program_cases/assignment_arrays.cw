var trace i64 := 0;
trivial struct Indices { zero usize; one usize; }
struct Base { value i32; }
ctor Base(value i32) { this.value := value; }
ctor Base(source &copy Base) { this.value := source.value; }
dtor Base() {}
struct Item : Base {}
ctor Item(value i32) { this.Base := Base(value); }
ctor Item(source &copy Item) { this.Base := source.Base; trace = trace * 10 + 2; }
ctor Item(source &move Item) { this.Base := source.Base; trace = trace * 10 + 3; }
dtor Item() { trace = trace * 10 + 4; }
struct Receipt {}
ctor Receipt() {}
dtor Receipt() { trace = trace * 10 + 6; }
func operator=(target &mut Base, source Item) Receipt {
  target.value = source.value;
  trace = trace * 10 + 5;
  Receipt()
}
func Source(source &copy [2] Item) &copy [2] Item { trace = trace * 10 + 8; source }
func Target(target &mut [2] Item) &mut [2] Item { trace = trace * 10 + 9; target }
func MutatingTarget(target &mut [2] Item, source &mut [2] Item, index usize) &mut [2] Item {
  source[index].value = 11;
  Target(target)
}
func Make() [2] Item { trace = trace * 10 + 8; [2] Item { Item(8), Item(9) } }
func Check() bool {
  var indices := Indices();
  ++indices.one;
  var target := [2] Item { Item(0), Item(0) };
  var source := [2] Item { Item(7), Item(8) };
  trace = 0;
  var result &mut [2] Item := Target(target) = Source(source);
  if &result != &target || trace != 8925642564 || target[indices.zero].value != 7 || target[indices.one].value != 8 {
    return false;
  }
  trace = 0;
  MutatingTarget(target, source, indices.zero) = Source(source);
  if trace != 8925642564 || target[indices.zero].value != 11 { return false; }
  trace = 0;
  var selected bool := false;
  selected ? (target = source) : target;
  if trace != 0 { return false; }
  selected = true;
  selected ? (target = source) : target;
  if trace != 25642564 { return false; }
  trace = 0;
  target = move source;
  if trace != 35643564 { return false; }
  trace = 0;
  Target(target) = Make();
  if trace != 893564356444 || target[indices.zero].value != 8 || target[indices.one].value != 9 { return false; }
  var nested_target := [1] [2] Item { { Item(0), Item(0) } };
  var nested_source := [1] [2] Item { { Item(2), Item(3) } };
  trace = 0;
  nested_target = nested_source;
  if trace != 25642564 || nested_target[indices.zero][indices.one].value != 3 { return false; }
  true
}
namespace ByValue {
func operator=(target Item, source &copy Base) i32 {
  target.value = source.value;
  trace = trace * 10 + 5;
  7
}
func Check() bool {
  var indices := Indices();
  ++indices.one;
  var target := [2] Item { Item(1), Item(2) };
  var source := [2] Item { Item(7), Item(8) };
  trace = 0;
  target = source;
  trace == 254254 && target[indices.zero].value == 1 && target[indices.one].value == 2
}
}
func ZeroSource(source &copy [2] [0] Item) &copy [2] [0] Item { trace = trace * 10 + 8; source }
func ZeroTarget(target &mut [2] [0] Item) &mut [2] [0] Item { trace = trace * 10 + 9; target }
func Zero() bool {
  var target := [2] [0] Item { {}, {} };
  var source := [2] [0] Item { {}, {} };
  trace = 0;
  ZeroTarget(target) = ZeroSource(source);
  trace == 89
}
func main() i32 {
  if !Check() { return 1; }
  if !ByValue::Check() { return 2; }
  if !Zero() { return 3; }
  0
}
