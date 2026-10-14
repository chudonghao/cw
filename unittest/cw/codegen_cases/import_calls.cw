namespace api {
  import struct Box { value i32; }
  import ctor Box(value i32);
  import ctor Box(source &copy Box);
  import ctor Box(source &move Box);
  import dtor Box();
  import func operator=(this &mut Box, source &copy Box);
  import func operator=(this &mut Box, source &move Box);
  import func Read(this &copy Box) i32;
  import func Make() Box;
  import func Flush();
}
var global := api::Make();
func Use() i32 {
  var first := api::Box(1);
  var second := first;
  first = second;
  second = move first;
  var third := move second;
  api::Flush();
  api::Read(third)
}
