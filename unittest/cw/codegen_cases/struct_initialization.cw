trivial struct Padded {
  tag u8;
  number i32;
  enabled bool;
}

trivial struct Defaults {
  count i16;
  enabled bool;
  ratio f32;
  wide f64;
  pointer *i32;
  callback *func () i32;
  values [2] i32;
}

func Fields(number i32, enabled bool) bool {
  var value Padded := {
    value.tag := 1;
    value.number := number;
    value.enabled := enabled;
  }
  value.enabled
}

func Default() *i32 {
  var value := Defaults();
  value.pointer
}
