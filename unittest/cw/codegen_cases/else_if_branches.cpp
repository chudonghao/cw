struct Token {
  Token() {}
  ~Token() {}
};
bool Ready(const Token& token) { return true; }

void StatementChain(bool first, bool second) {
  if (first) {
    Token a;
  } else if (second) {
    Token b;
  } else {
    Token c;
  }
}

int ResultChain(bool first, bool second) {
  if (first) {
    return 1;
  } else if (second) {
    return 2;
  } else {
    return 3;
  }
}

void ConditionTemporary(bool first) {
  if (first) {
  } else if (Ready(Token())) {
  }
}
