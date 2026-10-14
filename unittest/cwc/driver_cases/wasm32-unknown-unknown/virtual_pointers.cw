struct Item {
  virtual {
    func First(this &copy Item) i32;
  }
  value i32;
}
func First(this &copy Item) i32 { this.value }
ctor Item(value i32) { this.value := value; }
dtor Item() {}
func Identity(pointer virtual *func (&copy Item) i32) virtual *func (&copy Item) i32 { pointer }
func Invoke(item &copy Item) i32 {
  var pointer virtual *func (&copy Item) i32 := Identity(&First);
  pointer(item)
}
