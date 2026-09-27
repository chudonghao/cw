trivial struct Number { value i32; }
trivial struct Big { values [3] i64; }

func operator+(value &mut Number) &mut i32 { value.value }
func operator-(value &move Number) &move Number { move value }
func operator+(left &copy Number, right &copy Number) var result Number {
  result.value := left.value + right.value;
}
func operator+(left &copy Big, right &copy Big) Big { left }
func operator!(value &mut Number) { value.value = 0; }

func Assign(value &mut Number) { +value = 7; !value; }
func Move(value &mut Number) &move Number { -(move value) }
func Small(left &copy Number, right &copy Number) i32 { (left + right).value }
func Large(left &copy Big, right &copy Big) Big { left + right }
func Discard(left &copy Big, right &copy Big) { left + right; }
