trivial struct Value { number i32; }

func CopyAndMove(source &copy Value) i32 {
  var copied := source;
  var moved := move copied;
  moved = source;
  moved = moved;
  moved.number
}

func Assign(target &mut Value, middle &mut Value, source &copy Value) &mut Value {
  target = middle = source
}
