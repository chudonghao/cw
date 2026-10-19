trivial struct Value { number i32; }
func operator=(target &mut Value, source i32) &mut Value {
  target.number = source;
  target
}
func operator=(target &copy Value, source bool) i32 { source ? target.number : 0 }
func operator=(target Value, source *i32) i32 { target.number + *source }
func Mutable(target &mut Value) &mut Value { target = 7 }
func Readonly(target &copy Value) i32 { target = true }
func Temporary() i32 { Value() = true }
func ByValue(target &copy Value, source *i32) i32 { target = source }

trivial struct Base { value i32; tag u8; }
trivial struct Derived : Base { own u8; }
func Slice(target &mut Base, source &copy Derived) &mut Base { target = source }
func Move(target &mut Derived, source &move Derived) &mut Derived { target = move source }
func operator=(target &mut Base, source &move Derived) i32 { 42 }
func MoveWins(target &mut Derived, source &move Derived) &mut Derived { target = move source }

struct Box { value i32; }
ctor Box(value i32) { this.value := value; }
dtor Box() {}
func operator=(target &mut Box, source &mut Box) i32 { target.value = source.value; 1 }
func operator=(target &mut Box, source &copy Box) bool { target.value = source.value; true }
func MutableSource(target &mut Box, source &mut Box) i32 { target = source }
func ConstSource(target &mut Box, source &copy Box) bool { target = source }
