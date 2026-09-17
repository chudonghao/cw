trivial struct Base {}

trivial struct Middle : Base {}

trivial struct Derived : Middle {}

func Exact(value copy Base) {}

func Exact(value copy Derived) {}

func Near(value copy Base) {}

func Near(value copy Middle) {}

func Receive(this copy Base) {}

func ReturnBase(value copy Derived) copy Base {
  value
}

func DerivedToBaseReferenceBinding(value mut Derived, pointer *Derived) {
  var base mut Base := value;

  Exact(value);
  Near(value);
  value.Receive();
  pointer->Receive();
  ReturnBase(value);
}
