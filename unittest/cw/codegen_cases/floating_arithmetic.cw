func SingleArithmetic(left f32, right f32) f32 {
  (+left + -right) * (left - right) / right
}

func DoubleArithmetic(left f64, right f64) f64 {
  (+left + -right) * (left - right) / right
}

func MultiplyAdd(left f64, right f64, addend f64) f64 {
  left * right + addend
}

func Grouped(first f32, second f32, third f32) f32 {
  first + (second + third)
}

func PositiveInfinity() f64 {
  1.0 / 0.0
}

func NegativeInfinity() f32 {
  1.0f / -0.0f
}

func Overflow() f64 {
  1e308 * 10.0
}

func NegativeUnderflow() f64 {
  -1e-300 * 1e-300
}

func GradualUnderflow() f32 {
  1.1754943508222875e-38f * 0.5f
}

func RoundEachStep() f32 {
  (16777216.0f + 1.0f) - 16777216.0f
}
