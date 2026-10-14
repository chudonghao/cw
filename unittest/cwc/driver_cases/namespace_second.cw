namespace Shared {
  trivial struct T { number i32; }
  var next i32 := order + 1;
  func Run() i32 {
    var value := T();
    value.number = 40;
    Read(value) + next
  }
}
