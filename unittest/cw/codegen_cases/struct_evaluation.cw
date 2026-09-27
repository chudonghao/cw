trivial struct Value { number i32; }

func Change(source &mut Value, target &mut Value) &mut Value {
  source.number = 9;
  target
}

func Existing(source &mut Value, target &mut Value) {
  Change(source, target) = source;
}

func Formed(source &mut Value, target &mut Value) {
  Change(source, target) = Value();
}
