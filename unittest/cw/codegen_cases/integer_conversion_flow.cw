func Bump(value &mut i8) u32 {
  value = value + 1;
  value
}

func ReadBeforeBump(value &mut i8) u32 {
  value + Bump(value)
}

func Locate(value &mut u16) &mut u16 {
  value
}

func AssignConverted(value &mut u16, source i64) {
  Locate(value) = source;
}

func ReadWide(value &copy u64) u64 {
  value
}

func TemporaryWide() u64 {
  ReadWide(18446744073709551615)
}

func Choose(flag bool, left u8, right i16) i16 {
  flag ? left : right
}

func IntegerLoop(limit u8) u16 {
  var index u8 := 0;
  var total u16 := 0;
  var step u8 := 1;
  while index < limit {
    total = total + index;
    index = index + step;
  }
  total
}
