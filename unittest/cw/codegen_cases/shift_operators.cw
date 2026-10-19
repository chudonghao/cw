namespace Api {
trivial struct Bits { value i32; }

func operator<<(left &copy Bits, count i64) i64 { count }
func operator>>(left &mut Bits, count i32) &mut Bits { left }

func Expressions(left &mut Bits, count i8) i64 {
  (left >> count).value = 7;
  left << count
}
}

func Explicit(left &mut Api::Bits, count i8) i64 {
  ::Api::operator>>(left, count).value = 7;
  Api::operator<<(left, count)
}

func Indirect(left &mut Api::Bits, count i8) i64 {
  var shl *func (&copy Api::Bits, i64) i64 := &Api::operator<<;
  var shr *func (&mut Api::Bits, i32) &mut Api::Bits := &::Api::operator>>;
  shr(left, count).value = 7;
  shl(left, count)
}
