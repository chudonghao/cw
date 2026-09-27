func Replace(value &mut i32) i32 {
  value = 67;
  value
}

func First(first i32, second i32) i32 {
  first
}

func OrdinaryCall() i32 {
  var value i32 := 13;
  First(value, Replace(value))
}

func ReceiverCall() i32 {
  var value i32 := 13;
  value.First(Replace(value))
}

func ConditionalFirst(value i32, ignored i32) i32 {
  value
}

func ConditionalArgument(flag bool) i32 {
  var value i32 := 5;
  ConditionalFirst(flag ? value : (value = 7), value = 11)
}

func Locate(value &mut i32) &mut i32 {
  value = 23;
  value
}

func ReceiverSource() i32 {
  var value i32 := 13;
  Locate(value).First(Replace(value))
}

func ReadFirst(first &copy i32, ignored i32) i32 {
  first
}

func ReferenceArgument() i32 {
  var value i32 := 13;
  ReadFirst(Locate(value), Replace(value))
}
