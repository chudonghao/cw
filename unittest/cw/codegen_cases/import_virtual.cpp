namespace api {
// All Base operations are defined in another translation unit. CW separately
// exposes Keep for ordinary calls; the other slots remain virtual-only there.
struct Base {
  virtual int Read() const;
  virtual int Keep() const;
  virtual int Hidden() const;
  Base();
  ~Base();
};
}  // namespace api

// This unit defines Read and emits Derived's table. CW gives its table external
// linkage through the exported type, independently of Read's visibility.
struct Derived : api::Base {
  int Read() const override;
  Derived();
  ~Derived();
};
int Derived::Read() const { return 2; }
Derived::Derived() : api::Base() {}
// CW restores the imported base vptr before its destructor call. This C++ caller
// only calls the external base destructor, which handles its own vptr transition.
Derived::~Derived() {}
int Dispatch(const api::Base& value) { return value.Read(); }
int Direct(const api::Base& value) { return value.api::Base::Keep(); }

// CW can take the ordinary implementation's address directly. A C++ ordinary
// function pointer needs this adapter to make the qualified member call.
using Function = int (*)(const api::Base&);
Function Address() { return &Direct; }
int Slot(const api::Base& value) {
  // C++ member pointers also support nonvirtual targets; CW's pointer is virtual-only.
  using VirtualFunction = int (api::Base::*)() const;
  VirtualFunction callback = &api::Base::Hidden;
  return (value.*callback)();
}
int Use() {
  Derived value;
  return Dispatch(value);
}
