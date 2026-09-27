func Equal(left f32, right f32) bool {
  left == right
}

func NotEqual(left f64, right f64) bool {
  left != right
}

func Less(left f32, right f32) bool {
  left < right
}

func LessEqual(left f64, right f64) bool {
  left <= right
}

func Greater(left f32, right f32) bool {
  left > right
}

func GreaterEqual(left f64, right f64) bool {
  left >= right
}

func MixedLess(left i32, right f64) bool {
  left < right
}

func NaNEqual() bool {
  (0.0 / 0.0) == 1.0
}

func NaNNotEqual() bool {
  (0.0 / 0.0) != 1.0
}

func NaNLess() bool {
  (0.0 / 0.0) < 1.0
}

func NaNLessEqual() bool {
  (0.0 / 0.0) <= 1.0
}

func NaNGreater() bool {
  (0.0 / 0.0) > 1.0
}

func NaNGreaterEqual() bool {
  (0.0 / 0.0) >= 1.0
}

func SignedZerosEqual() bool {
  0.0f == -0.0f
}
