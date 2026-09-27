trivial struct Inner { value i16; }

trivial struct Outer {
  leading u8;
  inner Inner;
  items [2] Inner;
}

func Nested(value i16, index usize) i16 {
  var object Outer := {
    object.leading := 1;
    object.inner.value := value;
    object.items := [2] Inner { Inner(), object.inner };
  }
  object.items[index].value
}

func Array(source &copy [2] Outer, index usize) i16 {
  var copied := source;
  copied[index].items[index].value
}
