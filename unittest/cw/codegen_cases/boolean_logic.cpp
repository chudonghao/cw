bool Touch(bool& flag) {
  flag = !flag;
  return flag;
}

bool BooleanLogic(bool a, bool b, bool c, bool& flag) { return (a && b) && (c || Touch(flag)); }
