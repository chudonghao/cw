void StatementChains(bool first, bool second) {
  if (first) {
    first;
  } else if (second) {
    second;
  } else {
    first;
  }
  if (first) {
    first;
  } else if (second) {
    second;
  }
}

int ReturnChain(bool first, bool second) {
  if (first) {
    return 1;
  } else if (second) {
    return 2;
  } else {
    return 3;
  }
}

// CW completes the variable result block in each branch; C++ assigns a local in each branch.
int BlockChain(bool first, bool second) {
  int value;
  if (first) {
    value = 1;
  } else if (second) {
    value = 2;
  } else {
    value = 3;
  }
  return value;
}

int InitializationChain(bool first, bool second) {
  int value;
  if (first) {
    value = 1;
  } else if (second) {
    value = 2;
  } else {
    value = 3;
  }
  return value;
}
