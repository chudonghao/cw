struct Node {
  virtual int Visit() const = 0;
  Node() {}
  ~Node() {}
};
struct Left : Node {
  int Visit() const override;
  Left() : Node() {}
  ~Left() {}
};
int Left::Visit() const { return 1; }
struct Right : Node {
  Right() : Node() {}
  ~Right() {}
};
// Partial stays abstract: its Right subobject keeps the abstract Node::Visit.
struct Partial : Left, Right {
  Partial() : Left(), Right() {}
  ~Partial() {}
};
// One override replaces Left::Visit and the Node::Visit inherited through Right.
struct Both : Left, Right {
  int Visit() const override;
  Both() : Left(), Right() {}
  ~Both() {}
};
int Both::Visit() const { return 2; }
int MultipleInheritanceVirtual(const Both& both) { return both.Visit(); }
