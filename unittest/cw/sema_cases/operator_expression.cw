trivial struct OperatorValue {}

func operator-(this copy OperatorValue) copy OperatorValue {
  this
}

func operator+(left copy OperatorValue, right copy OperatorValue) copy OperatorValue {
  left
}

func OperatorExpression(left copy OperatorValue, right copy OperatorValue) void {
  -left;
  left + right;
}
