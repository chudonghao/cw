struct Base {
  virtual int Read() const = 0;
  Base();
  ~Base();
};
int Base::Read() const { return 9; }
Base::Base() {}
Base::~Base() {}
struct Derived : Base {
  int Read() const override;
  Derived();
  ~Derived();
};
int Derived::Read() const { return 2; }
int Invoke(const Base& object) { return object.Read(); }
Derived::Derived() : Base() { Invoke(*this); }
Derived::~Derived() {}
int Check() {
  Derived object;
  return Invoke(object) + object.Base::Read();
}
