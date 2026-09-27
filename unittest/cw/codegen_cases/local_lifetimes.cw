struct Token {}
ctor Token() {}
dtor Token() {}

func Deferred(flag bool) {
  var outer Token;
  if flag {
    var inner := Token();
    outer := Token();
  } else {
    outer := Token();
  }
}
func Early(flag bool) {
  var outer Token;
  if flag {
    outer := Token();
    return;
  }
}
func Loop(flag bool, stop bool) {
  var outer := Token();
  while flag {
    var inner := Token();
    if stop { break; }
    continue;
  }
}
