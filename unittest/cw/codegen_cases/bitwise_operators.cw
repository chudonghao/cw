namespace Api {
trivial struct Bits { value i32; }

func operator~(value &copy Bits) i32 { ~value.value }
func operator&(left &copy Bits, right &copy Bits) i32 { left.value & right.value }
func operator|(left &copy Bits, right &copy Bits) i32 { left.value | right.value }
func operator^(left &copy Bits, right &copy Bits) i32 { left.value ^ right.value }

func Expressions(left &copy Bits, right &copy Bits) i32 {
  ~left + (left & right) + (left | right) + (left ^ right)
}
}

func Explicit(left &copy Api::Bits, right &copy Api::Bits) i32 {
  Api::operator~(left) + Api::operator&(left, right) +
      ::Api::operator|(left, right) + ::Api::operator^(left, right)
}

func Indirect(left &copy Api::Bits, right &copy Api::Bits) i32 {
  var invert *func (&copy Api::Bits) i32 := &Api::operator~;
  var both *func (&copy Api::Bits, &copy Api::Bits) i32 := &Api::operator&;
  var either *func (&copy Api::Bits, &copy Api::Bits) i32 := &::Api::operator|;
  var different *func (&copy Api::Bits, &copy Api::Bits) i32 := &::Api::operator^;
  invert(left) + both(left, right) + either(left, right) + different(left, right)
}
