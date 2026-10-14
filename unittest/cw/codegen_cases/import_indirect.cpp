// Only virtual calls and slot values are used, without direct table or
// implementation references. Clang omits unused declarations; CW retains them.
struct Base {
  virtual int Read() const;
  virtual int Abstract() const = 0;
  ~Base();
};
void Unused();

int Dispatch(const Base& value) {
  // Preserve CW's left-to-right calls. The C++ sum assumes no signed overflow.
  int first = value.Read();
  return first + value.Abstract();
}
using VirtualFunction = int (Base::*)() const;
VirtualFunction Slot() { return &Base::Read; }
