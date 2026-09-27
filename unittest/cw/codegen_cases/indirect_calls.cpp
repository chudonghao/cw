signed char Signed(signed char (*callback)(signed char), signed char value) { return callback(value); }

unsigned short Unsigned(unsigned short (*callback)(unsigned short), unsigned short value) { return callback(value); }

bool Boolean(bool (*callback)(bool), bool value) { return callback(value); }

double Floating(double (*callback)(float), int value) { return callback(value); }

int& Reference(int& (*callback)(int&), int& value) { return callback(value); }

int ReadReference(const int& (*callback)(const int&), const int& value) { return callback(value); }

int&& MoveReference(int&& (*callback)(int&&), int&& value) { return callback(static_cast<int&&>(value)); }

void Void(void (*callback)(int*), int* pointer) { callback(pointer); }

using IntCallback = int (*)(int);
int Chained(IntCallback (*factory)(), int value) { return factory()(value); }
