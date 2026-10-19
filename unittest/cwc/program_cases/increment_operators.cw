namespace Numbers {
trivial struct Counter { value i32; }
var calls i32 := 0;
var locations i32 := 0;
func operator++(counter &mut Counter) &mut Counter {
  ++calls; ++counter.value; counter
}
func operator++(counter &mut Counter, marker i32) Counter {
  ++calls;
  var old := counter;
  counter.value += marker + 1;
  old
}
func operator--(counter &mut Counter) &mut Counter {
  ++calls; --counter.value; counter
}
func operator--(counter &mut Counter, marker i32) Counter {
  ++calls;
  var old := counter;
  counter.value -= marker + 1;
  old
}
func Locate(counter &mut Counter) &mut Counter { ++locations; counter }
var global := Counter();
var global_old := global++;
var global_new := ++global;
func Pair(first Counter, second Counter) i32 { first.value * 10 + second.value }
func Check() i32 {
  if global.value != 2 || global_old.value != 0 || global_new.value != 2 { return 15; }
  calls = 0;
  var counter := Counter();
  counter.value = 3;
  var reference &mut Counter := ++Locate(counter);
  if counter.value != 4 || &reference != &counter || calls != 1 || locations != 1 { return 1; }
  var old := Locate(counter)++;
  if old.value != 4 || counter.value != 5 || calls != 2 || locations != 2 { return 2; }
  old = Locate(counter)--;
  if old.value != 5 || counter.value != 4 || calls != 3 || locations != 3 { return 3; }
  var address := &(--Locate(counter));
  if address != &counter || counter.value != 3 || calls != 4 || locations != 4 { return 4; }
  ++Locate(counter); Locate(counter)++; --Locate(counter); Locate(counter)--;
  if counter.value != 3 || calls != 8 || locations != 8 { return 5; }
  (++counter).value = 20;
  if counter.value != 20 { return 6; }
  old = (++counter)++;
  if old.value != 21 || counter.value != 22 { return 7; }
  counter.value = 2;
  if Pair(counter++, counter++) != 23 || counter.value != 4 { return 8; }
  if (counter++).value * 10 + (counter++).value != 45 || counter.value != 6 { return 9; }
  old = operator++(counter, 7);
  if old.value != 6 || counter.value != 14 { return 10; }
  var operation *func (&mut Counter, i32) Counter := &operator--;
  old = operation(counter, 2);
  if old.value != 14 || counter.value != 11 { return 11; }
  var before_calls := calls;
  false && (++Locate(counter)).value == 1;
  true || (Locate(counter)++).value == 1;
  if calls != before_calls || locations != 8 { return 12; }
  0
}
}

namespace Results {
trivial struct Value { number i32; }
var target i32 := 0;
func operator++(value &copy Value) i32 { value.number + 2 }
func operator++(value &copy Value, marker i32) { target += marker + 1; }
func operator--(value Value) Value { value.number += 3; value }
func operator--(value &mut Value, marker i32) &mut i32 { target }
func Check() bool {
  var value := Value();
  value.number = 4;
  var fixed const Value := value;
  if ++fixed != 6 || ++Value() != 2 { return false; }
  fixed++; Value()++;
  if target != 2 { return false; }
  var result := --fixed;
  if result.number != 7 || fixed.number != 4 { return false; }
  var reference &mut i32 := value--;
  reference = 9;
  &reference == &target && target == 9 && value.number == 4
}
}

namespace Lifetimes {
var trace i32 := 0;
struct Token { id i32; }
ctor Token(id i32) { this.id := id; trace = trace * 10 + 1; }
ctor Token(other &copy Token) { this.id := other.id; trace = trace * 10 + 2; }
ctor Token(other &move Token) { this.id := other.id; trace = trace * 10 + 3; }
dtor Token() { trace = trace * 10 + 4; }
func operator++(value Token, marker i32) i32 { trace = trace * 10 + 5; value.id }
func operator--(value &copy Token) Token { Token(value.id + 1) }
func Check() bool {
  var value := Token(7);
  trace = 0;
  if value++ != 7 || trace != 25 { return false; }
  if trace != 254 { return false; }
  trace = 0;
  if (move value)++ != 7 || trace != 35 { return false; }
  if trace != 354 { return false; }
  trace = 0;
  if Token(7)++ != 7 || trace != 15 { return false; }
  if trace != 154 { return false; }
  trace = 0;
  --value;
  if trace != 14 { return false; }
  trace = 0;
  var result := --value;
  result.id == 8 && trace == 1
}
}

func main() i32 {
  var status := Numbers::Check();
  if status != 0 { return status; }
  if !Results::Check() { return 13; }
  if !Lifetimes::Check() { return 14; }
  0
}
