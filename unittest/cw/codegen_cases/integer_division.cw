func Divide(dividend i32, divisor i32) i32 {
  dividend / divisor
}

func Remainder(dividend i32, divisor i32) i32 {
  dividend % divisor
}

func DivideByNegativeOne(value i32) i32 {
  value / -1
}

func RemainderByNegativeOne(value i32) i32 {
  value % -1
}

func MinimumQuotient() i32 {
  -2147483648 / -1
}

func MinimumRemainder() i32 {
  -2147483648 % -1
}

func SignedQuotients() i32 {
  (-7 / 3) * 100 + (7 / -3) * 10 + (-7 / -3)
}

func SignedRemainders() i32 {
  (-7 % 3) * 100 + (7 % -3) * 10 + (-7 % -3)
}
