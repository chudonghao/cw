import struct Left {
  virtual { func Read(this &copy Left) i32; }
}
import ctor Left();
import dtor Left();
import struct Right {
  virtual { func Size(this &copy Right) i32; }
}
import ctor Right();
import dtor Right();
// A watch can call back through the Right base when it is destroyed.
import struct Watch { target *const Right; }
import ctor Watch(target *const Right);
import dtor Watch();
import func Record(value i32);

struct Both : Left, Right {
  virtual {
    override func Read(this &copy Both) i32;
    override func Size(this &copy Both) i32;
  }
  watch Watch;
}
func Read(this &copy Both) i32 { 3 }
func Size(this &copy Both) i32 { 4 }
ctor Both() {
  this.Left := Left();
  this.Right := Right();
  // Both is not complete yet, so each base still dispatches in its own stage.
  Record(this.Left.Read() + this.Right.Size());
  this.watch := Watch(&this.Right);
  // After the last initialization, both bases dispatch to Both.
  Record(this.Left.Read() + this.Right.Size());
}
// The body still dispatches to Both. Both bases leave Both's dispatch before the watch is
// destroyed, and the bases are destroyed in reverse order.
dtor Both() { Record(this.Right.Size()); }
