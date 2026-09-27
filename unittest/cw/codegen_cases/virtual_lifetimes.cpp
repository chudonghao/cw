long long trace = 0;
struct Base {
  virtual int Read() const;
  Base();
  ~Base();
};
int Base::Read() const { return 1; }
void Record(const Base& object) { trace = trace * 10 + object.Read(); }
Base::Base() {}
Base::~Base() { Record(*this); }
struct Watch {
  const Base* target;
  explicit Watch(const Base* target);
  ~Watch();
};
Watch::Watch(const Base* input) : target(input) {}
Watch::~Watch() { Record(*target); }
int Complete(const Watch&) { return 0; }
struct Derived : Base {
  int Read() const override;
  Watch watch;
  int value;
  explicit Derived(bool flag);
  Derived();
  ~Derived();
};
int Derived::Read() const { return 2; }
// C++ installs the derived vptr before member initialization; CW activates only
// after the last initialization's temporary cleanup, including inside branches.
// C++ has no counterpart for CW's branch-local field initialization, so the
// local observer below covers body cleanup while the initializer covers temporaries.
Derived::Derived(bool flag) : Base(), watch(this), value(Complete(Watch(this)) + (flag ? 0 : 1)) {
  Watch local(this);
  Record(*this);
}
Derived::Derived() : Derived(true) { Record(*this); }
Derived::~Derived() {
  Watch local(this);
  Record(*this);
  if (value == 0) return;
  // C++ retains derived dispatch during member destruction. CW restores base
  // dispatch after body locals and before destroying watch.
}
Derived global(true);
long long ReadTrace() { return trace; }
long long Entry(bool flag) {
  trace = 0;
  {
    Derived value(flag);
  }
  return trace;
}
long long Delegate() {
  trace = 0;
  {
    Derived value;
  }
  return trace;
}
