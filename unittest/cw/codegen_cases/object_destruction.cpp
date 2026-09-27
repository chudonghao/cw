struct Part {
  Part() {}
  ~Part() {}
};
struct Base {
  int value;
  Base(int value) : value(value) {}
  ~Base() {}
};
struct Owner : Base {
  Part first;
  Part last[2];
  Owner() : Base(1), first(), last() {}
  ~Owner() {
    Part local;
    return;
  }
};
void Destroy() { Owner owner; }
