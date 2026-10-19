namespace Api {
struct Bits {
  int value;
};

int operator~(const Bits& value) { return ~value.value; }
int operator&(const Bits& left, const Bits& right) { return left.value & right.value; }
int operator|(const Bits& left, const Bits& right) { return left.value | right.value; }
int operator^(const Bits& left, const Bits& right) { return left.value ^ right.value; }

// Inputs keep the signed sums representable in this C++ reference.
int Expressions(const Bits& left, const Bits& right) {
  return ~left + (left & right) + (left | right) + (left ^ right);
}
}  // namespace Api

int Explicit(const Api::Bits& left, const Api::Bits& right) {
  return Api::operator~(left) + Api::operator&(left, right) + ::Api::operator|(left, right) +
         ::Api::operator^(left, right);
}

int Indirect(const Api::Bits& left, const Api::Bits& right) {
  int (*invert)(const Api::Bits&) = &Api::operator~;
  int (*both)(const Api::Bits&, const Api::Bits&) = &Api::operator&;
  int (*either)(const Api::Bits&, const Api::Bits&) = &::Api::operator|;
  int (*different)(const Api::Bits&, const Api::Bits&) = &::Api::operator^;
  return invert(left) + both(left, right) + either(left, right) + different(left, right);
}
