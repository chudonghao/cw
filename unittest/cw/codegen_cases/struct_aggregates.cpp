struct Inner {
  short value;
};

struct Outer {
  unsigned char leading;
  Inner inner;
  Inner items[2];
};

short Nested(short value, unsigned long index) {
  Outer object{1, {value}, {Inner{}, object.inner}};
  return object.items[index].value;
}

struct ArrayValue {
  Outer items[2];
};

short Array(const ArrayValue& source, unsigned long index) {
  ArrayValue copied = source;
  return copied.items[index].items[index].value;
}
