namespace Steps {
func Check() bool {
  var counter := Counter();
  counter.value = 3;
  var reference &mut Counter := ++counter;
  if &reference != &counter || counter.value != 4 { return false; }
  var old := counter++;
  if old.value != 4 || counter.value != 5 { return false; }
  reference = --counter;
  if &reference != &counter || counter.value != 4 { return false; }
  old = counter--;
  old.value == 4 && counter.value == 3
}
}
func main() i32 {
  if !Steps::Check() { return 1; }
  var counter := Steps::Counter();
  var old := ::Steps::operator++(counter, 7);
  if old.value != 0 || counter.value != 8 { return 2; }
  var prefix *func (&mut Steps::Counter) &mut Steps::Counter := &Steps::operator--;
  var postfix *func (&mut Steps::Counter, i32) Steps::Counter := &Steps::operator--;
  if &prefix(counter) != &counter || counter.value != 7 { return 3; }
  old = postfix(counter, 2);
  if old.value != 7 || counter.value != 4 { return 4; }
  0
}
