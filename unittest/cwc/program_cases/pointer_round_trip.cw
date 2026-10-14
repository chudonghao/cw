func Write(pointer *i32, value i32) { *pointer = value; }

func main() i32 {
  var value i32 := 7;
  var pointer *i32 := &value;
  Write(pointer, 19);
  value
}
