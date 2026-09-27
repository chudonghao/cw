struct Base {
  virtual int Read() const;
  virtual int Keep() const;
  Base();
  ~Base();
};
struct Derived : Base {
  int Read() const override;
  Derived();
  ~Derived();
};
int Base::Read() const { return 1; }
int Base::Keep() const { return 5; }
int Derived::Read() const { return 2; }
Base::Base() {}
Base::~Base() {}
Derived::Derived() : Base() {}
Derived::~Derived() {}
int ReadBase(const Base& object) { return object.Read() + object.Read(); }
int Entry() {
  Derived value;
  return ReadBase(value) + value.Keep() + value.Derived::Read() + value.Base::Read();
}
