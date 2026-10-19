struct Value {
  int number;
  Value& operator=(int source) & { number = source; return *this; }
  int operator=(bool source) const & { return source ? number : 0; }
};
Value& Mutable(Value& target) { return target = 7; }
int Readonly(const Value& target) { return target = true; }
int Temporary() { return Value{} = true; }
// CW can pass the receiver by value; spell the equivalent operation as a helper in C++.
int AssignValue(Value target, int* source) { return target.number + *source; }
int ByValue(const Value& target, int* source) { return AssignValue(target, source); }

struct Derived;
struct Base {
  int value;
  unsigned char tag;
  int operator=(Derived&& source) { return 42; }
};
struct Derived : Base { unsigned char own; };
Base& Slice(Base& target, const Derived& source) { return target = source; }
Derived& Move(Derived& target, Derived&& source) { return target = static_cast<Derived&&>(source); }
Derived& MoveWins(Derived& target, Derived&& source) { return target = static_cast<Derived&&>(source); }

struct Box {
  int value;
  explicit Box(int value) : value(value) {}
  ~Box() {}
  int operator=(Box& source) { value = source.value; return 1; }
  bool operator=(const Box& source) { value = source.value; return true; }
};
int MutableSource(Box& target, Box& source) { return target = source; }
bool ConstSource(Box& target, const Box& source) { return target = source; }
