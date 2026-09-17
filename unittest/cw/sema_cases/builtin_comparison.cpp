void BuiltinComparison(signed char small, long long wide, float single, long offset, unsigned long size, bool flag) {
  auto integer_order = small < wide;
  auto float_order = wide >= single;
  auto character_order = 'a' > 'b';
  auto size_order = offset <= size;
  auto numeric_equal = small == wide;
  auto bool_equal = flag != false;
  auto integer_literals = 1 < 2;
  auto mixed_literal = 1 < 2.0;
}
