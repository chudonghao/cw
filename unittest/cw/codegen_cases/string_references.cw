func Borrow() &copy [3] u8 { "abc" }

func Pointer() *const [3] u8 { &"abc" }

func Read(value &copy [3] u8, index usize) u8 { value[index] }

func Use(index usize) u8 {
  var callback *func (&copy [3] u8, usize) u8 := &Read;
  Read(Borrow(), index) + callback(*Pointer(), index) + "abc".Read(index)
}
