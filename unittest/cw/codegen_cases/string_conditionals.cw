func Choose(flag bool) &copy [3] u8 { flag ? "yes" : "no!" }

func ReadChoice(flag bool, index usize) u8 {
  var text := flag ? "yes" : "no!";
  text[index]
}

func WithValue(flag bool, index usize) u8 {
  var text := flag ? "yes" : [3] u8 { 'n', 'o', '!' };
  text[index]
}

func Touch(count &mut u32) &copy [3] u8 {
  count = count + 1;
  "no!"
}

func Discard(flag bool, count &mut u32) {
  flag ? "yes" : Touch(count);
}
