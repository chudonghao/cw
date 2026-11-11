struct Base {
  int value;
  explicit Base(int value) : value(value) {}
  ~Base() {}
};
struct Label {
  Label() {}
  ~Label() {}
};
struct Counter : Base, Label {
  int limit;
  // CW computes `first` before the bases and chooses the Base source in a
  // branch. C++ evaluates the bases in declaration order in the initializers.
  Counter(int start, bool skip_first) : Base(skip_first ? start + 1 : start), Label(), limit(start + 1) {}
  // CW delegates on one path and constructs the object itself on the other.
  // C++ delegation is unconditional, so this counterpart shows only the second path.
  explicit Counter(bool flag) : Base(2), Label(), limit(3) {}
  ~Counter() {}
};
