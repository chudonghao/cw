int destroyed = 0;
struct Result {
  int value;
  explicit Result(int input) : value(input) {}
  ~Result() { destroyed = static_cast<int>(static_cast<unsigned int>(destroyed) + 1); }
};
namespace Api {
struct Value {
  int number;
};
int operator+=(Value left, int right) {
  return static_cast<int>(static_cast<unsigned int>(left.number) + static_cast<unsigned int>(right));
}
Value& operator-=(Value& left, Value& right) { return right; }
Result operator*=(Value& left, int right) { return Result(right); }
void operator/=(Value& left, int right) {
  left.number = right == -1 ? static_cast<int>(0U - static_cast<unsigned int>(left.number)) : left.number / right;
}
void operator%=(Value& left, int right) { left.number = right == -1 ? 0 : left.number % right; }
void operator&=(Value& left, int right) { left.number &= right; }
void operator|=(Value& left, int right) { left.number |= right; }
void operator^=(Value& left, int right) { left.number ^= right; }
long long operator<<=(Value& left, long long right) { return right; }
Value& operator>>=(Value& left, int right) { return left; }
int Change(Value& value) {
  value.number = 9;
  return 1;
}
int Syntax(Value& value) {
  int rhs = Change(value);
  Value lhs = value;
  return operator+=(lhs, rhs);
}
int Explicit(Value& value) {
  Value lhs = value;
  int rhs = Change(value);
  return operator+=(lhs, rhs);
}
void ReferenceResult(Value& left, Value& right) {
  int& target = (left -= right).number;
  target = static_cast<int>(static_cast<unsigned int>(target) + 3);
}
void Calls(Value& value) {
  value /= 1;
  value %= 3;
  value &= 7;
  value |= 1;
  value ^= 2;
  value *= 5;
  int& target = (value >>= -1).number;
  target = static_cast<int>(static_cast<unsigned int>(target) + 1);
}
}  // namespace Api
int Qualified(Api::Value& value) {
  Api::Value lhs = value;
  int rhs = Api::Change(value);
  return Api::operator+=(lhs, rhs);
}
int Indirect(Api::Value& value) {
  int (*operation)(Api::Value, int) = &Api::operator+=;
  Api::Value lhs = value;
  int rhs = Api::Change(value);
  return operation(lhs, rhs);
}
long long UnmaskedCount(Api::Value& value, long long count) { return Api::operator<<=(value, count); }
