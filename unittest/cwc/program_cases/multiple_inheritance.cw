// Each constructor and destructor appends the result of a virtual call, so the trace records
// both the order of construction and destruction and the dispatch stage of every call.
var trace i64 := 0;

func Note(digit i32) { trace = trace * 10 + i64(digit); }

struct Tag { tag i32; }
ctor Tag() { this.tag := 5; }
dtor Tag() {}

struct Product { value i32; }
ctor Product(value i32) { this.value := value; }
dtor Product() {}

// The Product base follows the Tag base, at a nonzero offset.
struct Special : Tag, Product {}
ctor Special() {
  this.Tag := Tag();
  this.Product := Product(42);
}
dtor Special() {}

struct Left {
  virtual { func Name(this &copy Left) i32; }
  left i32;
}
func Name(this &copy Left) i32 { 1 }
ctor Left() {
  this.left := 10;
  Note(this.Name());
}
dtor Left() { Note(this.Name()); }

struct Right {
  virtual {
    func Kind(this &copy Right) i32;
    func Make(this &copy Right) *Product;
  }
  right i32;
}
func Kind(this &copy Right) i32 { 2 }
func Make(this &copy Right) *Product { null }
ctor Right() {
  this.right := 20;
  Note(this.Kind());
}
dtor Right() { Note(this.Kind()); }

// Left is the primary base. Calls through Right reach Both's overrides through thunks, which
// must adjust the receiver to read the fields, and adjust the covariant result.
struct Both : Left, Right {
  virtual {
    override func Name(this &copy Both) i32;
    override func Kind(this &copy Both) i32;
    override func Make(this &copy Both) *Special;
  }
  product *Special;
}
func Name(this &copy Both) i32 { this.left / 10 + 2 }
func Kind(this &copy Both) i32 { this.right / 5 }
func Make(this &copy Both) *Special { this.product }
ctor Both(product *Special) {
  this.Left := Left();
  this.Right := Right();
  // Both is not complete yet, so the Right base still dispatches to Right.
  Note(this.Right.Kind());
  this.product := product;
  Note(this.Right.Kind());
}
dtor Both() { Note(this.Right.Kind()); }

func ReadName(object &copy Left) i32 { object.Name() }
func ReadKind(object &copy Right) i32 { object.Kind() }
func MakeThrough(object &copy Right) *Product { object.Make() }

func Check() i32 {
  var special := Special();
  var both := Both(&special);
  var empty := Both(null);
  if ReadName(both) != 3 { return 1; }
  if ReadKind(both) != 4 { return 2; }
  if MakeThrough(both) != &special.Product || MakeThrough(both)->value != 42 { return 3; }
  if MakeThrough(empty) != null { return 4; }
  var right *Right := &both;
  if right != &both.Right || right->right != 20 { return 5; }
  var none *Both := null;
  var converted *Right := none;
  if converted != null { return 6; }
  var kind virtual *func (&copy Right) i32 := &Kind;
  if kind(both) != 4 || both.Right.nonvirtual Kind() != 2 { return 7; }
  0
}

// Inner has a secondary vtable nested in the group of Middle. After Outer stops dispatching,
// the watch calls back through Inner and must reach Middle's override, not Outer's.
struct Head {
  virtual { func Top(this &copy Head) i32; }
}
func Top(this &copy Head) i32 { 0 }
ctor Head() {}
dtor Head() {}
struct Inner {
  virtual { func Level(this &copy Inner) i32; }
}
func Level(this &copy Inner) i32 { 1 }
ctor Inner() {}
dtor Inner() {}
struct Middle : Head, Inner {
  virtual { override func Level(this &copy Middle) i32; }
}
func Level(this &copy Middle) i32 { 2 }
ctor Middle() {
  this.Head := Head();
  this.Inner := Inner();
}
dtor Middle() {}
struct Watch { target *const Inner; }
ctor Watch(target *const Inner) { this.target := target; }
dtor Watch() { Note(this.target->Level()); }
struct Outer : Left, Middle {
  virtual { override func Level(this &copy Outer) i32; }
  watch Watch;
}
func Level(this &copy Outer) i32 { 3 }
ctor Outer() {
  this.Left := Left();
  this.Middle := Middle();
  this.watch := Watch(&this.Middle.Inner);
}
dtor Outer() { Note(this.Middle.Inner.Level()); }

func CheckStop() i32 {
  trace = 0;
  { var outer := Outer(); }
  // Left's construction, Outer's body, the watch after Outer stops dispatching, and Left's
  // destruction.
  if trace != 1321 { return 9; }
  0
}

func main() i32 {
  trace = 0;
  var result := Check();
  if result != 0 { return result; }
  // Construction of both and empty, then their destruction in reverse order.
  if trace != 12241224421421 { return 8; }
  result = CheckStop();
  result
}
