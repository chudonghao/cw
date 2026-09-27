struct Receipt { trace *i32; }
ctor Receipt(trace *i32) { this.trace := trace; }
dtor Receipt() { *this.trace = *this.trace * 10 + 2; }

struct Item { trace *i32; }
ctor Item(trace *i32) { this.trace := trace; }
dtor Item() {}
func operator=(target &mut Item, source &copy Item) Receipt {
  *target.trace = *target.trace * 10 + 1;
  Receipt(target.trace)
}

struct Token { trace *i32; tag i32; }
ctor Token(trace *i32, tag i32) {
  this.trace := trace;
  this.tag := tag;
  *trace = *trace * 10 + tag;
}
dtor Token() { *this.trace = *this.trace * 10 + this.tag; }

func Source(source &copy [2] Item, token &copy Token) &copy [2] Item { source }
func Target(target &mut [2] Item, token &copy Token) &mut [2] Item { target }
func Assign(target &mut [2] Item, source &copy [2] Item, trace &mut i32) {
  Target(target, Token(&trace, 5)) = Source(source, Token(&trace, 4));
}
func Conditional(flag bool, target &mut [2] Item, source &copy [2] Item) {
  flag ? (target = source) : target;
}
