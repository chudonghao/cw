struct Pair {
  int first;
  int second;
};

struct Callback {
  int (*invoke)(int);
};

int& Member(Pair& value, int input) {
  value.second = input;
  return value.second;
}

int* Pointer(Pair* value, int input) {
  value->first = input;
  return &value->first;
}

int Call(const Callback& value, int input) { return value.invoke(input); }

int Temporary() { return Pair{}.first; }
