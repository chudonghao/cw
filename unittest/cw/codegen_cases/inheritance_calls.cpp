struct FloatBase {
  double x;
};
struct Floats : FloatBase {
  double y;
};
struct BigBase {
  long long values[3];
};
struct Big : BigBase {
  bool flag;
};

Floats FloatIdentity(Floats value) { return value; }
Floats FloatCall(const Floats& value) { return FloatIdentity(value); }
BigBase MakeBigBase() { return BigBase{}; }

Big BigCall() {
  Big value{MakeBigBase(), true};
  return value;
}

Big Indirect(Big (*callback)(Big), const Big& value) { return callback(value); }
