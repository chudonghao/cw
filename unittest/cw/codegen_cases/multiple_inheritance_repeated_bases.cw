import struct A {
  virtual { func F(this &copy A) i32; }
  value i32;
}
import dtor A();
import func F(this &copy A) i32;
// B overrides F and C does not, so the two A subobjects of D have different final overriders.
import struct B : A {
  virtual { override func F(this &copy B) i32; }
}
import ctor B();
import dtor B();
import func F(this &copy B) i32;
import struct C : A {
  virtual { func G(this &copy C) i32; }
}
import ctor C();
import dtor C();

// In the secondary vtable of C, F stays A's implementation and G reaches D's override through
// a thunk.
struct D : B, C {
  virtual { override func G(this &copy D) i32; }
}
func G(this &copy D) i32 { 4 }
ctor D() {
  this.B := B();
  this.C := C();
}
dtor D() {}

func ReadThroughC(d &copy D) i32 { F(d.C) + G(d.C) }
