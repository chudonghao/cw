trivial struct Receiver {}

func Select(this mut Receiver) void {
  this;
}

func Select(receiver copy Receiver) void {}

func Select(receiver move Receiver) void {}

func Make() Receiver {
  Receiver()
}

func Read(receiver copy Receiver) void {}

func WithArg(receiver mut Receiver, value i32) void {}

func ReceiverCall(value Receiver, fixed copy Receiver, pointer *Receiver, const_pointer *const Receiver, argument i32) {
  value.Select();
  fixed.Select();
  (move value).Select();
  Make().Select();
  pointer->Read();
  const_pointer->Read();
  value.WithArg(argument);
}
