struct OperatorCallValue {};

const OperatorCallValue& operator-(const OperatorCallValue& value) {
  return value;
}

const OperatorCallValue& operator-(const OperatorCallValue& left, const OperatorCallValue& right) {
  return left;
}

void OperatorFunctionCall(const OperatorCallValue& value, const OperatorCallValue& other) {
  operator-(value);
  operator-(value, other);
}
