struct Base {
  virtual void Draw() const;
  virtual void Measure() const = 0;
};

void Base::Draw() const {}
void Base::Measure() const {}

struct Derived : Base {
  void Draw() const override;
};

void Derived::Draw() const {}

int Ordinary(int value) { return value; }

int Use(const Base& base, const Derived& derived, const Base* pointer) {
  base.Draw();
  base.Base::Draw();
  base.Base::Measure();
  pointer->Base::Draw();
  derived.Draw();
  derived.Derived::Draw();
  derived.Base::Draw();
  return Ordinary(1);
}
