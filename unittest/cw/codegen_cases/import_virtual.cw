namespace api {
  import struct Base {
    virtual {
      func Read(this &copy Base) i32;
      func Keep(this &copy Base) i32;
      func Hidden(this &copy Base) i32;
    }
  }
  import ctor Base();
  import dtor Base();
  import func Keep(this &copy Base) i32;
}
export struct Derived : api::Base {
  virtual { override func Read(this &copy Derived) i32; }
}
func Read(this &copy Derived) i32 { 2 }
ctor Derived() { this.Base := api::Base(); }
export dtor Derived() {}
func Dispatch(value &copy api::Base) i32 { api::Read(value) }
func Direct(value &copy api::Base) i32 { nonvirtual api::Keep(value) }
func Address() *func(&copy api::Base) i32 { &api::Keep }
func Slot(value &copy api::Base) i32 {
  var callback virtual *func(&copy api::Base) i32 := &api::Hidden;
  callback(value)
}
func Use() i32 { var value := Derived(); Dispatch(value) }
