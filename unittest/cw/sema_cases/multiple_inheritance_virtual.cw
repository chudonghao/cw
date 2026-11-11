struct Node {
  virtual { abstract func Visit(this &copy Node) i32; }
}

ctor Node() {}

dtor Node() {}

struct Left : Node {
  virtual { override func Visit(this &copy Left) i32; }
}

func Visit(this &copy Left) i32 { 1 }

ctor Left() { this.Node := Node(); }

dtor Left() {}

struct Right : Node {}

ctor Right() { this.Node := Node(); }

dtor Right() {}

struct Partial : Left, Right {}

ctor Partial() {
  this.Left := Left();
  this.Right := Right();
}

dtor Partial() {}

struct Both : Left, Right {
  virtual { override func Visit(this &copy Both) i32; }
}

func Visit(this &copy Both) i32 { 2 }

ctor Both() {
  this.Left := Left();
  this.Right := Right();
}

dtor Both() {}

func MultipleInheritanceVirtual(both &copy Both) i32 {
  Visit(both)
}
