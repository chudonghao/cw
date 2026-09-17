struct Point {
  x i32;
  y i32;
}

ctor Point(x i32, y i32) {
  this.x := x;
  this.y := y;
}

ctor Point(x i32) {
  this := Point(x, 0);
}

dtor Point() {}

func ConstructorThis() {
  var p := Point(1);
}
