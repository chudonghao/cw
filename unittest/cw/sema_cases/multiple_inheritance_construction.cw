struct Base {
  value i32;
}

ctor Base(value i32) { this.value := value; }

dtor Base() {}

struct Label {}

ctor Label() {}

dtor Label() {}

struct Counter : Base, Label {
  limit i32;
}

ctor Counter(start i32, skip_first bool) {
  var first := start + 1;
  if skip_first {
    this.Base := Base(first);
  } else {
    this.Base := Base(start);
  }
  this.Label := Label();
  this.limit := first;
}

ctor Counter(flag bool) {
  if flag {
    this := Counter(1, false);
  } else {
    this.Base := Base(2);
    this.Label := Label();
    this.limit := 3;
  }
}

dtor Counter() {}
