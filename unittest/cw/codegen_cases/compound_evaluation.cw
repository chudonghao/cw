trivial struct Item { value i32; }

func Locate(value &mut i32, counter &mut i32) &mut i32 {
  counter += 1;
  value
}
func Change(value &mut i32, source &mut i32) &mut i32 {
  source = 9;
  value
}
func Capture(value &mut i32, source &mut i32) i32 { Change(value, source) += source }
func Once(value &mut i32, counter &mut i32) &mut i32 { Locate(value, counter) += (value = 2) }
func ReadAfterRight(value &mut i32) i32 { value += (value = 2) }
func Chain(value &mut i32) &mut i32 { (value += 2) *= 3 }
func RightAssociated(left &mut i32, right &mut i32) i32 { left += right *= 2 }
func Address(value &mut i32) *i32 { &(value += 2) }
func Field(value &mut Item) i32 { value.value += 3 }
func Element(value &mut [2] i32, index usize) i32 { value[index] += (value[index] = 2) }
func Conditional(first &mut i32, second &mut i32, choose bool) &mut i32 { (choose ? first : second) += 3 }
func Discard(value &mut i32) { value += 2; value <<= 32; }
