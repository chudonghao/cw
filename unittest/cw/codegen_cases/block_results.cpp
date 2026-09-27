int Replace(int& value) {
  value = 71;
  return value;
}

// C++ has no CW result blocks or named return objects. Local assignments below
// express their scalar data flow, including use of an earlier block result.
int BlockResults() {
  int result;
  int source;
  source = 11;
  int first = source;
  int second = Replace(source);
  int block;
  int forwarded;
  {
    int saved = first;
    block = saved;
    forwarded = block;
  }
  result = forwarded;
  return result;
}

int BranchResults(bool flag) {
  int first;
  int second;
  if (flag) {
    first = 7;
    second = first;
  } else {
    first = 11;
    second = first;
  }
  return second;
}
