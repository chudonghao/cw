var order i32 := 0;
func Mark(value i32) i32 { order = order * 10 + value; order }

namespace A {
  var first i32 := Mark(1);
  func main(value i32) i32 { value }
}
namespace B { var second i32 := Mark(2); }
namespace A {
  var third i32 := Mark(3);
  var copied i32 := B::second;
}

func main() i32 {
  if order == 123 && A::first == 1 && B::second == 12 && A::third == 123 && A::copied == 12 {
    return 7;
  }
  1
}
