func InvertByte(value u8) u8 { ~value }
func InvertSignedByte(value i8) i8 { ~value }
func InvertBeforeWidening(value u8) i32 { ~value & 256 }
func Mixed(left i8, right u16) u16 { left & right }
func Wide(left u64, right u64) u64 { (~left & right) | (left ^ right) }
func FoldedWrap() i32 { (2147483647 + 1) & 0 }
func FoldedConversion() u64 { -1 & 18446744073709551615 }

trivial struct Bits { value i32; }
func operator~(value &copy Bits) i32 { ~value.value }
func operator&(left &copy Bits, right &copy Bits) i32 { left.value & right.value }
func operator|(left &copy Bits, right &copy Bits) i32 { left.value | right.value }
func operator^(left &copy Bits, right &copy Bits) i32 { left.value ^ right.value }

func main() i32 {
  if InvertByte('a') != 158 { return 1; }
  if InvertSignedByte(~'a') != 97 { return 2; }
  if InvertBeforeWidening('a' ^ 'a') != 0 { return 3; }
  var negative i8 := -1;
  var mask u16 := 65535;
  if Mixed(negative, mask) != 65535 { return 4; }
  if Wide(9223372036854775808, 18446744073709551615) != 9223372036854775807 { return 5; }
  if ~0x80000000 != -2147483649 { return 6; }
  if ~18446744073709551615 != 0 { return 7; }
  if FoldedWrap() != 0 { return 8; }
  if FoldedConversion() != 18446744073709551615 { return 9; }

  var left := Bits();
  var right := Bits();
  left.value = 6;
  right.value = 3;
  if ~left != -7 { return 10; }
  if (left & right) != 2 { return 11; }
  if (left | right) != 7 { return 12; }
  if (left ^ right) != 5 { return 13; }
  if operator~(left) != -7 || operator&(left, right) != 2 ||
      operator|(left, right) != 7 || operator^(left, right) != 5 { return 14; }

  var invert *func (&copy Bits) i32 := &operator~;
  var both *func (&copy Bits, &copy Bits) i32 := &operator&;
  var either *func (&copy Bits, &copy Bits) i32 := &operator|;
  var different *func (&copy Bits, &copy Bits) i32 := &operator^;
  if invert(left) != -7 || both(left, right) != 2 ||
      either(left, right) != 7 || different(left, right) != 5 { return 15; }
  var address *Bits := &left;
  if address->value != 6 { return 16; }
  0
}
