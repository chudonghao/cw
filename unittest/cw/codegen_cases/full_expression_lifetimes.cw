struct Token {}
ctor Token() {}
dtor Token() {}
struct Holder {}
ctor Holder(value &copy Token) {}
dtor Holder() {}

func Make(value &copy Token) Holder { Holder(value) }
func Boundaries() {
  var first Holder, second Holder := Holder(Token()), Make(Token());
  var block Holder := {
    var inner := Token();
    Holder(Token())
  }
}
func Returning() Holder {
  var local := Token();
  return Holder(Token());
}
