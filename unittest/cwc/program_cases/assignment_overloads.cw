namespace Model {
struct Box { value i32; }
ctor Box(value i32) { this.value := value; }
dtor Box() {}
}
namespace Operations {
var calls i32 := 0;
func operator=(target &mut Model::Box, source &mut Model::Box) i32 {
  ++calls; target.value = source.value + 1; 1
}
func operator=(target &mut Model::Box, source &copy Model::Box) i32 {
  ++calls; target.value = source.value + 2; 2
}
func operator=(target &mut Model::Box, source &move Model::Box) i32 {
  ++calls; target.value = source.value + 3; 3
}
func Check() bool {
  var target := Model::Box(0);
  var source := Model::Box(7);
  if (target = source) != 1 || target.value != 8 { return false; }
  var readonly const Model::Box := Model::Box(7);
  if (target = readonly) != 2 || target.value != 9 { return false; }
  if (target = move source) != 3 || target.value != 10 { return false; }
  calls == 3
}
}
namespace Values {
trivial struct Value { number i32; }
var trace i32 := 0;
func operator=(target &mut Value, source i32) &mut Value { target.number = source; target }
func operator=(target &copy Value, source bool) i32 { source ? target.number : 0 }
func operator=(target Value, source *i32) i32 { target.number += *source; target.number }
func operator=(target &mut Value, source *func (i32) i32) i32 { source(target.number) }
func Read(value i32) i32 { value + 1 }
func Read(value bool) bool { !value }
func Source(source &mut Value) &mut Value { trace = trace * 10 + 1; source }
func Target(target &mut Value, source &mut Value) &mut Value {
  trace = trace * 10 + 2; source.number = 9; target
}
func Check() bool {
  var target := Value();
  var source := Value();
  source.number = 7;
  var result &mut Value := Target(target, source) = Source(source).number;
  if &result != &target || target.number != 7 || source.number != 9 || trace != 12 { return false; }
  source.number = 4;
  trace = 0;
  result = Target(target, source) = Source(source);
  if target.number != 9 || trace != 12 { return false; }
  var readonly const Value := target;
  if (readonly = true) != 9 || (Value() = false) != 0 { return false; }
  var increment i32 := 3;
  if (readonly = &increment) != 12 || target.number != 9 { return false; }
  if (target = &Read) != 10 { return false; }
  true
}
}
namespace Intrinsic {
trivial struct Root { value i32; }
trivial struct Base : Root { tag u8; }
trivial struct Derived : Base { own u8; }
func Make() Derived {
  var value := Derived();
  value.value = 23; value.tag = '\x04'; value.own = '\x08';
  value
}
func Check() bool {
  var target := Derived();
  target.own = '\x07';
  var base &mut Base := target;
  var result &mut Base := base = Make();
  if &result != &base || target.value != 23 || target.tag != 4 || target.own != 7 { return false; }
  var source := Make();
  var full &mut Derived := target = move source;
  &full == &target && target.own == 8
}
namespace Move {
var calls i32 := 0;
func operator=(target &mut Base, source &move Derived) i32 { ++calls; 42 }
func Check() bool {
  var target := Derived();
  var source := Make();
  var result &mut Derived := target = move source;
  &result == &target && calls == 0 && target.value == 23 && target.own == 8
}
}
namespace Readonly {
var calls i32 := 0;
func operator=(target &copy Base, source &copy Derived) i32 { ++calls; source.value }
func Check() bool {
  var target := Derived();
  var source const Derived := Make();
  var result &mut Derived := target = source;
  if &result != &target || calls != 0 || target.value != 23 { return false; }
  var readonly const Derived := target;
  if (readonly = source) != 23 || calls != 1 { return false; }
  true
}
}
}
func main() i32 {
  if !Operations::Check() { return 1; }
  if !Values::Check() { return 2; }
  if !Intrinsic::Check() { return 3; }
  if !Intrinsic::Move::Check() { return 4; }
  if !Intrinsic::Readonly::Check() { return 5; }
  0
}
