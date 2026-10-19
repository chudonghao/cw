func ZeroInteger() i32 { i32() }
func ZeroFloat() f32 { f32() }
func ToSize(value i32) usize { usize(value) }
func FromSize(value usize) i16 { i16(value) }
func Same(value i32) i32 { i32(value) }
func FloatSize(value usize) f32 { f32(value) }
func SizeFloat(value f64) isize { isize(value) }
func NarrowFloat(value f64) f32 { f32(value) }
func WidenFloat(value f32) f64 { f64(value) }
func Advance(value &mut i32) i32 { i32(value++) }
func Discard(value &mut i32) { f64(value++); }
