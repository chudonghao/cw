struct Value { number i32; }
ctor Value(number i32) { this.number := number; }
dtor Value() {}

func operator=(target &mut Value, source &copy Value) {
  target.number = source.number;
}
func Target(target &mut Value, source &mut Value, token &copy Value) &mut Value {
  source.number = token.number;
  target
}
func Source(source &copy Value) Value { Value(source.number) }

func Infix() i32 {
  var source := Value(1);
  var target := Value(0);
  Target(target, source, Value(9)) = Source(source);
  target.number
}
func Explicit() i32 {
  var source := Value(1);
  var target := Value(0);
  operator =(Target(target, source, Value(9)), Source(source));
  target.number
}
