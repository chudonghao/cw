void NumericArithmetic(signed char signed8, unsigned char unsigned8, short signed16,
                       int signed32, long long signed64, float single, double wide,
                       long offset, unsigned long size) {
  auto same_small = signed8 + signed8;
  auto mixed_integer = unsigned8 + signed16;
  auto characters = 'a' + 'b';
  auto mixed_float = signed32 + single;
  auto wider_float = single * wide;
  auto literal_float = 1.0f + 2.0;
  auto integer_difference = signed32 - signed32;
  auto integer_quotient = signed32 / signed32;
  auto integer_remainder = signed32 % signed32;
  auto float_quotient = wide / single;
  auto sizes = size + offset;
  auto nested = 1 + 2 + signed64;
}
