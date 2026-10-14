namespace lib {
  export trivial struct Element { value i32; }
}
export trivial struct Matrix {
  data [2 + 2] *const lib::Element;
  qualified const *lib::Element;
  nested *const *lib::Element;
  callbacks [1 + 1] *func(&copy lib::Element, *const u8) *lib::Element;
  slots virtual *func(&copy lib::Element) i32;
  zero [0] u8;
  flags bool;
  signed8 i8;
  signed16 i16;
  signed32 i32;
  signed64 i64;
  unsigned8 u8;
  unsigned16 u16;
  unsigned32 u32;
  unsigned64 u64;
  float32 f32;
  float64 f64;
  size isize;
  unsigned_size usize;
}
export func Mut(value &mut lib::Element) &mut lib::Element { value }
export func Copy(value &copy lib::Element) &copy lib::Element { value }
export func Move(value &move lib::Element) &move lib::Element { move value }
export func Callback(value *func(i32) void) *func(i32) void { value }
export func Slot(value virtual *func(&copy lib::Element) i32) virtual *func(&copy lib::Element) i32 { value }
export func Inspect(value &copy Matrix) {}
