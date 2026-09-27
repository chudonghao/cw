struct Number {
  int value;
};

// Arithmetic inputs keep these signed C++ operations representable.
int operator-(const Number& value) { return -value.value; }
int operator-(const Number& left, short right) { return left.value - right; }

int Unary(const Number& value) { return -value; }
int Binary(const Number& value, signed char amount) { return value - amount; }
int Explicit(const Number& value, short amount) { return operator-(value, amount); }
int Indirect(const Number& value, short amount) {
  int (*operation)(const Number&, short) = &operator-;
  return operation(value, amount);
}
