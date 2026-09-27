struct Item { value i32; }
ctor Item(value i32) { this.value := value; }
ctor Item(other &copy Item) { this.value := other.value; }
ctor Item(other &move Item) { this.value := other.value; }
dtor Item() {}

func Copy(source &copy [2] Item) { var value := source; }
func Move(source &move [2] Item) { var value := move source; }
func Nested(source &copy [1][2] Item) { var value := source; }
func Zero(source &copy [0] Item) { var value := source; }

func ZeroSource(source &copy [3][0] Item, counter &mut i32) &copy [3][0] Item {
  counter = counter + 1;
  source
}
func NestedZero(source &copy [3][0] Item, counter &mut i32) {
  var value := ZeroSource(source, counter);
}

struct Empty {}
ctor Empty() {}
ctor Empty(other &copy Empty) {}
dtor Empty() {}
func EmptyElements() { var value := [2] Empty { Empty(), Empty() }; }
func CopyEmpty(source &copy [2] Empty) { var value := source; }
func EmptyValue(value Empty) Empty { Empty() }
func Discard() { EmptyValue(Empty()); }

struct Holder { items [0] Item; }
ctor Holder(source &copy Holder) { this.items := source.items; }
dtor Holder() {}
func Holders(source &copy [2] Holder) { var value := source; }
