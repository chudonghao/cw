func ConditionalValue(flag bool, other bool, left i32, right i32) i32 {
  flag ? (other ? left : 7) : (other ? 11 : right)
}
