trivial struct Root { value i32; }
trivial struct Middle : Root { value i16; }
trivial struct Leaf : Middle { Root i8; }

func Select(value &mut Leaf) &mut Root { value }
func Pointer(value *Leaf) *const Root { value }
func Null() *Root {
  var value *Leaf := null;
  value
}

func Explicit(value *Leaf) i32 { value->Middle.Root.value }
func Hidden(value &copy Leaf) i8 { value.Root }
func Nearest(value &copy Leaf) i16 { value.value }
