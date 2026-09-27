trivial struct Value { number i64; }
trivial struct Empty {}

func operator+(left Value, right i64) i64 {
  left.number = left.number + right;
  left.number
}
func Change(value &mut Value) i64 { value.number = 9; 0 }
func Capture(value &mut Value) i64 { value + Change(value) }

func operator()(object &copy Value, value i64) i64 { object.number + value }
func Locate(value &mut Value, counter &mut i32) &mut Value {
  counter = counter + 1;
  value
}
func Invoke(value &mut Value, counter &mut i32) i64 {
  Locate(value, counter)(Change(value))
}

func operator!(value Empty) Empty { value }
func MakeEmpty(counter &mut i32) Empty { counter = counter + 1; Empty() }
func EmptyResult(counter &mut i32) { !MakeEmpty(counter); }
