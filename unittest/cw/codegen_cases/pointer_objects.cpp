int* Address(int& value) { return &value; }

int Read(const int* pointer) { return *pointer; }

void Write(int* pointer, int value) { *pointer = value; }

bool Toggle(bool* pointer) {
  *pointer = !*pointer;
  return *pointer;
}

double Double(double* pointer, double value) {
  *pointer = value;
  return *pointer;
}

int* Nested(int** pointer, int* other) {
  *pointer = other;
  return *pointer;
}

int Local() {
  int value = 7;
  int* pointer = &value;
  *pointer = 11;
  return Read(pointer);
}

int* Receiver(int* pointer) { return Address(*pointer); }
