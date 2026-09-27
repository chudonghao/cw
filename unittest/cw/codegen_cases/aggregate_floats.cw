trivial struct Inner { value f32; }
trivial struct Homogeneous { first Inner; rest [2] f32; }
trivial struct Mixed { real f32; integer i32; }
trivial struct Padded { real f32; empty [0] i64; }
trivial struct ZeroArray { real f64; empty [0] i64; }
trivial struct NestedZeroArray { real f32; empty [2][0] i32; }

func Nested(value Homogeneous) Homogeneous { value }
func Four(value [4] f64) [4] f64 { value }
func Five(value [5] f32) [5] f32 { value }
func Different(value Mixed) Mixed { value }
func WithPadding(value Padded) Padded { value }
func WithZeroArray(value ZeroArray) ZeroArray { value }
func WithNestedZeroArray(value NestedZeroArray) NestedZeroArray { value }
func Forward(value &copy Homogeneous) Homogeneous { Nested(value) }
func ForwardZeroArray(value &copy ZeroArray) ZeroArray { WithZeroArray(value) }
