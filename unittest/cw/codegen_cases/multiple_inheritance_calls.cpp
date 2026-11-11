struct Empty {};
struct Other {};
// Every base is empty, so the value is not passed at all.
struct Nothing : Empty, Other {};

// The floats of both bases and the field form one homogeneous aggregate.
struct X {
  float x;
};
struct Y {
  float y;
};
struct Vector : X, Y {
  float z;
};

// Both bases hold only pointers, so the value is passed as pointers.
struct Head {
  int* head;
};
struct Tail {
  int* tail;
};
struct Links : Head, Tail {};

// An empty base keeps the value from being passed as pointers.
struct Marked : Head, Empty {
  int* tail;
};

Nothing PassNothing(Nothing value) { return value; }
Vector PassVector(Vector value) { return value; }
Links PassLinks(Links value) { return value; }
Marked PassMarked(Marked value) { return value; }
