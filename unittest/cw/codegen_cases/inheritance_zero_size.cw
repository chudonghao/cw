trivial struct Empty {}
trivial struct ZeroBase { values [0] i64; }
trivial struct ZeroDerived : ZeroBase { empty Empty; }
trivial struct Occupied : ZeroDerived { empty Empty; number i32; }

func Make(counter &mut i32) ZeroDerived {
  counter = counter + 1;
  ZeroDerived()
}
func Identity(value ZeroDerived) ZeroDerived { value }

func Form(counter &mut i32) Occupied {
  var value Occupied := {
    value.ZeroDerived := Make(counter);
    value.empty := Empty();
    value.number := 1;
  }
  value
}

func Same(value &mut Occupied) bool { &value.empty == &value.ZeroDerived.empty }
func Base(value &mut Occupied) *ZeroBase { &value.ZeroBase }
