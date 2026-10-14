namespace A {
  struct T { value i32; }
  ctor T(value i32) { this.value := value; }
  ctor T(other &copy T) { this.value := other.value + 1; }
  ctor T(other &move T) { this.value := other.value + 2; }
  dtor T() {}
  func operator=(to &mut T, from &copy T) { to.value = from.value + 3; }
  func operator=(to &mut T, from &move T) { to.value = from.value + 4; }
  func Read(value &copy T) i32 { value.value }
  func operator+(left &copy T, right &copy T) i32 { left.value + right.value }
  func operator()(value &copy T) i32 { value.value }
  func Invoke(value &copy T) i32 { value.Read() + value() }

  struct Base { virtual { func VirtualRead(this &copy Base) i32; } }
  ctor Base() {} dtor Base() {}
  func VirtualRead(this &copy Base) i32 { 1 }
}
namespace B {
  trivial struct T { value i32; }
  func Read(value &copy T) i32 { value.value + 20 }
  struct Derived : A::Base { virtual { override func VirtualRead(this &copy Derived) i32; } }
  ctor Derived() { this.Base := A::Base(); } dtor Derived() {}
  func VirtualRead(this &copy Derived) i32 { 2 }
}
func main() i32 {
  var source := A::T(5);
  var copied A::T := source;
  var moved A::T := move source;
  if copied.value != 6 || moved.value != 7 { return 1; }
  copied = source;
  moved = move source;
  if copied.value != 8 || moved.value != 9 { return 2; }
  if A::operator+(copied, moved) != 17 || A::Invoke(source) != 10 { return 3; }
  var other := B::T();
  other.value = 5;
  var derived := B::Derived();
  var pointer *func(&copy A::T) i32 := &A::Read;
  if B::Read(other) != 25 || pointer(source) != 5 { return 4; }
  if A::VirtualRead(derived) != 2 || nonvirtual A::VirtualRead(derived) != 1 { return 5; }
  42
}
