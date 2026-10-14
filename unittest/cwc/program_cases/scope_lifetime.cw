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

func Scope(trace *i32) {
  var first := Token(trace, 1);
  var second := Token(trace, 2);
}

func main() i32 {
  var trace i32 := 0;
  Scope(&trace);
  if trace == 1221 { 1 } else { 0 }
}
