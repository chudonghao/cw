// These are defined in another translation unit, as CW's imported declarations are.
struct Left {
  virtual int Read() const;
  Left();
  ~Left();
};
struct Right {
  virtual int Size() const;
  Right();
  ~Right();
};
// A watch can call back through the Right base when it is destroyed.
struct Watch {
  const Right* target;
  explicit Watch(const Right* target);
  ~Watch();
};
void Record(int value);

// C++ installs Both's vptrs before member initialization and keeps them while members are
// destroyed. CW starts Both's dispatch after the last initialization and leaves it before the
// members are destroyed, so CW's calls before the watch exists use the bases' own stages.
struct Both : Left, Right {
  int Read() const override;
  int Size() const override;
  Watch watch;
  Both();
  ~Both();
};
int Both::Read() const { return 3; }
int Both::Size() const { return 4; }
Both::Both() : Left(), Right(), watch(this) {
  Record(static_cast<const Left&>(*this).Read() + static_cast<const Right&>(*this).Size());
}
Both::~Both() { Record(static_cast<const Right&>(*this).Size()); }
