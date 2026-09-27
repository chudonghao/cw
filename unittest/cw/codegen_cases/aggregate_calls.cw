func Make(value i8, counter &mut i32) [3] i64 {
  counter = counter + 1;
  [3] i64 { value, 2, 3 }
}

func Forward(value i8, counter &mut i32) [3] i64 { Make(value, counter) }

func Indirect(callback *func (i8, &mut i32) [3] i64, value i8, counter &mut i32) [3] i64 {
  callback(value, counter)
}

func Discard(value i8, counter &mut i32) { Make(value, counter); }
func Element(value i8, counter &mut i32, index usize) i64 { Make(value, counter)[index] }

func Reference(value &mut [3] i64) &mut [3] i64 { value }
func CopyReference(value &mut [3] i64) [3] i64 { Reference(value) }

func Identity(value [3] i64) [3] i64 { value }
func Nested(value i8, counter &mut i32) [3] i64 { Identity(Make(value, counter)) }
