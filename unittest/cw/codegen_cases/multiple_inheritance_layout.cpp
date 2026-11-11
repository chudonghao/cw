struct Empty {};
struct Small {
  int a;
};
struct Wide {
  long long b;
};
// The empty base shares offset zero with Small.
struct Pair : Small, Wide, Empty {
  unsigned char c;
};

// Empty base subobjects of the same type need distinct addresses.
struct EmptyA : Empty {};
struct EmptyB : Empty {};
struct EmptyC : Empty {};
struct Spread : EmptyA, EmptyB, EmptyC {
  unsigned char d;
};

// These are defined in another translation unit, as CW's imported declarations are.
// The dynamic base is primary and precedes the base declared before it.
struct Count {
  int a;
  ~Count();
};
struct Shape {
  virtual int Area() const;
  int e;
  ~Shape();
};
struct Placed : Count, Shape {
  int f;
  ~Placed();
};

// Padded is not standard-layout, so Byte reuses its tail padding.
struct Head {
  int g;
};
struct Padded : Head {
  unsigned char h;
};
struct Byte {
  unsigned char i;
};
struct Packed : Padded, Byte {
  unsigned char j;
};

// A base reached through two paths forms two subobjects.
struct Point {
  int x;
};
struct First : Point {};
struct Second : Point {};
struct Twice : First, Second {
  int y;
};

// The sums assume values without signed overflow; CW signed arithmetic wraps.
long long ReadPair(const Pair& pair) { return pair.a + pair.b + pair.c; }
Empty* ThirdEmpty(Spread& spread) { return static_cast<EmptyC*>(&spread); }
unsigned char ReadSpread(const Spread& spread) { return spread.d; }
int ReadPlaced(const Placed& placed) { return placed.a + placed.e + placed.f; }
unsigned char ReadPacked(const Packed& packed) { return packed.h + packed.i + packed.j; }
// C++ cannot name x through First while Point is ambiguous in Twice, so it converts first.
int ReadTwice(const Twice& twice) {
  return static_cast<const First&>(twice).x + static_cast<const Second&>(twice).x + twice.y;
}
