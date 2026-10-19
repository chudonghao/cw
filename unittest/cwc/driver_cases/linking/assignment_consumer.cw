namespace Consumer {
func operator=(target &mut api::Box, source &copy api::Box) i32 {
  target.value = source.value + 1;
  42
}
func Check() bool {
  var target := api::Box(0);
  var source := api::Box(7);
  if (target = source) != 42 || target.value != 8 { return false; }
  var result &mut api::Box := api::operator=(target, 9);
  if &result != &target || target.value != 9 { return false; }
  var assign *func (&mut api::Box, &copy api::Box) void := &api::operator=;
  assign(target, source);
  target.value == 7
}
}
func main() i32 { Consumer::Check() ? 0 : 1 }
