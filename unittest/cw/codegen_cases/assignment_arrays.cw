var trace i64 := 0;
struct Base { value i32; }
ctor Base(value i32) { this.value := value; }
ctor Base(source &copy Base) { this.value := source.value; }
dtor Base() {}
struct Item : Base {}
ctor Item(value i32) { this.Base := Base(value); }
ctor Item(source &copy Item) { this.Base := source.Base; trace = trace * 10 + 2; }
ctor Item(source &move Item) { this.Base := source.Base; trace = trace * 10 + 3; }
dtor Item() { trace = trace * 10 + 4; }
struct Receipt {}
ctor Receipt() {}
dtor Receipt() { trace = trace * 10 + 6; }
func operator=(target &mut Base, source Item) Receipt {
  target.value = source.value;
  trace = trace * 10 + 5;
  Receipt()
}
func Copy(target &mut [2] Item, source &copy [2] Item) { target = source; }
func Move(target &mut [2] Item, source &move [2] Item) { target = move source; }
func Nested(target &mut [1] [2] Item, source &copy [1] [2] Item) { target = source; }
func Zero(target &mut [0] Item, source &copy [0] Item) { target = source; }
namespace ByValue {
func operator=(target Item, source &copy Base) i32 { target.value = source.value; 7 }
func Copy(target &mut [2] Item, source &copy [2] Item) { target = source; }
}
