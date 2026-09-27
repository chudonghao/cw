func Bump(value &mut i32) i32 {
  value = value + 1;
  value
}

func ReadBeforeCall(value &mut i32) i32 {
  value + Bump(value)
}

func CompareBeforeCall(value &mut i32) bool {
  value == Bump(value)
}

func DivideOnce(value &mut i32) i32 {
  Bump(value) / Bump(value)
}

func RemainderSideEffect(value &mut i32) i32 {
  Bump(value) % -1
}

func ConditionalDivisor(value &mut i32, flag bool) i32 {
  (flag ? Bump(value) : value) / (flag ? -1 : Bump(value))
}

func ShortCircuitDivision(flag bool, left i32, right i32) bool {
  flag && left / right > 0
}

func DiscardAndPass(value &mut i32) i32 {
  Bump(value) + 1;
  Consume(Bump(value) * 2)
}

func Consume(value i32) i32 {
  value
}
