struct Part {}
ctor Part() {}
dtor Part() {}
struct Base { value i32; }
ctor Base(value i32) { this.value := value; }
dtor Base() {}
struct Owner : Base { first Part; last [2] Part; }
ctor Owner() {
  this.Base := Base(1);
  this.first := Part();
  this.last := [2] Part { Part(), Part() };
}
dtor Owner() {
  var local := Part();
  return;
}
func Destroy() { var owner := Owner(); }
