func Other(value [3] i64, ignored i32) [3] i64 { value }

func Replace(callback &mut *func ([3] i64, i32) [3] i64) i32 {
  callback = &Other;
  0
}

func Invoke(callback &mut *func ([3] i64, i32) [3] i64, value &copy [3] i64) [3] i64 {
  callback(value, Replace(callback))
}
