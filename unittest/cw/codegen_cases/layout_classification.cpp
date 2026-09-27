struct Empty {};
struct Floats : Empty {
  float x;
  float y;
};
struct WithZero {
  float x;
  float zero[0];
};
struct Pointer : Empty {
  int* value;
};
struct Pointers {
  int* values[2];
};

Floats FloatIdentity(Floats value) { return value; }
WithZero ZeroIdentity(WithZero value) { return value; }
Pointer PointerIdentity(Pointer value) { return value; }
Pointers PointersIdentity(Pointers value) { return value; }
// The wrapper preserves CW's by-value array semantics.
Pointers ArrayIdentity(Pointers value) { return value; }
