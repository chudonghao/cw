int* Set(int*& target, int* next) {
  target = next;
  return target;
}

bool CompareBeforeChange(int*& target, int* next) {
  // CW completes the left pointer read before the right-side mutation.
  int* before = target;
  int* after = Set(target, next);
  return before == after;
}

const int* Choose(bool flag, int* pointer) { return flag ? pointer : nullptr; }

int*& Select(bool flag, int*& left, int*& right) { return flag ? left : right; }

void WriteSelected(bool flag, int*& left, int*& right, int* value) { Select(flag, left, right) = value; }

int* Locate(int* pointer, int& count) {
  count = count + 1;
  return pointer;
}

// The order example uses values whose increments are representable.
int Next(int& value) {
  value = value + 1;
  return value;
}

void AssignOnce(int* pointer, int& state) { *Locate(pointer, state) = Next(state); }
