trivial struct Root { number i32; }
trivial struct Middle : Root { tag u8; }
trivial struct Leaf : Middle { extra u8; }
trivial struct Box { head u8; value Leaf; }

func Fields(number i32, tag u8, extra u8) i32 {
  var value Leaf := {
    value.Root.number := number;
    value.tag := tag;
    value.extra := extra;
  }
  value.number
}

func Extra(value &mut Leaf) *u8 { &value.extra }
func Element(values &copy [2] Leaf, index usize) i32 { values[index].number }
func Nested(value &mut Box) *u8 { &value.value.extra }
