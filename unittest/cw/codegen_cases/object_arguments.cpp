#include <utility>

struct Token {
  Token() {}
  Token(const Token&) {}
  Token(Token&&) {}
  ~Token() {}
};
void Consume(Token value, int next) {}
int Next() { return 3; }
using Operation = void (*)(Token, int);
Operation Select(Operation operation) { return operation; }

void Arguments() {
  Token source;
  // CW completes each argument left to right; C++17 leaves the argument order unspecified.
  Consume(source, Next());
  Consume(std::move(source), Next());
  Operation operation = &Consume;
  Select(operation)(Token(), Next());
}

struct Box {
  Box(Token value, int next) {}
  ~Box() {}
};
void Pack() { Box box{Token(), Next()}; }
