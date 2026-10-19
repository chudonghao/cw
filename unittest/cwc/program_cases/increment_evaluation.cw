var global i32 := 1;
var global_old i32 := global++;
var global_new i32 := ++global;

func Locate(value &mut i32, counter &mut i32) &mut i32 { ++counter; value }
func Pair(first i32, second i32) i32 { first * 10 + second }
func Prefix(value &mut i32) &mut i32 { ++value }
trivial struct Item { value i32; index usize; }

func main() i32 {
  if global != 3 || global_old != 1 || global_new != 3 { return 1; }
  var value i32 := 1;
  var result := value++ + value;
  if result != 3 || value != 2 { return 2; }
  value = 1;
  result = ++value + value++;
  if result != 4 || value != 3 { return 3; }
  value = 1;
  value = value++;
  if value != 1 { return 4; }
  result = Pair(value++, value);
  if result != 12 || value != 2 { return 5; }
  var counter i32 := 0;
  var reference &mut i32 := ++Locate(value, counter);
  if value != 3 || counter != 1 || &reference != &value { return 6; }
  var old := Locate(value, counter)--;
  if old != 3 || value != 2 || counter != 2 { return 7; }
  var address := &(--Locate(value, counter));
  if address != &value || value != 1 || counter != 3 { return 8; }
  ++reference;
  if value != 2 || &reference != &value { return 9; }
  (*address)--;
  if value != 1 { return 10; }
  ++(++value);
  if value != 3 { return 11; }
  old = (--value)++;
  if old != 2 || value != 3 { return 12; }
  (++Locate(value, counter)) = 5;
  if value != 5 || counter != 4 { return 13; }
  value = 1;
  result = ++value += value++;
  if result != 4 || value != 4 { return 14; }
  ++Locate(value, counter);
  Locate(value, counter)++;
  --Locate(value, counter);
  Locate(value, counter)--;
  if value != 4 || counter != 8 { return 15; }

  var second i32 := 10;
  old = (true ? Locate(value, counter) : Locate(second, counter))++;
  if old != 4 || value != 5 || second != 10 || counter != 9 { return 16; }
  var selected &mut i32 := --(false ? Locate(value, counter) : Locate(second, counter));
  if &selected != &second || second != 9 || counter != 10 { return 17; }
  false && Locate(value, counter)++ == 5;
  true || ++Locate(value, counter) == 5;
  if value != 5 || counter != 10 { return 18; }
  if !(true && Locate(value, counter)++ == 5) { return 19; }
  if value != 6 || counter != 11 { return 20; }
  if !(false || --Locate(value, counter) == 5) { return 21; }
  if value != 5 || counter != 12 { return 22; }

  var item := Item();
  var zero := item.index;
  var data := [2] i32 { 7, 9 };
  var index := zero;
  old = data[index++]++;
  if old != 7 || data[zero] != 8 || index == zero { return 23; }
  if data[index] != 9 { return 24; }
  old = data[--index]--;
  if old != 8 || data[zero] != 7 || index != zero { return 25; }
  item.value = 5;
  if item.value++ != 5 || --item.value != 5 { return 26; }
  var bound &mut i32 := ++Prefix(value);
  if &bound != &value || value != 7 { return 27; }
  var snapshot := value++;
  value = 100;
  if snapshot != 7 || bound != 100 { return 28; }
  value = 1;
  old = Locate(value, value)++;
  if old != 2 || value != 3 { return 29; }
  0
}
