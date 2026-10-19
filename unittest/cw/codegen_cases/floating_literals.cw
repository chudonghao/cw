func SingleTenth() f32 {
  0.1f32
}

func DoubleTenth() f64 {
  0.1
}

func SingleSubnormal() f32 {
  1.401298464324817e-45f32
}

func DoubleSubnormal() f64 {
  5e-324
}

func Underflow() f64 {
  1e-400
}

func NegativeZero() f32 {
  -0.0f32
}

func NegatedZero() f64 {
  -(-0.0)
}

func WidenedSingle() f64 {
  0.1f32
}

func ExplicitDouble() f64 {
  .5e3f64
}

func DirectSingleRounding() f32 {
  1.000000059604644775390626f32
}

func DoubleNegativeZero() f64 {
  -0.f64
}
