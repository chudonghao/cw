import struct Left {
  virtual { func Name(this &copy Left) i32; }
  left i32;
}
import ctor Left();
import dtor Left();
import struct Tag {
  virtual { func Size(this &copy Tag) i32; }
}
import dtor Tag();
import struct Inner {
  virtual { abstract func Deep(this &copy Inner) i32; }
}
import dtor Inner();
// Tag is the primary base of Right, and Inner has a secondary vtable nested in Right's group.
import struct Right : Tag, Inner {
  virtual { func Name(this &copy Right) i32; }
  right i32;
}
import ctor Right();
import dtor Right();
import func Name(this &copy Right) i32;

// One override replaces Name in both bases. Size overrides a secondary base, so it also takes a
// new slot in the primary vtable. Deep stays abstract, so Both is abstract too.
struct Both : Left, Right {
  virtual {
    override func Name(this &copy Both) i32;
    override func Size(this &copy Both) i32;
  }
}
func Name(this &copy Both) i32 { 1 }
func Size(this &copy Both) i32 { 2 }
ctor Both() {
  this.Left := Left();
  this.Right := Right();
}
dtor Both() {}

// The vtable group of Child reuses the thunks of Both.
struct Child : Both {}
ctor Child() { this.Both := Both(); }
dtor Child() {}

func ReadDeep(both &copy Both) i32 { both.Deep() }
func ViaPointer(both &copy Both) i32 {
  var size virtual *func (&copy Tag) i32 := &Size;
  size(both)
}
func Direct(both &copy Both) i32 { both.Right.nonvirtual Name() }
