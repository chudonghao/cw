int Replace(int& value) {
  value = 67;
  return value;
}

int First(int first, int second) { return first; }

// CW evaluates arguments left to right. C++17 leaves their relative order
// unspecified; this reference shows this Clang's choice.
int OrdinaryCall() {
  int value = 13;
  return First(value, Replace(value));
}

int ReceiverCall() {
  int value = 13;
  // CW's value.First(...) calls the same free function with value prepended.
  return First(value, Replace(value));
}

int ConditionalFirst(int value, int ignored) { return value; }

int ConditionalArgument(bool flag) {
  int value = 5;
  // C++17 leaves argument order unspecified; Clang still warns about sequencing here.
  return ConditionalFirst(flag ? value : (value = 7), value = 11);
}

int& Locate(int& value) {
  value = 23;
  return value;
}

int ReceiverSource() {
  int value = 13;
  return First(Locate(value), Replace(value));
}

int ReadFirst(const int& first, int ignored) { return first; }

int ReferenceArgument() {
  int value = 13;
  return ReadFirst(Locate(value), Replace(value));
}
