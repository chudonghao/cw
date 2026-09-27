func First(value &copy [2] i32, index usize) i32 { value[index] }

func Forward(value &mut [2] i32) &mut [2] i32 { value }

func ForwardMove(value &move [2] i32) &move [2] i32 { move value }

func ThroughPointer(value &mut [2] i32, index usize) i32 {
  var pointer := &value;
  var bound &mut [2] i32 := pointer->Forward();
  var callbacks [1] *func (&copy [2] i32, usize) i32 := [1] *func (&copy [2] i32, usize) i32 { &First };
  callbacks[index](bound, index) + ForwardMove(move bound).First(index)
}
