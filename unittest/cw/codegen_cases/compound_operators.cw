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
func Syntax(value &mut Value) i32 { value += Change(value) }
func Explicit(value &mut Value) i32 { operator+=(value, Change(value)) }
func ReferenceResult(left &mut Value, right &mut Value) { (left -= right).number += 3; }
func Calls(value &mut Value) {
  value /= 1; value %= 3; value &= 7; value |= 1; value ^= 2;
  value *= 5;
  (value >>= -1).number += 1;
}
}

func Qualified(value &mut Api::Value) i32 { ::Api::operator+=(value, Api::Change(value)) }
func Indirect(value &mut Api::Value) i32 {
  var operation *func (Api::Value, i32) i32 := &Api::operator+=;
  operation(value, Api::Change(value))
}
func UnmaskedCount(value &mut Api::Value, count i64) i64 { Api::operator<<=(value, count) }
