struct Token {}
ctor Token() {}
dtor Token() {}
func Check(value &copy Token) bool { false }
func Next() i32 { 7 }
func Use(test bool, next i32) {}

func Short(flag bool) {
  Use(flag && Check(Token()), Next());
}
func Repeat(flag &mut bool, other bool) {
  while flag && (other && Check(Token())) {
    flag = false;
  }
}

func Change(flag &mut bool) i32 { flag = false; 7 }
func Choice(flag bool) {
  Use(flag ? Check(Token()) : Check(Token()), Change(flag));
}
