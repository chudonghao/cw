trivial struct Empty {}

trivial struct Aligned { values [0] i64; }

trivial struct Wrapper {
  empty Empty;
  aligned Aligned;
  repeated [2] Empty;
}

trivial struct Mixed {
  head u8;
  aligned Aligned;
  tail u8;
  empty Empty;
}

func Zero(index usize) {
  var object := Wrapper();
  var copied := object;
  copied = object;
  var many := [2] Empty { Empty(), Empty() };
  var reference &mut Empty := many[index];
}

func Store(value &mut Mixed) { value.tail = 1; }

func Forward(value &mut Aligned, counter &mut i32) &mut Aligned {
  counter = counter + 1;
  value
}

func Assign(source &mut Aligned, target &mut Aligned, counter &mut i32) {
  Forward(target, counter) = Forward(source, counter);
}

func Large(source &copy [18446744073709551615] Aligned) {
  var copied := source;
}
