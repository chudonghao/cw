func Read() i32 { number }
func Advance() i32 {
  number = number + 1;
  number
}

var number i32 := 7;
var first i32, second i32 := Advance(), Advance();
var enabled bool, saved const i32 := {
  enabled := true;
  saved := Read();
}
var address *i32 := &number;
var action *func () i32 := &Read;
var text := "hi";
trivial struct Record { value i32; }
var record := Record();

func Update() i32 {
  *address = action();
  record.value = second;
  first + record.value
}
