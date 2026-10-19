namespace Api {
struct Bits {
  int value;
};

long long operator<<(const Bits& left, long long count) { return count; }
Bits& operator>>(Bits& left, int count) { return left; }

long long Expressions(Bits& left, signed char count) {
  (left >> count).value = 7;
  return left << count;
}
}  // namespace Api

long long Explicit(Api::Bits& left, signed char count) {
  ::Api::operator>>(left, count).value = 7;
  return Api::operator<<(left, count);
}

long long Indirect(Api::Bits& left, signed char count) {
  long long (*shl)(const Api::Bits&, long long) = &Api::operator<<;
  Api::Bits& (*shr)(Api::Bits&, int) = &::Api::operator>>;
  shr(left, count).value = 7;
  return shl(left, count);
}
