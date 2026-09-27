trivial struct Empty {}
trivial struct Floats : Empty { x f32; y f32; }
trivial struct WithZero { x f32; zero [0] f32; }
trivial struct Pointer : Empty { value *i32; }
trivial struct Pointers { values [2] *i32; }

func FloatIdentity(value Floats) Floats { value }
func ZeroIdentity(value WithZero) WithZero { value }
func PointerIdentity(value Pointer) Pointer { value }
func PointersIdentity(value Pointers) Pointers { value }
func ArrayIdentity(value [2] *i32) [2] *i32 { value }
