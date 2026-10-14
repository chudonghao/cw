trivial struct Size { value isize; }
func main() i32 {
  var value i32 := 1;
  var fixed const i32 := 2;
  var native := Size();
  var wide i64 := 4;
  var callback *func(i64) i32 := &api::Read;
  var array := [4] i32 { 1, 2, 3, 4 };
  var item api::Item := { item.value := 5; }
  if callback(wide) == 20 && api::Read(native.value) == 30 && api::Apply(callback, wide) == 20 &&
     api::Pick(fixed) == 40 && api::Pick(value) == 50 && api::Pick(move value) == 60 &&
     api::Array(array) == 1 && api::读取(5) == 12 && api::operator+(item, 6) == 11 && api::main(7) == 10 {
    0
  } else { 1 }
}
