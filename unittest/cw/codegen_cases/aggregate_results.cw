trivial struct Value { number i32; }

func Make(value i32) var result Value { result.number := value; }
func Choose(flag bool, left i32, right i32) Value { flag ? Make(left) : Make(right) }
func Read(value &copy Value) i32 { value.number }
func Bind(value i32) i32 { Read(Make(value)) }
func Member(value i32) i32 { Make(value).number }
func Discard(flag bool, value i32) { flag ? Make(value) : Make(0); }

func Target(target &mut Value, source &mut i32) &mut Value {
  source = 99;
  target
}

func Assign(target &mut Value, source &mut i32) { Target(target, source) = Make(source); }

func Take(value Value) i32 { value.number }
func Receiver(value &copy Value) i32 { value.Take() }
func Pass(value i32) i32 { Take(Make(value)) }
func Local(value i32) Value { var object := Make(value); object }
