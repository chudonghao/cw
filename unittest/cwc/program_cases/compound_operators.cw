var destroyed i32 := 0;
struct Result { value i32; }
ctor Result(value i32) { this.value := value; }
dtor Result() { destroyed += 1; }

namespace Api {
trivial struct Value { number i32; }
func operator+=(left Value, right i32) i32 { left.number + right }
func operator-=(left &mut Value, right &mut Value) &mut Value { right }
func operator*=(left &mut Value, right i32) Result { Result(right) }
func operator/=(left &mut Value, right i32) { left.number /= right; }
func operator%=(left &mut Value, right i32) { left.number %= right; }
func operator&=(left &mut Value, right i32) { left.number &= right; }
func operator|=(left &mut Value, right i32) { left.number |= right; }
func operator^=(left &mut Value, right i32) { left.number ^= right; }
func operator<<=(left &mut Value, right i64) i64 { right }
func operator>>=(left &mut Value, right i32) &mut Value { left }

func Change(value &mut Value) i32 { value.number = 9; 1 }
func Locate(value &mut Value, trace &mut i32) &mut Value { trace = trace * 10 + 1; value }
func Count(trace &mut i32) i32 { trace = trace * 10 + 2; 3 }
func Check() i32 {
  var left := Value();
  left.number = 2;
  if (left += Change(left)) != 10 || left.number != 9 { return 1; }
  left.number = 2;
  if operator+=(left, Change(left)) != 3 || left.number != 9 { return 2; }
  left.number = 2;
  var operation *func (Value, i32) i32 := &operator+=;
  if operation(left, Change(left)) != 3 || left.number != 9 { return 3; }
  var right := Value();
  right.number = 5;
  (left -= right).number += 3;
  if left.number != 9 || right.number != 8 { return 4; }
  var reference &mut Value := (left -= right) >>= -1;
  reference.number += 1;
  if left.number != 9 || right.number != 9 || &reference != &right { return 5; }
  left.number = 12;
  left /= 3; left %= 3; left &= 3; left |= 4; left ^= 2;
  if left.number != 7 { return 6; }
  left *= 5;
  if destroyed != 1 { return 7; }
  var count := (left *= 6).value;
  if count != 6 || destroyed != 2 { return 8; }
  if (left <<= -1) != -1 || (left <<= 64) != 64 { return 9; }
  var trace i32 := 0;
  Locate(left, trace) += Count(trace);
  if trace != 21 { return 10; }
  trace = 0;
  operator+=(Locate(left, trace), Count(trace));
  if trace != 12 { return 11; }
  0
}
}

namespace Lifetimes {
var trace i32 := 0;
struct Token { id i32; }
ctor Token(id i32) { this.id := id; trace = trace * 10 + id; }
ctor Token(other &copy Token) { this.id := other.id; trace = trace * 10 + this.id; }
dtor Token() { trace = trace * 10 + this.id; }
func operator+=(left Token, right Token) i32 { trace = trace * 10 + 9; left.id + right.id }
func Check() bool {
  var left := Token(1);
  trace = 0;
  var result := left += Token(2);
  if result != 3 || trace != 21912 { return false; }
  trace = 0;
  result = operator+=(left, Token(2));
  result == 3 && trace == 12921
}
}

func main() i32 {
  var status := Api::Check();
  if status != 0 { return status; }
  var value := Api::Value();
  value.number = 2;
  if ::Api::operator+=(value, Api::Change(value)) != 3 || value.number != 9 { return 12; }
  value.number = 2;
  var operation *func (Api::Value, i32) i32 := &Api::operator+=;
  if operation(value, Api::Change(value)) != 3 || value.number != 9 { return 13; }
  if Api::operator<<=(value, -1) != -1 { return 14; }
  if !Lifetimes::Check() { return 15; }
  0
}
