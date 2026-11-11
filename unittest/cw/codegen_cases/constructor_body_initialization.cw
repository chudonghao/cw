struct Base {
  virtual { func Read(this &copy Base) i32; }
}
func Read(this &copy Base) i32 { 1 }
ctor Base(value i32) {}
dtor Base() {}
struct Counter : Base {
  virtual { override func Read(this &copy Counter) i32; }
  limit i32;
}
func Read(this &copy Counter) i32 { 2 }
ctor Counter(start i32, skip_first bool) {
  var first := start + 1;
  if skip_first {
    this.Base := Base(first);
  } else {
    this.Base := Base(start);
  }
  this.limit := first + 10;
}
ctor Counter(flag bool) {
  if flag {
    this := Counter(3, true);
  } else {
    this.Base := Base(3);
    this.limit := 4;
  }
}
dtor Counter() {}
struct Probe {
  virtual { func Read(this &copy Probe) i32; }
}
func Read(this &copy Probe) i32 { 5 }
ctor Probe(value i32) {}
// A path that does not delegate dispatches as Probe from the entry; the other path delegates.
ctor Probe(flag bool) {
  if flag {
    this := Probe(1);
  } else {
    var before := this.Read();
  }
}
dtor Probe() {}
