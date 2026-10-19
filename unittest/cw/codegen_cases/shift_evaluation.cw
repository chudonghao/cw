func Bump(value &mut i32) i32 {
  value = value + 1;
  value
}

func LeftBeforeCall(value &mut i32) i32 { value << Bump(value) }
func RightBeforeCall(value &mut i32) i32 { value >> Bump(value) }
func BothCalls(value &mut i32) i32 { Bump(value) << Bump(value) }
func ZeroLeft(value &mut i32) i32 { 0 << Bump(value) }
func ZeroCount(value &mut i32) i32 { Bump(value) >> (Bump(value) * 32) }
