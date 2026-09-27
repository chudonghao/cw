struct Item {
  virtual {
    func First(this &copy Item) i32;
    func Second(this &copy Item) i32;
  }
  value i32;
}
func First(this &copy Item) i32 { this.value }
func Second(this &copy Item) i32 { this.value + 10 }
ctor Item(value i32) { this.value := value; }
dtor Item() {}
func Identity(pointer virtual *func (&copy Item) i32) virtual *func (&copy Item) i32 { pointer }
func Replace(pointer &mut virtual *func (&copy Item) i32, item &copy Item) &copy Item {
  pointer = &Second;
  item
}
func Invoke(item &copy Item) i32 {
  var pointer virtual *func (&copy Item) i32 := Identity(&First);
  var copied := pointer;
  var direct *func (&copy Item) i32 := &First;
  var result := pointer(Replace(pointer, item));
  result + pointer(item) + copied(item) + direct(item)
}
func Entry() i32 {
  var first := Item(3);
  var second := Item(7);
  Invoke(first) + Invoke(second)
}
func Empty() bool {
  var pointer virtual *func (&copy Item) i32 := null;
  pointer == null
}
func Present() bool {
  var pointer virtual *func (&copy Item) i32 := &First;
  null != pointer
}
