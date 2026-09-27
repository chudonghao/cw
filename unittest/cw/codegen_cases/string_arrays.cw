func Copy(index usize) u8 {
  var text := "abc";
  text[index] = 'x';
  text[index] + "abc"[index]
}

func Assign(target &mut [3] u8) &mut [3] u8 { target = "def" }

func Empty() {
  var text := "";
  text = "";
  "";
}
