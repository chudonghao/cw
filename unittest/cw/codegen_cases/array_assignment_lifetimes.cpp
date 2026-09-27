struct Receipt {
  int* trace;
  Receipt(int* trace) : trace(trace) {}
  ~Receipt() { *trace = *trace * 10 + 2; }
};
struct Item {
  int* trace;
  Item(int* trace) : trace(trace) {}
  ~Item() {}
  Receipt operator=(const Item& source) {
    *trace = *trace * 10 + 1;
    return Receipt(trace);
  }
};
// The implicit wrapper assignment discards and destroys each element's result.
struct Pair {
  Item elements[2];
};
struct Token {
  int* trace;
  int tag;
  Token(int* trace, int tag) : trace(trace), tag(tag) { *trace = *trace * 10 + tag; }
  ~Token() { *trace = *trace * 10 + tag; }
};
const Pair& Source(const Pair& source, const Token& token) { return source; }
Pair& Target(Pair& target, const Token& token) { return target; }
// The decimal traces stay representable; C++17 evaluates the RHS before the LHS.
void Assign(Pair& target, const Pair& source, int& trace) {
  Target(target, Token(&trace, 5)) = Source(source, Token(&trace, 4));
}
void Conditional(bool flag, Pair& target, const Pair& source) { flag ? (target = source) : target; }
