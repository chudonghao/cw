trivial struct Sizes { signed_value isize; unsigned_value usize; }

func main() i32 {
  var byte i8 := 127;
  if byte++ != 127 || byte != -128 { return 1; }
  if byte-- != -128 || byte != 127 { return 2; }
  if ++byte != -128 || --byte != 127 { return 3; }
  var unsigned_byte u8 := 255;
  if unsigned_byte++ != 255 || unsigned_byte != 0 { return 4; }
  if unsigned_byte-- != 0 || unsigned_byte != 255 { return 5; }
  var short i16 := 32767;
  if ++short != -32768 || --short != 32767 { return 6; }
  var unsigned_short u16 := 65535;
  if ++unsigned_short != 0 || --unsigned_short != 65535 { return 7; }
  var integer i32 := 2147483647;
  if ++integer != -2147483648 || --integer != 2147483647 { return 8; }
  var unsigned_integer u32 := 4294967295;
  if ++unsigned_integer != 0 || --unsigned_integer != 4294967295 { return 9; }
  var long i64 := 9223372036854775807;
  if ++long != -9223372036854775808 || --long != 9223372036854775807 { return 10; }
  var unsigned_long u64 := 18446744073709551615;
  if ++unsigned_long != 0 || --unsigned_long != 18446744073709551615 { return 11; }

  var sizes := Sizes();
  var signed_zero := sizes.signed_value;
  var unsigned_zero := sizes.unsigned_value;
  var unsigned_max := ~unsigned_zero;
  if sizes.unsigned_value-- != unsigned_zero || sizes.unsigned_value != unsigned_max { return 12; }
  if ++sizes.unsigned_value != unsigned_zero { return 13; }
  var signed_min := ++sizes.signed_value << 63;
  var signed_max := ~signed_min;
  sizes.signed_value = signed_max;
  if ++sizes.signed_value != signed_min || --sizes.signed_value != signed_max { return 14; }
  sizes.signed_value = signed_zero;
  if sizes.signed_value++ != signed_zero || --sizes.signed_value != signed_zero { return 15; }

  var single f32 := 1.5;
  if single++ != 1.5 || single != 2.5 { return 16; }
  if --single != 1.5 || single-- != 1.5 || single != 0.5 { return 17; }
  if ++single != 1.5 { return 18; }
  single = 16777216.0;
  if single++ != 16777216.0 || single != 16777216.0 { return 19; }
  if --single != 16777215.0 { return 20; }
  single = -0.0;
  var zero_before := single++;
  if 1.0 / zero_before != -1.0 / 0.0 || single != 1.0 { return 21; }
  var double f64 := 1.5;
  if double++ != 1.5 || --double != 1.5 { return 22; }
  if double-- != 1.5 || ++double != 1.5 { return 23; }
  double = 9007199254740992.0;
  if double++ != 9007199254740992.0 || double != 9007199254740992.0 { return 24; }
  if --double != 9007199254740991.0 { return 25; }
  double = 1.0 / 0.0;
  if ++double != 1.0 / 0.0 || double-- != 1.0 / 0.0 || double != 1.0 / 0.0 { return 26; }
  double = 0.0 / 0.0;
  var old := double++;
  if old == old || double == double { return 27; }
  --double;
  if double == double { return 28; }
  0
}
