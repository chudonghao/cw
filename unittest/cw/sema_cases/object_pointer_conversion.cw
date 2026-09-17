trivial struct Base {}

trivial struct Middle : Base {}

trivial struct Derived : Middle {}

func Exact(value *const Derived) {}

func Exact(value *Derived) {}

func Near(value *Base) {}

func Near(value *Middle) {}

func ObjectPointerConversion(derived *Derived, nested **Derived) {
  var base *Base := derived;
  var readonly_base *const Base := derived;
  var readonly_derived *const Derived := derived;
  var safe_nested *const *const Derived := nested;

  Exact(derived);
  Near(derived);
}
