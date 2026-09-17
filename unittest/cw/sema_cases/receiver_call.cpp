struct Receiver {
  void Select() & {}
  void Select() const & {}
  void Select() && {}
  void Read() const & {}
  void WithArg(int) & {}
};
Receiver Make() { return {}; }
void ReceiverCall(Receiver value, const Receiver& fixed, Receiver* pointer,
                  const Receiver* const_pointer, int argument) {
  value.Select();
  fixed.Select();
  static_cast<Receiver&&>(value).Select();
  Make().Select();
  pointer->Read();
  const_pointer->Read();
  value.WithArg(argument);
}
