func NumericArithmetic(signed8 i8, unsigned8 u8, signed16 i16, signed32 i32, signed64 i64, single f32,
                       wide f64, offset isize, size usize) {
  var same_small := signed8 + signed8;
  var mixed_integer := unsigned8 + signed16;
  var characters := 'a' + 'b';
  var mixed_float := signed32 + single;
  var wider_float := single * wide;
  var literal_float := 1.0f + 2.0;
  var integer_difference := signed32 - signed32;
  var integer_quotient := signed32 / signed32;
  var integer_remainder := signed32 % signed32;
  var float_quotient := wide / single;
  var sizes := size + offset;
  var nested := 1 + 2 + signed64;
}
