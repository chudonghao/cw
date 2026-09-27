func Tick(flag &mut bool) bool {
  flag = !flag;
  flag
}

func WhileLoop(flag &mut bool, skip bool, leave bool) i32 {
  var result i32 := 0;
  while Tick(flag) {
    if leave {
      break;
    }
    if skip {
      skip = false;
      continue;
    }
    result = 9;
  }
  result
}

func NestedLoops(outer bool, inner bool, stop bool, finish bool) i32 {
  while outer {
    while inner {
      if stop {
        break;
      }
      inner = false;
      continue;
    }
    if finish {
      return 7;
    }
    if stop {
      break;
    }
    outer = false;
    continue;
  }
  9
}
