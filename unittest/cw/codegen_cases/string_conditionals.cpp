// Explicit bytes match CW's unterminated u8 arrays; trivial wrappers enable value results and copies.
struct Array {
  unsigned char values[3];
};

static const Array Yes{{'y', 'e', 's'}};
static const Array No{{'n', 'o', '!'}};

const Array& Choose(bool flag) { return flag ? Yes : No; }

unsigned char ReadChoice(bool flag, unsigned long index) {
  Array text = flag ? Yes : No;
  return text.values[index];
}

unsigned char WithValue(bool flag, unsigned long index) {
  Array text = flag ? Yes : Array{{'n', 'o', '!'}};
  return text.values[index];
}

const Array& Touch(unsigned int& count) {
  count = count + 1;
  return No;
}

void Discard(bool flag, unsigned int& count) { (void)(flag ? Yes : Touch(count)); }
