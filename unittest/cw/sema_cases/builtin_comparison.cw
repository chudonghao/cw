func BuiltinComparison(small i8, wide i64, single f32, offset isize, size usize, flag bool) {
  var integer_order := small < wide;
  var float_order := wide >= single;
  var character_order := 'a' > 'b';
  var size_order := offset <= size;
  var numeric_equal := small == wide;
  var bool_equal := flag != false;
  var integer_literals := 1 < 2;
  var mixed_literal := 1 < 2.0;
}
