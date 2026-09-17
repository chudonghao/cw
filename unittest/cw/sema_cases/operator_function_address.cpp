struct AddressValue {};

const AddressValue& operator-(const AddressValue& value) { return value; }

const AddressValue& OperatorFunctionAddress(const AddressValue& value) {
  const AddressValue& (*operation)(const AddressValue&) = &operator-;
  return operation(value);
}
