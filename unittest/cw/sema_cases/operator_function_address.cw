trivial struct AddressValue {}

func operator-(value copy AddressValue) copy AddressValue {
  value
}

func OperatorFunctionAddress(value copy AddressValue) copy AddressValue {
  var operation *func (copy AddressValue) copy AddressValue := &operator -;

  operation(value)
}
