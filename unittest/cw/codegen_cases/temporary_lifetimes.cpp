struct Token {
  Token() {}
  ~Token() {}
};
bool Check(const Token& value) { return false; }
int Next() { return 7; }
void Use(bool test, int next) {}

void Short(bool flag) {
  // C++17 leaves argument order unspecified; CW evaluates the boolean argument first.
  Use(flag && Check(Token()), Next());
}
void Repeat(bool& flag, bool other) {
  while (flag && (other && Check(Token()))) {
    flag = false;
  }
}

int Change(bool& flag) {
  flag = false;
  return 7;
}
void Choice(bool flag) {
  // The lambda keeps both the chosen temporary and the captured condition alive
  // through Change and Use, while prescribing CW's argument evaluation order.
  auto use = [&](bool test) { Use(test, Change(flag)); };
  use(flag ? Check(Token()) : Check(Token()));
}
