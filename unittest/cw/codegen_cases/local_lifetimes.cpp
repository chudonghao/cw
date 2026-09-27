#include <new>

struct Token {
  Token() {}
  ~Token() {}
};

void Deferred(bool flag) {
  // C++ has no deferred initialization of an ordinary local. Explicit storage
  // preserves CW's outer lifetime when construction happens in a nested block.
  alignas(Token) unsigned char storage[sizeof(Token)];
  Token* outer = reinterpret_cast<Token*>(storage);
  if (flag) {
    Token inner;
    new (outer) Token();
  } else {
    new (outer) Token();
  }
  outer->~Token();
}
void Early(bool flag) {
  // The only initialized path immediately exits the function in both languages.
  if (flag) {
    Token outer;
    return;
  }
}
void Loop(bool flag, bool stop) {
  Token outer;
  while (flag) {
    Token inner;
    if (stop) {
      break;
    }
    continue;
  }
}
