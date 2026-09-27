func Bump(value &mut f32) f64 {
  value = value + 1.0f;
  value
}

func ReadBeforeBump(value &mut f32) f64 {
  value + Bump(value)
}

func Pair(first f64, second f64) f64 {
  first + second
}

func ArgumentOrder(value &mut f32) f64 {
  Pair(value, Bump(value))
}

func Choose(flag bool, left f32, right f64) f64 {
  flag ? left : right
}

func Sum(limit i32) f64 {
  var index i32 := 0;
  var sum f64 := 0.0;
  while index < limit {
    sum = sum + index;
    index = index + 1;
  }
  sum
}

func Select(flag bool, left &mut f32, right &mut f32) &mut f32 {
  flag ? left : right
}

func WriteChosen(flag bool, left &mut f32, right &mut f32, value f64) {
  Select(flag, left, right) = value;
}
