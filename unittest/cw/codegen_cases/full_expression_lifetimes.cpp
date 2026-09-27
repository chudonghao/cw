struct Token {
  Token() {}
  ~Token() {}
};
struct Holder {
  Holder(const Token&) {}
  ~Holder() {}
};
Holder Make(const Token& value) { return Holder(value); }
void Boundaries() {
  Holder first = Holder(Token()), second = Make(Token());
  // A directly returned prvalue expresses the CW initialization block's result identity.
  Holder block = [] {
    Token inner;
    return Holder(Token());
  }();
}
Holder Returning() {
  Token local;
  return Holder(Token());
}
