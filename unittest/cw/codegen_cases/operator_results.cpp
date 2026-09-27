struct Number {
  int value;
};
struct Big {
  long long values[3];
};

int& operator+(Number& value) { return value.value; }
Number&& operator-(Number&& value) { return static_cast<Number&&>(value); }
// The sum is representable in C++.
Number operator+(const Number& left, const Number& right) { return Number{left.value + right.value}; }
Big operator+(const Big& left, const Big& right) { return left; }
void operator!(Number& value) { value.value = 0; }

void Assign(Number& value) {
  +value = 7;
  !value;
}
Number&& Move(Number& value) { return -static_cast<Number&&>(value); }
int Small(const Number& left, const Number& right) { return (left + right).value; }
Big Large(const Big& left, const Big& right) { return left + right; }
void Discard(const Big& left, const Big& right) { left + right; }
