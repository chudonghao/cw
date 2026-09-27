func CopyAndMove(source &copy [2] i32, index usize) i32 {
  var copied := source;
  var moved := move copied;
  moved = source;
  moved = moved;
  moved[index]
}

func Assign(target &mut [2] i32, source &copy [2] i32) &mut [2] i32 {
  target = source
}

func Chain(target &mut [2] i32, middle &mut [2] i32, source &copy [2] i32) {
  target = middle = source;
}
