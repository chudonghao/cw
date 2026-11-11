trivial struct Empty {}
trivial struct Small { a i32; }
trivial struct Wide { b i64; }
// The empty base shares offset zero with Small.
trivial struct Pair : Small, Wide, Empty { c u8; }

// Empty base subobjects of the same type need distinct addresses.
trivial struct EmptyA : Empty {}
trivial struct EmptyB : Empty {}
trivial struct EmptyC : Empty {}
trivial struct Spread : EmptyA, EmptyB, EmptyC { d u8; }

// The dynamic base is primary and precedes the base declared before it.
import struct Count { a i32; }
import dtor Count();
import struct Shape {
  virtual { func Area(this &copy Shape) i32; }
  e i32;
}
import dtor Shape();
import struct Placed : Count, Shape { f i32; }
import dtor Placed();

// Padded is not standard-layout, so Byte reuses its tail padding.
trivial struct Head { g i32; }
trivial struct Padded : Head { h u8; }
trivial struct Byte { i u8; }
trivial struct Packed : Padded, Byte { j u8; }

// A base reached through two paths forms two subobjects.
trivial struct Point { x i32; }
trivial struct First : Point {}
trivial struct Second : Point {}
trivial struct Twice : First, Second { y i32; }

func ReadPair(pair &copy Pair) i64 { i64(pair.a) + pair.b + i64(pair.c) }
func ThirdEmpty(spread &mut Spread) *Empty { &spread.EmptyC.Empty }
func ReadSpread(spread &copy Spread) u8 { spread.d }
func ReadPlaced(placed &copy Placed) i32 { placed.a + placed.e + placed.f }
func ReadPacked(packed &copy Packed) u8 { packed.h + packed.i + packed.j }
func ReadTwice(twice &copy Twice) i32 { twice.First.x + twice.Second.x + twice.y }
