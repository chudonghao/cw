struct Base {}
ctor Base() {}
ctor Base(source &move Base) {}
dtor Base() {}
func Make() Base { Base() }
struct Derived : Base {}
ctor Derived() { this.Base := (Base()); }
ctor Derived(value i32) { this.Base := Make(); }
ctor Derived(condition bool) { this.Base := condition ? Base() : Make(); }
dtor Derived() {}
