bool Tick(bool& flag) {
  flag = !flag;
  return flag;
}

int WhileLoop(bool& flag, bool skip, bool leave) {
  int result = 0;
  while (Tick(flag)) {
    if (leave) {
      break;
    }
    if (skip) {
      skip = false;
      continue;
    }
    result = 9;
  }
  return result;
}

int NestedLoops(bool outer, bool inner, bool stop, bool finish) {
  while (outer) {
    while (inner) {
      if (stop) {
        break;
      }
      inner = false;
      continue;
    }
    if (finish) {
      return 7;
    }
    if (stop) {
      break;
    }
    outer = false;
    continue;
  }
  return 9;
}
