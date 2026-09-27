trivial struct Root { number i32; }
trivial struct Base : Root { tag u8; }
trivial struct Derived : Base { own u8; }

func Make(seed i32) Base {
  var value Base := {
    value.Root.number := seed;
    value.tag := 9;
  }
  value
}

func Form(seed i32) Derived {
  var value Derived := {
    value.Base := Make(seed);
    value.own := 7;
  }
  value
}

func Assign(target &mut Derived, source &copy Base) u8 {
  var base &mut Base := target;
  base = source;
  target.own
}

func Copy(source &copy [2] Derived) [2] Derived { source }

func Default() Derived {
  var value Derived := {
    value.Base := Base();
    value.own := 7;
  }
  value
}
