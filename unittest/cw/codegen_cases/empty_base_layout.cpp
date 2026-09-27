struct Empty {};
struct Member {
  Empty empty;
};
struct Distinct : Empty {
  Member member;
  unsigned char value;
};
struct Anchor {
  Anchor() {}
  ~Anchor() {}
};
struct Aligned : Anchor {
  int zero[0];
  Aligned() : Anchor(), zero{} {}
  ~Aligned() {}
};
struct Child : Aligned {
  unsigned char value;
  Child() : Aligned(), value(7) {}
  ~Child() {}
};

Empty* Base(Distinct& value) { return &value; }
Empty* Nested(Distinct& value) { return &value.member.empty; }
unsigned char* Last(Distinct& value) { return &value.value; }
Child Make() { return Child(); }
