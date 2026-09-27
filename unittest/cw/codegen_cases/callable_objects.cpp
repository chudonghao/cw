// C++ expresses the callable receiver as a member's implicit this parameter.
struct Callable {
  int value;
  int operator()(int argument) {
    value = argument;
    return value;
  }
  // The sum is representable in C++.
  int operator()(int argument) const { return value + argument; }
};
struct Derived : Callable {
  int extra;
};

int Invoke(Derived& object, int value) {
  object.operator()(value);
  return object(value);
}
int Read(const Derived& object, int value) { return object(value); }
int Pointer(Callable* object, int value) { return (*object)(value); }
int Temporary(int value) {
  // CW binds this temporary to the const-reference overload; C++ permits a mutable member call.
  return static_cast<const Callable&>(Callable{})(value);
}
