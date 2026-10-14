namespace Shared {
  var order i32 := 1;
  func Read(value &copy T) i32 { value.number }
  func main(value i32) i32 { value }
}
func main() i32 { Shared::Run() }
