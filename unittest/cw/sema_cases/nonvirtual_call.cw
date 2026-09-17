struct Base {
  virtual {
    func Draw(this copy Base);
    abstract func Measure(this copy Base);
  }
}

func Draw(this copy Base) {}

func Measure(this copy Base) {}

ctor Base() {}

dtor Base() {}

struct Derived : Base {
  virtual {
    override func Draw(this copy Derived);
  }
}

func Draw(this copy Derived) {}

ctor Derived() {
  this.Base := Base();
}

dtor Derived() {}

func Ordinary(value i32) i32 {
  return value;
}

func Use(base copy Base, derived copy Derived, pointer *const Base) i32 {
  base.Draw();
  base.nonvirtual Draw();
  nonvirtual Measure(base);
  pointer->nonvirtual Draw();

  derived.Draw();
  derived.nonvirtual Draw();
  derived.Base.nonvirtual Draw();

  return nonvirtual Ordinary(1);
}
