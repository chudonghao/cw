struct Pair {
  long first;
  long second;
};
struct Triple {
  long first;
  long second;
  long third;
};

int ChangeSmall(Pair& value) {
  value.first = 99;
  return 0;
}
long TakeSmall(Pair value, int ignored) {
  value.second = 7;
  return value.first;
}
long Small(Pair& value) {
  // C++ does not prescribe argument order; capture the complete CW value first.
  Pair argument = value;
  int ignored = ChangeSmall(value);
  return TakeSmall(argument, ignored);
}

int ChangeLarge(Triple& value) {
  value.first = 99;
  return 0;
}
long TakeLarge(Triple value, int ignored) {
  value.second = 7;
  return value.first;
}
long Large(Triple& value) {
  Triple argument = value;
  int ignored = ChangeLarge(value);
  return TakeLarge(argument, ignored);
}
