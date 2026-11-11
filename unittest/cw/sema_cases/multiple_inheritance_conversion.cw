trivial struct Base {
  value i32;
}

trivial struct Left : Base {}

trivial struct Right {}

trivial struct Pair : Left, Right {}

func Pick(object &copy Base) {}

func Pick(object &copy Left) {}

func MultipleInheritanceConversion(pair &mut Pair, pointer *Pair, left *Left) {
  var base &mut Base := pair;
  var right *Right := pointer;
  Pick(pair);
  var same := left == pointer;
}
