func Choose(flag bool, left &mut [2] i32, right &mut [2] i32) &mut [2] i32 {
  flag ? left : right
}

func Value(flag bool, source &copy [2] i32, index usize) i32 {
  var values := flag ? source : [2] i32 { 7, 8 };
  values[index]
}

func Temporary(index usize) i32 {
  [2] i32 { 5, 7 }[index]
}
