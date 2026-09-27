trivial struct Base { number i32; }
trivial struct Derived : Base { own i32; }

func Assign(source *func (&mut i32) &mut Derived,
            target *func (&mut i32) &mut Derived, counter &mut i32) {
  target(counter).Base = source(counter).Base;
}

func Convert(callback *func (&mut i32) *Derived, counter &mut i32) *Base { callback(counter) }
func Temporary(callback *func (&mut i32) Derived, counter &mut i32) i32 { callback(counter).number }
