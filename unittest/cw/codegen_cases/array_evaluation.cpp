// The wrapper makes C++'s object assignment available for the complete array.
struct Array {
  int values[2];
};

Array& Change(Array& source, Array& target, unsigned long index) {
  source.values[index] = 9;
  return target;
}

void Existing(Array& source, Array& target, unsigned long index) { Change(source, target, index) = source; }

void Formed(Array& source, Array& target, unsigned long index) {
  Change(source, target, index) = Array{{source.values[index], source.values[index]}};
}

Array& Locate(Array& value, unsigned long& index, unsigned long replacement) {
  index = replacement;
  return value;
}

int Read(Array& value, unsigned long& index, unsigned long replacement) {
  return Locate(value, index, replacement).values[index];
}

int Next(int& value) {
  // Inputs keep the increment representable in C++; CW defines signed wrapping separately.
  value = value + 1;
  return value;
}

int Elements(int& value, unsigned long index) {
  Array values{{Next(value), Next(value)}};
  return values.values[index];
}

void Discarded(bool flag, int& value) { (void)(flag ? Array{{Next(value), Next(value)}} : Array{{0, Next(value)}}); }
