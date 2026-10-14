struct Token {
  trace *i32;
  tag i32;
}

ctor Token(trace *i32, tag i32) {
  this.trace := trace;
  this.tag := tag;
  *trace = *trace * 10 + tag;
}

dtor Token() { *this.trace = *this.trace * 10 + this.tag; }

func Consume(value &copy Token) {}

func main() i32 {
  var trace i32 := 0;
  Consume(Token(&trace, 1));
  if trace == 11 { 1 } else { 0 }
}
