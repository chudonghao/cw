struct Inner {
  float value;
};
struct Homogeneous {
  Inner first;
  float rest[2];
};
struct Mixed {
  float real;
  int integer;
};
// Clang's zero-length array extension retains alignment and the resulting tail padding.
struct Padded {
  float real;
  long empty[0];
};
struct ZeroArray {
  double real;
  long empty[0];
};
struct NestedZeroArray {
  float real;
  int empty[2][0];
};
struct FourDoubles {
  double values[4];
};
struct FiveFloats {
  float values[5];
};

Homogeneous Nested(Homogeneous value) { return value; }
FourDoubles Four(FourDoubles value) { return value; }
FiveFloats Five(FiveFloats value) { return value; }
Mixed Different(Mixed value) { return value; }
Padded WithPadding(Padded value) { return value; }
ZeroArray WithZeroArray(ZeroArray value) { return value; }
NestedZeroArray WithNestedZeroArray(NestedZeroArray value) { return value; }
Homogeneous Forward(const Homogeneous& value) { return Nested(value); }
ZeroArray ForwardZeroArray(const ZeroArray& value) { return WithZeroArray(value); }
