struct Point {
  int x;
  int y;
  Point(int x, int y) : x(x), y(y) {}
  Point(int x) : Point(x, 0) {}
  ~Point() {}
};
void ConstructorThis() {
  Point p(1);
}
