trivial struct Empty {}
trivial struct Other {}
// Every base is empty, so the value is not passed at all.
trivial struct Nothing : Empty, Other {}

// The floats of both bases and the field form one homogeneous aggregate.
trivial struct X { x f32; }
trivial struct Y { y f32; }
trivial struct Vector : X, Y { z f32; }

// Both bases hold only pointers, so the value is passed as pointers.
trivial struct Head { head *i32; }
trivial struct Tail { tail *i32; }
trivial struct Links : Head, Tail {}

// An empty base keeps the value from being passed as pointers.
trivial struct Marked : Head, Empty { tail *i32; }

func PassNothing(value Nothing) Nothing { value }
func PassVector(value Vector) Vector { value }
func PassLinks(value Links) Links { value }
func PassMarked(value Marked) Marked { value }
