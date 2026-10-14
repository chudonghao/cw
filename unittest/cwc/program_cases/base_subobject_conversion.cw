trivial struct Base { value i32; }
trivial struct Derived : Base { own i32; }

func Set(value &mut Base) { value.value = 19; }

func main() i32 {
  var object Derived := {
    object.Base := Base();
    object.own := 7;
  }
  Set(object);
  var pointer *Base := &object;
  var null_derived *Derived := null;
  var null_base *Base := null_derived;
  var result i32 := pointer->value;
  if null_base == null {
    result = result + 1;
  }
  result
}
