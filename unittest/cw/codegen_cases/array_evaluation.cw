func Change(source &mut [2] i32, target &mut [2] i32, index usize) &mut [2] i32 {
  source[index] = 9;
  target
}

func Existing(source &mut [2] i32, target &mut [2] i32, index usize) {
  Change(source, target, index) = source;
}

func Formed(source &mut [2] i32, target &mut [2] i32, index usize) {
  Change(source, target, index) = [2] i32 { source[index], source[index] };
}

func Locate(value &mut [2] i32, index &mut usize, replacement usize) &mut [2] i32 {
  index = replacement;
  value
}

func Read(value &mut [2] i32, index &mut usize, replacement usize) i32 {
  Locate(value, index, replacement)[index]
}

func Next(value &mut i32) i32 {
  value = value + 1;
  value
}

func Elements(value &mut i32, index usize) i32 {
  var values := [2] i32 { Next(value), Next(value) };
  values[index]
}

func Discarded(flag bool, value &mut i32) {
  flag ? [2] i32 { Next(value), Next(value) } : [2] i32 { 0, Next(value) };
}
