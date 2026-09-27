struct Value {
  int number;
};

Value& Change(Value& source, Value& target) {
  source.number = 9;
  return target;
}

void Existing(Value& source, Value& target) { Change(source, target) = source; }

void Formed(Value& source, Value& target) { Change(source, target) = Value{}; }
