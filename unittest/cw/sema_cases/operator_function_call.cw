trivial struct OperatorCallValue {}

func operator-(value copy OperatorCallValue) copy OperatorCallValue {
  value
}

func operator-(left copy OperatorCallValue, right copy OperatorCallValue) copy OperatorCallValue {
  left
}

func OperatorFunctionCall(value copy OperatorCallValue, other copy OperatorCallValue) void {
  operator -(value);
  operator -(value, other);
}
