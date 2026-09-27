struct Item { value i32; }

ctor Item(value i32) { this.value := value; }
ctor Item(other &copy Item) { this.value := other.value; }
ctor Item(other &move Item) { this.value := other.value; }
ctor Item() { this := Item(7); }
dtor Item() {}

func Construct() {
  var first := Item();
  var copied Item := first;
  var moved Item := move first;
  Item(9);
}
