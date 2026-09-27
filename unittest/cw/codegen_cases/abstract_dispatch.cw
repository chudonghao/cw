struct Base { virtual { abstract func Read(this &copy Base) i32; } }
func Read(this &copy Base) i32 { 9 }
ctor Base() {}
dtor Base() {}
struct Derived : Base { virtual { override func Read(this &copy Derived) i32; } }
func Read(this &copy Derived) i32 { 2 }
func Invoke(object &copy Base) i32 { object.Read() }
ctor Derived() {
  this.Base := Base();
  // This layer is already complete: successful dispatch must use Derived.
  Invoke(this);
}
dtor Derived() {}
func Check() i32 {
  var object := Derived();
  Invoke(object) + object.Base.nonvirtual Read()
}
