struct Callable {
  int operator()(int value) & { return value; }
  int operator()(int value) const& { return value; }
  long long operator()(long long value) & { return value; }
};

long long CallableObject(Callable& object, const Callable& fixed, int narrow, long long wide) {
  object(narrow);
  fixed(narrow);
  object.operator()(narrow);
  using Operation = int (Callable::*)(int) &;
  Operation operation = static_cast<Operation>(&Callable::operator());
  (object.*operation)(narrow);
  return object(wide);
}

int InvokePointer(Callable* pointer, int narrow) { return (*pointer)(narrow); }
