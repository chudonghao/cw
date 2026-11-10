func StatementChains(first bool, second bool) {
  if first {
    first;
  } else if second {
    second;
  } else {
    first;
  }
  if first {
    first;
  } else if second {
    second;
  }
}

func ReturnChain(first bool, second bool) i32 {
  if first {
    1
  } else if second {
    2
  } else {
    3
  }
}

func BlockChain(first bool, second bool) i32 {
  var value i32 := {
    if first {
      1
    } else if second {
      2
    } else {
      3
    }
  }
  value
}

func InitializationChain(first bool, second bool) i32 {
  var value i32;
  if first {
    value := 1;
  } else if second {
    value := 2;
  } else {
    value := 3;
  }
  value
}
