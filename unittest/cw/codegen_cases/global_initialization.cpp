extern int number;
int Read() { return number; }
int Advance() {
  number = number + 1;
  return number;
}

int number = 7;
int first = Advance(), second = Advance();
// These initializers express the order of CW's shared block.
bool enabled = true;
const int saved = Read();
int* address = &number;
int (*action)() = &Read;
// CW copies the two content bytes without a terminator.
unsigned char text[2] = {'h', 'i'};
struct Record {
  int value;
};
Record record = Record();

int Update() {
  *address = action();
  record.value = second;
  return first + record.value;
}
