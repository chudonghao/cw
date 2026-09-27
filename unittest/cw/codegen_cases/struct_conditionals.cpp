struct Value {
  int number;
};

Value& Choose(bool flag, Value& left, Value& right) { return flag ? left : right; }

int Form(bool flag, const Value& source) {
  Value result = flag ? Value{} : source;
  return result.number;
}

int Read(const Value& value) { return value.number; }

int Temporary() { return Read(Value{}); }

void Discard(bool flag, const Value& source) { flag ? Value{} : source; }
