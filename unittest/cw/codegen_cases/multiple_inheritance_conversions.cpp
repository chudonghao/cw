struct Small {
  int a;
};
struct Wide {
  long long b;
};
struct Pair : Small, Wide {
  int c;
};

// Wide is at offset eight. A pointer conversion keeps null; a zero offset needs no check.
Wide& WideReference(Pair& pair) { return pair; }
Wide* WidePointer(Pair* pair) { return pair; }
Small* SmallPointer(Pair* pair) { return pair; }

// Point occurs twice in Twice; a base path names one of them.
struct Point {
  int x;
};
struct Mark {
  int m;
};
struct First : Point {};
struct Second : Point, Mark {};
struct Twice : First, Second {};
Mark* MarkPointer(Twice* twice) { return twice; }
Point& SecondPoint(Twice& twice) { return static_cast<Second&>(twice); }
void AssignPoint(Twice& twice, const Point& source) {
  static_cast<Point&>(static_cast<Second&>(twice)) = source;
}

// Member access through a pointer reaches the base at its offset without a null check.
long long ReadWide(Pair* pair) { return pair->b; }
int ReadMark(Twice* twice) { return static_cast<Second&>(*twice).m; }

// Left and Right are defined in another translation unit, as CW's imported declarations are.
// Construction initializes each base in place, including the one at a nonzero offset.
struct Left {
  int l;
  explicit Left(int value);
  ~Left();
};
struct Right {
  long long r;
  explicit Right(long long value);
  ~Right();
};
struct Join : Left, Right {
  Join();
  ~Join();
};
Join::Join() : Left(1), Right(2) {}
Join::~Join() {}
