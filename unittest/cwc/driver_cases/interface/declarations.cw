trivial struct Private { value i32; }
func Hidden() i32 { 99 }
var hidden i32 := 7;

export trivial struct Point { x i32; y i32; }
export struct Handle { value i32; }
export ctor Handle(value i32) { this.value := value; }
ctor Handle() { this.value := 0; }
export dtor Handle() {}
func Secret(this &copy Handle) i32 { this.value }
export func Read(this &copy Handle) i32 { this.value }
export func Add(left i32, right i32) var result i32 { result := left + right; }
export func Add(left i64, right i64) i64 { left + right }
export func operator+(left &copy Point, right &copy Point) var result Point {
  result.x := left.x + right.x;
  result.y := left.y + right.y;
}
export func operator()(this &copy Point) i32 { this.x }
export func operator~(value &copy Point) i32 { ~value.x }
export func operator&(left &copy Point, right &copy Point) i32 { left.x & right.x }
export func operator|(left &copy Point, right &copy Point) i32 { left.x | right.x }
export func operator^(left &copy Point, right &copy Point) i32 { left.x ^ right.x }
export func operator<<(left &copy Point, count i64) i64 { count }
export func operator>>(left &copy Point, count i32) i32 { count }
export func operator+=(left &mut Point, right i32) &mut Point { left.x += right; left }
export func operator-=(left &mut Point, right i32) &mut Point { left.x -= right; left }
export func operator*=(left &mut Point, right i32) &mut Point { left.x *= right; left }
export func operator/=(left &mut Point, right i32) &mut Point { left.x /= right; left }
export func operator%=(left &mut Point, right i32) &mut Point { left.x %= right; left }
export func operator&=(left &mut Point, right i32) &mut Point { left.x &= right; left }
export func operator|=(left &mut Point, right i32) &mut Point { left.x |= right; left }
export func operator^=(left &mut Point, right i32) &mut Point { left.x ^= right; left }
export func operator<<=(left &mut Point, right i32) &mut Point { left.x <<= right; left }
export func operator>>=(left &mut Point, right i32) &mut Point { left.x >>= right; left }
export func Flush() {}
