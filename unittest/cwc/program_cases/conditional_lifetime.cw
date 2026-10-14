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

func Conditional(flag bool, trace *i32) {
  if flag {
    var value := Token(trace, 1);
  } else {
    var value := Token(trace, 2);
  }
}

func main() i32 {
  var trace i32 := 0;
  Conditional(true, &trace);
  Conditional(false, &trace);
  if trace == 1122 { 1 } else { 0 }
}
