// Calls through Right reach Both's override through a receiver-adjusting thunk.
struct Left {
  virtual { func Name(this &copy Left) i32; }
}
func Name(this &copy Left) i32 { 1 }
ctor Left() {}
dtor Left() {}
struct Right {
  virtual { func Size(this &copy Right) i32; }
}
func Size(this &copy Right) i32 { 2 }
ctor Right() {}
dtor Right() {}
struct Both : Left, Right {
  virtual { override func Size(this &copy Both) i32; }
}
func Size(this &copy Both) i32 { 3 }
ctor Both() {
  this.Left := Left();
  this.Right := Right();
}
dtor Both() {}

// Through Maker, the thunk adjusts the receiver to Factory and the result to Product.
trivial struct Tag { tag i32; }
trivial struct Product { value i32; }
trivial struct Special : Tag, Product {}
struct Maker {
  virtual { func Make(this &copy Maker) *Product; }
}
func Make(this &copy Maker) *Product { null }
ctor Maker() {}
dtor Maker() {}
struct Factory : Left, Maker {
  virtual { override func Make(this &copy Factory) *Special; }
}
func Make(this &copy Factory) *Special { null }
ctor Factory() {
  this.Left := Left();
  this.Maker := Maker();
}
dtor Factory() {}

// Only one base holds data, so the value is a single-element struct.
trivial struct Empty {}
trivial struct Value { value i32; }
trivial struct Single : Empty, Value {}
func PassSingle(value Single) Single { value }
