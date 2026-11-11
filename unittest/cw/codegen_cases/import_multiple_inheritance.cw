namespace api {
  import struct First {
    virtual { func One(this &copy First) i32; }
  }
  import dtor First();
  import struct Second {
    virtual { func Two(this &copy Second) i32; }
    value i32;
  }
  import dtor Second();
  // Pair overrides Two of its secondary base; the implementation is defined elsewhere.
  import struct Pair : First, Second {
    virtual { override func Two(this &copy Pair) i32; }
  }
  import ctor Pair();
  import dtor Pair();
}
// The vtable group of Derived refers to the imported implementation of Two, and its secondary
// vtable adjusts the receiver in a local thunk.
export struct Derived : api::Pair {
  virtual { override func One(this &copy Derived) i32; }
}
func One(this &copy Derived) i32 { 1 }
ctor Derived() { this.Pair := api::Pair(); }
export dtor Derived() {}
func CallSecond(pair &copy api::Pair) i32 { api::Two(pair.Second) }
