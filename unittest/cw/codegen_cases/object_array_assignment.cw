struct Item { value i32; }
ctor Item(value i32) { this.value := value; }
dtor Item() {}
func operator=(target &mut Item, source &copy Item) {
  target.value = source.value;
}
func operator=(target &mut Item, source &move Item) &mut Item {
  target.value = source.value;
  target
}

func Copy(target &mut [2] Item, source &copy [2] Item) &mut [2] Item { target = source }
func Move(target &mut [2] Item, source &move [2] Item) &mut [2] Item { target = move source }
func Nested(target &mut [2][2] Item, source &copy [2][2] Item) { target = source; }

struct CopyOnly { value i32; }
ctor CopyOnly(value i32) { this.value := value; }
dtor CopyOnly() {}
func operator=(target &mut CopyOnly, source &copy CopyOnly) i32 {
  target.value = source.value;
  7
}
func Fallback(target &mut [2] CopyOnly, source &move [2] CopyOnly) { target = move source; }

func ZeroSource(source &copy [3][0] Item, counter &mut i32) &copy [3][0] Item {
  counter = counter * 10 + 1;
  source
}
func ZeroTarget(target &mut [3][0] Item, counter &mut i32) &mut [3][0] Item {
  counter = counter * 10 + 2;
  target
}
func NestedZero(target &mut [3][0] Item, source &copy [3][0] Item, counter &mut i32) {
  ZeroTarget(target, counter) = ZeroSource(source, counter);
}

struct Empty {}
ctor Empty() {}
dtor Empty() {}
func operator=(target &mut Empty, source &copy Empty) {}
func EmptyElements(target &mut [2] Empty, source &copy [2] Empty) { target = source; }
