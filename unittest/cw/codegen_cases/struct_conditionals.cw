trivial struct Value { number i32; }

func Choose(flag bool, left &mut Value, right &mut Value) &mut Value {
  flag ? left : right
}

func Form(flag bool, source &copy Value) i32 {
  var result := flag ? Value() : source;
  result.number
}

func Read(value &copy Value) i32 { value.number }

func Temporary() i32 { Read(Value()) }

func Discard(flag bool, source &copy Value) {
  flag ? Value() : source;
}
