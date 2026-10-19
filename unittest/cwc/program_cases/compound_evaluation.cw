func Locate(value &mut i32, counter &mut i32) &mut i32 {
  counter += 1;
  value
}
func Change(value &mut i32, source &mut i32) &mut i32 { source = 9; value }
func Index(index usize, counter &mut i32) usize { counter += 1; index }
trivial struct Item { value i32; index usize; }

func main() i32 {
  var value i32 := 1;
  value += (value = 2);
  if value != 4 { return 1; }
  var counter i32 := 0;
  var result &mut i32 := Locate(value, counter) += (value = 2);
  if counter != 1 || value != 4 || &result != &value { return 2; }
  result += 1;
  if value != 5 || counter != 1 { return 3; }
  value = 1;
  var source i32 := 2;
  Change(value, source) += source;
  if value != 3 || source != 9 { return 4; }
  var address := &(value += 2);
  if address != &value || value != 5 { return 5; }
  *address += 1;
  if value != 6 { return 6; }
  (value += 2) *= 3;
  if value != 24 { return 7; }
  (value -= 4) = 1;
  if value != 1 { return 8; }
  source = 3;
  value += source *= 2;
  if value != 7 || source != 6 { return 9; }
  var read := value += 3;
  if read != 10 || value != 10 { return 10; }
  var item := Item();
  item.value += (item.value = 2);
  if item.value != 4 { return 11; }
  var index := item.index;
  var array := [2] i32 { 1, 2 };
  array[index] += (array[index] = 2);
  if array[index] != 4 { return 12; }
  var selected &mut i32 := (true ? value : source) += 1;
  if &selected != &value || value != 11 || source != 6 { return 13; }
  (false ? value : source) <<= 1;
  if source != 12 || value != 11 { return 14; }
  (Locate(value, counter) += 1) += (source = 2);
  if value != 14 || source != 2 || counter != 2 { return 15; }
  value <<= 32;
  if value != 14 { return 16; }
  Change(value, value) += 2;
  if value != 11 { return 17; }
  array[Index(index, counter)] *= 2;
  if array[index] != 8 || counter != 3 { return 18; }
  (false ? Locate(value, counter) : Locate(source, counter)) += 1;
  if source != 3 || value != 11 || counter != 4 { return 19; }
  0
}
