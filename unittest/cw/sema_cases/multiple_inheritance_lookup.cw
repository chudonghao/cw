trivial struct Base {
  value i32;
}

trivial struct Left : Base {
  left i32;
}

trivial struct Right : Base {
  value i32;
}

trivial struct Pair : Left, Right {}

func MultipleInheritanceLookup(pair Pair) {
  pair.left;
  pair.Left.value;
  pair.Right.value;
  pair.Right.Base.value;
}
