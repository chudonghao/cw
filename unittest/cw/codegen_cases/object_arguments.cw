struct Token {}
ctor Token() {}
ctor Token(other &copy Token) {}
ctor Token(other &move Token) {}
dtor Token() {}

func Consume(value Token, next i32) {}
func Next() i32 { 3 }
func Select(operation *func(Token, i32) void) *func(Token, i32) void { operation }

func Arguments() {
  var source := Token();
  Consume(source, Next());
  Consume(move source, Next());
  var operation *func(Token, i32) void := &Consume;
  Select(operation)(Token(), Next());
}

struct Box {}
ctor Box(value Token, next i32) {}
dtor Box() {}
func Pack() { var box := Box(Token(), Next()); }
