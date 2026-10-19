namespace Api {
trivial struct Value { number i32; }
import func operator++(value &mut Value) &mut Value;
import func operator++(value &mut Value, marker i32) Value;
import func operator--(value Value) i32;
import func operator--(value &move Value, marker i32);

func Prefix(value &mut Value) &mut Value { ++value }
func Postfix(value &mut Value) Value { value++ }
func ByValue(value Value) i32 { --value }
func Discard(value &mut Value) { (move value)--; }
func Locate(value &mut Value, count &mut i32) &mut Value { ++count; value }
func Once(value &mut Value, count &mut i32) Value { Locate(value, count)++ }
func Nested(value &mut Value) Value { (++value)++ }
}

func Explicit(value &mut Api::Value, marker i32) Api::Value { ::Api::operator++(value, marker) }
func Indirect(value &mut Api::Value, marker i32) Api::Value {
  var operation *func (&mut Api::Value, i32) Api::Value := &Api::operator++;
  operation(value, marker)
}
