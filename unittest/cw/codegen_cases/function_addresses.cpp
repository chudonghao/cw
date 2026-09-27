using Callback = double (*)(double);
using IntCallback = int (*)(int);
int Later(int value);

int Select(int value) { return value; }

double Select(double value) { return value; }

Callback Get() { return &Select; }

double Invoke(double value) {
  Callback callback = &Select;
  return callback(value);
}

double Apply(Callback callback, double value) { return callback(value); }

double Pass() { return Apply(&Select, 2.5); }

IntCallback Forward() { return &Later; }

int Later(int value) { return value; }
