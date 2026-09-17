struct OperatorValue {};

const OperatorValue& operator-(const OperatorValue& value) {
  return value;
}

const OperatorValue& operator+(const OperatorValue& left, const OperatorValue& right) {
  return left;
}

void OperatorExpression(const OperatorValue& left, const OperatorValue& right) {
  -left;
  left + right;
}
