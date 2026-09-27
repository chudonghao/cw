trivial struct Number { value i32; }

func operator-(value &copy Number) i32 { -value.value }
func operator-(left &copy Number, right i16) i32 { left.value - right }

func Unary(value &copy Number) i32 { -value }
func Binary(value &copy Number, amount i8) i32 { value - amount }
func Explicit(value &copy Number, amount i16) i32 { operator -(value, amount) }
func Indirect(value &copy Number, amount i16) i32 {
  var operation *func (&copy Number, i16) i32 := &operator -;
  operation(value, amount)
}
