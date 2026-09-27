func IntegerArithmetic(left i32, right i32) i32 {
  (+left + -right) * (left - right)
}

func AddWrap() i32 {
  2147483647 + 1
}

func SubtractWrap() i32 {
  (-2147483647 - 1) - 1
}

func MultiplyWrap() i32 {
  65536 * 65536
}

func NegateMinimum() i32 {
  -(-2147483647 - 1)
}
