func Observe() {}

func ConditionalExpression(condition bool, signed16 i16, signed32 i32, unsigned32 u32, single f32, wide f64) {
  var same_bool := condition ? true : false;
  var wider_integer := condition ? signed16 : signed32;
  var mixed_sign := condition ? signed32 : unsigned32;
  var mixed_float := condition ? signed16 : single;
  var wider_float := condition ? single : wide;

  condition ? Observe() : Observe();
}
