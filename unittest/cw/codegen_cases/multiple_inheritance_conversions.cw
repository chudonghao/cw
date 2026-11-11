trivial struct Small { a i32; }
trivial struct Wide { b i64; }
trivial struct Pair : Small, Wide { c i32; }

// Wide is at offset eight. A pointer conversion keeps null; a zero offset needs no check.
func WideReference(pair &mut Pair) &mut Wide { pair }
func WidePointer(pair *Pair) *Wide { pair }
func SmallPointer(pair *Pair) *Small { pair }

// Point occurs twice in Twice; a base path names one of them.
trivial struct Point { x i32; }
trivial struct Mark { m i32; }
trivial struct First : Point {}
trivial struct Second : Point, Mark {}
trivial struct Twice : First, Second {}
func MarkPointer(twice *Twice) *Mark { twice }
func SecondPoint(twice &mut Twice) &mut Point { twice.Second }
func AssignPoint(twice &mut Twice, source &copy Point) { twice.Second.Point = source; }

// Construction initializes each base in place, including the one at a nonzero offset.
import struct Left { l i32; }
import ctor Left(value i32);
import dtor Left();
import struct Right { r i64; }
import ctor Right(value i64);
import dtor Right();
struct Join : Left, Right {}
ctor Join() {
  this.Left := Left(1);
  this.Right := Right(2);
}
dtor Join() {}
