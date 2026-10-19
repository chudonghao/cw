func Bump(value &mut i32) i32 {
  value = value + 1;
  value
}

func AndBeforeCall(value &mut i32) i32 { value & Bump(value) }

func OrBeforeCall(value &mut i32) i32 { value | Bump(value) }

func XorBeforeCall(value &mut i32) i32 { value ^ Bump(value) }

func InvertCall(value &mut i32) i32 { ~Bump(value) }

func BothCalls(value &mut i32) i32 { Bump(value) & Bump(value) }

func ZeroMask(value &mut i32) i32 { 0 & Bump(value) }

func AllOnesMask(value &mut i32) i32 { -1 | Bump(value) }
