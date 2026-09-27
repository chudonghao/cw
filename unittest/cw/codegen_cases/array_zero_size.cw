func Forward(value &mut [0] i32) &mut [0] i32 { value }

func Assign(source &mut [0] i32, target &mut [0] i32) {
  Forward(target) = Forward(source);
}

func Index(value &mut usize) usize {
  value = value + value;
  value - value
}

func Nested(value &mut usize) {
  var values := [2] [0] i32 { {}, {} };
  var copied := values[Index(value)];
  values[Index(value)] = [0] i32 {};
}

func Large(source &copy [18446744073709551615] [0] i32) {
  var copied := source;
}
