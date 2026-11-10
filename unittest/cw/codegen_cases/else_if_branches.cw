struct Token {}
ctor Token() {}
dtor Token() {}
func Ready(token &copy Token) bool { true }

func StatementChain(first bool, second bool) {
  if first {
    var a := Token();
  } else if second {
    var b := Token();
  } else {
    var c := Token();
  }
}

func ResultChain(first bool, second bool) i32 {
  if first {
    1
  } else if second {
    2
  } else {
    3
  }
}

func ConditionTemporary(first bool) {
  if first {
  } else if Ready(Token()) {
  }
}
