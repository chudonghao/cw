struct Base {
  virtual { func Read(this &copy Base) i32; }
}
struct Derived : Base {
  virtual { override func Read(this &copy Derived) i32; }
}

func Read(this &copy Base) i32 { 1 }
func Read(this &copy Derived) i32 { 2 }

ctor Base() {}
dtor Base() {}
ctor Derived() { this.Base := Base(); }
dtor Derived() {}

func Invoke(object &copy Base) i32 { object.Read() }

func main() i32 {
  var value := Derived();
  Invoke(value)
}
