struct Base {
  virtual int Read() const;
  explicit Base(int value);
  ~Base();
};
int Base::Read() const { return 1; }
Base::Base(int) {}
Base::~Base() {}
struct Counter : Base {
  int Read() const override;
  int limit;
  Counter(int start, bool skip_first);
  explicit Counter(bool flag);
  ~Counter();
};
int Counter::Read() const { return 2; }
// CW computes `first` before the base and chooses the base source in a branch.
// C++ can only compute in the member initializers, so `first` is recomputed.
Counter::Counter(int start, bool skip_first) : Base(skip_first ? start + 1 : start), limit(start + 1 + 10) {}
// CW delegates on one path and constructs the object itself on the other. C++
// delegation is unconditional, so this counterpart shows only the second path.
Counter::Counter(bool flag) : Base(3), limit(4) {}
Counter::~Counter() {}
struct Probe {
  virtual int Read() const;
  explicit Probe(int value);
  explicit Probe(bool flag);
  ~Probe();
};
int Probe::Read() const { return 5; }
Probe::Probe(int) {}
// CW dispatches as Probe from the entry of a constructor without subobjects. It
// delegates on one path and calls Read on the other. C++ delegation is
// unconditional, so this counterpart shows only the second path.
Probe::Probe(bool flag) {
  if (flag) {
  } else {
    int before = Read();
    (void)before;
  }
}
Probe::~Probe() {}
