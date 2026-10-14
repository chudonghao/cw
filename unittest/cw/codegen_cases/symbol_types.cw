// Distinct semantic types keep their identity when lowered to the same LLVM type.
namespace api {
  import struct Owner { virtual { func Read(this &copy Owner) i32; } }
  import dtor Owner();
  import func Scalar(value isize) i32;
  import func Scalar(value i64) i32;
  import func Reference(value &copy i32) i32;
  import func Reference(value &mut i32) i32;
  import func Reference(value &move i32) i32;
  import func Qualified(value *const *i32) i32;
  import func Qualified(value **const i32) i32;
  import func Array(value &copy [2 + 2] i32) i32;
  import func Callback(value *func(i32) i32) i32;
  import func Callback(value virtual *func(&copy Owner) i32) i32;
  import func main(value i32) i32;
  import func 读取(value i32) i32;
}
import func main() i32;
