namespace api {
  export struct Base {
    virtual {
      abstract func Read(this &copy Base) i32;
      func Keep(this &copy Base) i32;
    }
    marker i32;
  }
  export ctor Base(value i32) { this.marker := value; }
  export dtor Base() {}
  func Keep(this &copy Base) i32 { this.marker }
  export struct Derived : Base {
    virtual { override func Read(this &copy Derived) i32; }
  }
  export ctor Derived(value i32) { this.Base := Base(value); }
  export dtor Derived() {}
  export func Read(this &copy Derived) i32 { this.marker }
  export struct Abstract : Base {
    virtual { override abstract func Keep(this &copy Abstract) i32; }
  }
  ctor Abstract(value i32) { this.Base := Base(value); }
  export dtor Abstract() {}
}
