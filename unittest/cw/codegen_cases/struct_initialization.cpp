struct Padded {
  unsigned char tag;
  int number;
  bool enabled;
};

struct Defaults {
  short count;
  bool enabled;
  float ratio;
  double wide;
  int* pointer;
  int (*callback)();
  int values[2];
};

bool Fields(int number, bool enabled) {
  Padded value{1, number, enabled};
  return value.enabled;
}

int* Default() {
  Defaults value{};
  return value.pointer;
}
