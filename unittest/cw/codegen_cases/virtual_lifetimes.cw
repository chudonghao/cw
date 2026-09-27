var trace i64 := 0;
struct Base { virtual { func Read(this &copy Base) i32; } }
func Read(this &copy Base) i32 { 1 }
func Record(object &copy Base) { trace = trace * 10 + object.Read(); }
ctor Base() {}
dtor Base() { Record(this); }
struct Watch { target *const Base; }
ctor Watch(target *const Base) { this.target := target; }
dtor Watch() { Record(*this.target); }
func Complete(watch &copy Watch) i32 { 0 }
struct Derived : Base {
  virtual { override func Read(this &copy Derived) i32; }
  watch Watch;
  value i32;
}
func Read(this &copy Derived) i32 { 2 }
ctor Derived(flag bool) {
  this.Base := Base();
  this.watch := Watch(&this.Base);
  if flag {
    var local := Watch(&this.Base);
    this.value := Complete(Watch(&this.Base));
    Record(this);
  } else {
    var local := Watch(&this.Base);
    this.value := Complete(Watch(&this.Base)) + 1;
    Record(this);
  }
}
ctor Derived() { this := Derived(true); Record(this); }
dtor Derived() {
  var local := Watch(&this.Base);
  Record(this);
  if this.value == 0 { return; }
}
var global := Derived(true);
func ReadTrace() i64 { trace }
func Entry(flag bool) i64 {
  trace = 0;
  { var value := Derived(flag); }
  trace
}
func Delegate() i64 {
  trace = 0;
  { var value := Derived(); }
  trace
}
