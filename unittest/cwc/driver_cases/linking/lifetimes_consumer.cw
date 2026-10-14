trivial struct Index { value usize; }
struct Derived : lifetime::Base { member lifetime::Base; items [2] lifetime::Base; }
ctor Derived() {
  this.Base := lifetime::Base();
  this.member := lifetime::Base();
  this.items := [2] lifetime::Base { lifetime::Base(8), lifetime::Base(9) };
}
dtor Derived() {}
var global := lifetime::Base(19);
var globals := [2] lifetime::Base { lifetime::Base(21), lifetime::Base(22) };
func Exercise() i32 {
  var initial := lifetime::Count();
  var full := lifetime::Base();
  var derived := Derived();
  var copied := derived.items;
  var index := Index();
  if lifetime::Count() != initial + 7 || full.value != 7 || derived.value != 7 ||
     derived.member.value != 7 || copied[index.value].value != 8 { return 1; }
  dtor (&full) lifetime::Base();
  ctor (&full) lifetime::Base(11);
  if lifetime::Count() != initial + 7 || full.value != 11 { return 2; }
  0
}
func main() i32 {
  var initial := lifetime::Count();
  var index := Index();
  if global.value != 19 || globals[index.value].value != 21 { return 4; }
  var result := Exercise();
  if result != 0 { return result; }
  if lifetime::Count() == initial { 0 } else { 3 }
}
