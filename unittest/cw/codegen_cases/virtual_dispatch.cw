struct Base {
  virtual {
    func Read(this &copy Base) i32;
    func Keep(this &copy Base) i32;
  }
}
struct Derived : Base {
  virtual { override func Read(this &copy Derived) i32; }
}
func Read(this &copy Base) i32 { 1 }
func Keep(this &copy Base) i32 { 5 }
func Read(this &copy Derived) i32 { 2 }
ctor Base() {}
dtor Base() {}
ctor Derived() { this.Base := Base(); }
dtor Derived() {}
func ReadBase(object &copy Base) i32 { object.Read() + Read(object) }
func Entry() i32 {
  var value := Derived();
  ReadBase(value) + value.Keep() + value.nonvirtual Read() + value.Base.nonvirtual Read()
}
